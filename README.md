# Freshly Harvested

Android-first grocery and fresh-food delivery starter for an own-inventory business in India.

## What's included
- Expo + React Native starter app
- Fresh green brand styling and responsive shopping UI
- Product categories: vegetables, fruits, meat, fish, dairy and groceries
- Search and product cards
- Local cart quantity controls and bill summary
- Demo checkout placeholder (does not submit a real order)
- Initial Supabase/PostgreSQL schema for profiles, addresses, products, inventory, orders and delivery assignments

## Run locally
1. Install Node.js LTS and Git.
2. Install Expo Go on an Android phone, or configure an Android emulator.
3. In this folder run:
   ```bash
   npm install
   npx expo start
   ```
4. Scan the QR code with Expo Go.

## Before real launch
- Create a Supabase project and apply `supabase/migrations/0001_initial_schema.sql`.
- Add strict row-level security policies and server-side order/stock transaction functions.
- Implement phone OTP authentication.
- Connect Razorpay using a trusted server/edge function. Never put secret keys in the mobile app.
- Configure Firebase Cloud Messaging for push notifications.
- Add verified delivery zones, serviceability, delivery fee and minimum order rules.
- Add food safety, FSSAI, invoicing, refund, privacy and consumer-protection compliance appropriate to the operating model.
- Replace sample products, images and prices with your actual catalogue.
- Test stock reservation, payment confirmation, cancellation and refund flows before production.

## Important
This is a development starter, not a production-ready commerce system. The current checkout is explicitly a demo. Do not accept real payments or customer orders until backend authorization, stock locking, payment verification, operational workflows and compliance are implemented.


## Habra launch configuration (new)
- Launch stock-point label: near Habra Bazar, Habra, West Bengal.
- Primary PIN reference: 743263 (verify each customer address; PIN alone is not proof of serviceability).
- Provisional delivery zone: 4 km radius, within the previously discussed 3–5 km planning range.
- Provisional fee: ₹25; free delivery above ₹499; minimum order ₹99. Change these after checking rider costs and local demand.
- Bengali (`bn-IN`) and English (`en-IN`) are configured as intended languages.
- `config/habra-launch.json` contains the editable launch settings.
- `admin/index.html` is a browser-only operations dashboard prototype with demo orders, stock controls and zone settings. Changes remain in that browser's local storage; it is not connected to a live database.
- Apply `supabase/migrations/0002_habra_launch_configuration.sql` after migration `0001` to add store settings, delivery zones and order status audit events.

## Admin dashboard prototype
Open `admin/index.html` in a desktop/mobile browser. It demonstrates order status updates, inventory adjustments, low-stock indicators and editable delivery settings. Do not use it to fulfil real orders: it has no login, server persistence, role enforcement or payment integration.
