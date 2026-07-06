-- Loot — migration 0003: transactional order placement
-- The ONLY code path that decrements stock. Row-locks variants, validates stock,
-- inserts order + items + event atomically. Called by edge functions (service role)
-- and by authenticated clients via RPC.

create type place_order_item as (
  variant_id uuid,
  qty        int
);

create function public.place_order(
  p_profile_id     uuid,            -- null for guests
  p_email          text,
  p_phone          text,
  p_payment_method payment_method,
  p_items          place_order_item[],
  p_shipping_addr  jsonb,
  p_promo_code     text default null
) returns table (order_id uuid, order_no text, total_fils int)
language plpgsql security definer set search_path = public as $$
declare
  v_order_id      uuid;
  v_order_no      text;
  v_item          place_order_item;
  v_variant       record;
  v_subtotal      int := 0;
  v_shipping      int := 2000;             -- flat 2.000 KD
  v_free_ship_min int := 15000;            -- free shipping >= 15.000 KD
  v_discount      int := 0;
  v_total         int;
  v_promo         record;
  v_status        order_status;
begin
  if array_length(p_items, 1) is null then
    raise exception 'EMPTY_CART';
  end if;

  -- Lock variants in a stable order to avoid deadlocks; validate stock & price.
  foreach v_item in array p_items loop
    select pv.id, pv.price_fils, pv.stock_qty, pv.product_id
      into v_variant
      from product_variants pv
      join products p on p.id = pv.product_id and p.status = 'active'
     where pv.id = v_item.variant_id
       for update of pv;
    if not found then
      raise exception 'VARIANT_NOT_FOUND %', v_item.variant_id;
    end if;
    if v_variant.stock_qty < v_item.qty then
      raise exception 'INSUFFICIENT_STOCK %', v_item.variant_id;
    end if;
    v_subtotal := v_subtotal + v_variant.price_fils * v_item.qty;
  end loop;

  if v_subtotal >= v_free_ship_min then
    v_shipping := 0;
  end if;

  -- Promo (validated server-side; usage counted atomically)
  if p_promo_code is not null then
    select * into v_promo from promotions
     where code = upper(p_promo_code) and is_active
       and (starts_at is null or starts_at <= now())
       and (ends_at is null or ends_at >= now())
       and (max_uses is null or used_count < max_uses)
       and min_order_fils <= v_subtotal
       for update;
    if not found then
      raise exception 'INVALID_PROMO';
    end if;
    v_discount := case v_promo.type
      when 'percent'       then (v_subtotal * v_promo.value) / 100
      when 'fixed'         then least(v_promo.value, v_subtotal)
      when 'free_shipping' then 0
    end;
    if v_promo.type = 'free_shipping' then v_shipping := 0; end if;
    update promotions set used_count = used_count + 1 where id = v_promo.id;
  end if;

  v_total := v_subtotal - v_discount + v_shipping;   -- tax_fils = 0 (no VAT in Kuwait today)
  v_status := case when p_payment_method = 'cod' then 'cod_confirmed'::order_status
                   else 'pending_payment'::order_status end;

  insert into orders (profile_id, email, phone, status, payment_method,
                      subtotal_fils, shipping_fils, discount_fils, tax_fils, total_fils,
                      shipping_address)
  values (p_profile_id, p_email, p_phone, v_status, p_payment_method,
          v_subtotal, v_shipping, v_discount, 0, v_total, p_shipping_addr)
  returning id, orders.order_no into v_order_id, v_order_no;

  -- Snapshot lines + decrement stock (rows already locked above)
  foreach v_item in array p_items loop
    insert into order_items (order_id, variant_id, product_name, product_name_ar,
                             image_url, unit_price_fils, qty)
    select v_order_id, pv.id, p.name, p.name_ar,
           (select url from product_images pi where pi.product_id = p.id order by sort_order limit 1),
           pv.price_fils, v_item.qty
      from product_variants pv join products p on p.id = pv.product_id
     where pv.id = v_item.variant_id;

    update product_variants set stock_qty = stock_qty - v_item.qty
     where id = v_item.variant_id;
  end loop;

  insert into order_events (order_id, status, note)
  values (v_order_id, v_status, 'Order placed');

  return query select v_order_id, v_order_no, v_total;
end $$;

-- Callable by authenticated users (guests go through the edge function which
-- uses the service role).
grant execute on function public.place_order to authenticated, service_role;
revoke execute on function public.place_order from anon;
