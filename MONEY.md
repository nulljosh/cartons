# Cartons Money

How Cartons makes money. The company plan is `REVENUE.md` in the Code root; the ledger is `GTM.md`.

## Price and rail

$0.99 upfront on the App Store (ASC 6825115360), iPhone, iPad and Mac in one purchase. Apple keeps 15%, so each sale pays about $0.84. The web app at cartons.jaybulb.com stays free.

## What is actually sold

A tracker that turns a UPS number into a countdown to the delivery day. The tracking data belongs to UPS. Cartons reads UPS's own tracking page in a hidden web view and sells none of it. The risk is that UPS changes that page or stops it being read. No price fixes that.

## Who pays and why

Someone who gets packages and wants one calm screen. Not an account, not an inbox scan, not a subscription. The big trackers want one of those three, and Cartons asks for a dollar, once.

## Cost to serve

No paid API in the app. The web app is a Worker that loads UPS's tracking page in Cloudflare Browser Rendering, which bills browser time. The caps in the code: 10 lookups a minute per visitor (a LIMITER binding, a brake and not a wall), results cached for 15 minutes, and a warm browser kept for 10 minutes. No dollar cap is set. The worst case is set by the Browser Rendering plan.

## Where we are

- 2026-10-20: renamed from Carton to Cartons, because Carton belongs to another account on the store. The Paid Apps agreement was accepted the same day.
- 2026-10-20: 1.0.0 went to App Review on iOS and Mac. The price moved from free to $0.99 the same day, before the first sale.
- Revenue: no verified number (the App Store Connect key cannot read sales yet).

## Role in the company plan

Catalogue. GTM.md lists it as a $0.99 app that is free on the web. It serves Stage 0 as a dollar app that proves strangers pay. It gets no hero push, and under Stage 2 it either folds into the grid or is retired.

## Next

Once 1.0 is live and the Sales role is on the key, read the first month of store sales against web visits. If the store sells nothing for a month, the price goes free.

## Million, billion, trillion

**A million.** Cartons is the package tracker people keep on their home screen because it asks for nothing but a number.

**A billion.** Cartons is how most people follow a parcel, and the only thing anyone pays for is one dollar on their phone.

**A trillion.** Cartons follows a parcel from any carrier, which only works if the carriers open their data, and that decision is not ours.

## Change it

`asc pricing schedule create --app 6825115360 --price 0.99 --base-territory USA --start-date YYYY-MM-DD`. Swap `--price 0.99` for `--free` to revert. No build, no review. Only with Joshua's yes in chat.

Anyone who got Cartons while it was free keeps it free.

*ASC 6825115360. Verified 2026-11-02.*
