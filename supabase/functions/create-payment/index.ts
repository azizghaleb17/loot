// Loot — create-payment edge function
// Places the order server-side (never trusts client totals), then creates a
// MyFatoorah invoice (ExecutePayment) and returns the hosted payment page URL.
//
// Secrets (set via `supabase secrets set`):
//   MYFATOORAH_API_TOKEN  — sandbox or production token
//   MYFATOORAH_BASE_URL   — https://apitest.myfatoorah.com (sandbox) | https://api-kwt.myfatoorah.com
//   SITE_URL              — https://getloot.co (return URL base)

import { createClient } from "jsr:@supabase/supabase-js@2";

type PlaceOrderRequest = {
  profileId: string | null;
  email: string;
  phone: string;
  paymentMethod: "knet" | "card" | "cod";
  items: { variantId: string; qty: number }[];
  shippingAddress: Record<string, unknown>;
  promoCode?: string;
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = (await req.json()) as PlaceOrderRequest;
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // 1. Place the order transactionally — recomputes totals server-side.
  const { data: placed, error } = await supabase.rpc("place_order", {
    p_profile_id: body.profileId,
    p_email: body.email,
    p_phone: body.phone,
    p_payment_method: body.paymentMethod,
    p_items: body.items.map((i) => ({ variant_id: i.variantId, qty: i.qty })),
    p_shipping_addr: body.shippingAddress,
    p_promo_code: body.promoCode ?? null,
  });
  if (error) {
    return Response.json({ error: error.message }, { status: 400 });
  }
  const order = placed[0] as { order_id: string; order_no: string; total_fils: number };

  // 2. COD needs no gateway.
  if (body.paymentMethod === "cod") {
    return Response.json({ orderId: order.order_id, orderNo: order.order_no, paymentUrl: null });
  }

  // 3. Create MyFatoorah invoice. KWD amounts use 3 decimals: fils / 1000.
  const mfResponse = await fetch(
    `${Deno.env.get("MYFATOORAH_BASE_URL")}/v2/ExecutePayment`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${Deno.env.get("MYFATOORAH_API_TOKEN")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        PaymentMethodId: body.paymentMethod === "knet" ? 1 : 2, // 1 = KNET, 2 = Visa/MC (Kuwait)
        InvoiceValue: order.total_fils / 1000,
        DisplayCurrencyIso: "KWD",
        CustomerName: body.email,
        CustomerEmail: body.email,
        CustomerMobile: body.phone.replace(/^\+?965/, ""),
        MobileCountryCode: "+965",
        CallBackUrl: `${Deno.env.get("SITE_URL")}/checkout/result?order=${order.order_no}`,
        ErrorUrl: `${Deno.env.get("SITE_URL")}/checkout/result?order=${order.order_no}&failed=1`,
        ClientReferenceId: order.order_id,
      }),
    },
  );
  const mf = await mfResponse.json();
  if (!mf.IsSuccess) {
    return Response.json({ error: "PAYMENT_INIT_FAILED", detail: mf.Message }, { status: 502 });
  }

  await supabase
    .from("orders")
    .update({ payment_ref: String(mf.Data.InvoiceId) })
    .eq("id", order.order_id);

  return Response.json({
    orderId: order.order_id,
    orderNo: order.order_no,
    paymentUrl: mf.Data.PaymentURL,
  });
});
