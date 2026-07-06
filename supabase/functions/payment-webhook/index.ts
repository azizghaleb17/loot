// Loot — payment-webhook edge function
// MyFatoorah calls this on payment events. Source of truth for marking orders paid.
// Idempotent: keyed on payment_ref (unique InvoiceId); duplicate webhooks are no-ops.
//
// Secrets: MYFATOORAH_WEBHOOK_SECRET (dashboard → webhook settings),
//          MYFATOORAH_API_TOKEN, MYFATOORAH_BASE_URL

import { createClient } from "jsr:@supabase/supabase-js@2";

async function verifySignature(req: Request, rawBody: string): Promise<boolean> {
  const signature = req.headers.get("MyFatoorah-Signature");
  const secret = Deno.env.get("MYFATOORAH_WEBHOOK_SECRET");
  if (!signature || !secret) return false;
  const key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign"],
  );
  const mac = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(rawBody));
  const expected = btoa(String.fromCharCode(...new Uint8Array(mac)));
  return expected === signature;
}

Deno.serve(async (req) => {
  const rawBody = await req.text();
  if (!(await verifySignature(req, rawBody))) {
    return new Response("Invalid signature", { status: 401 });
  }

  const event = JSON.parse(rawBody);
  const invoiceId = String(event?.Data?.InvoiceId ?? "");
  const txStatus = event?.Data?.TransactionStatus as string | undefined; // SUCCESS | FAILED
  if (!invoiceId) return new Response("Missing InvoiceId", { status: 400 });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: order } = await supabase
    .from("orders")
    .select("id, status")
    .eq("payment_ref", invoiceId)
    .maybeSingle();
  if (!order) return new Response("Unknown invoice", { status: 404 });

  // Idempotency: only transition orders still awaiting payment.
  if (order.status !== "pending_payment") {
    return Response.json({ ok: true, note: "already processed" });
  }

  if (txStatus === "SUCCESS") {
    await supabase.from("orders")
      .update({ status: "paid", paid_at: new Date().toISOString() })
      .eq("id", order.id);
    await supabase.from("order_events")
      .insert({ order_id: order.id, status: "paid", note: `MyFatoorah invoice ${invoiceId}` });
  } else if (txStatus === "FAILED") {
    await supabase.from("order_events")
      .insert({ order_id: order.id, status: "pending_payment", note: `Payment attempt failed (invoice ${invoiceId})` });
    // Order stays pending_payment; the reconciliation sweep cancels + restocks after TTL.
  }

  return Response.json({ ok: true });
});
