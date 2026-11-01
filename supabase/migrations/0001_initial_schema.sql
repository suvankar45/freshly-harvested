-- Freshly Harvested: initial schema (review and apply in a Supabase project)
create extension if not exists pgcrypto;

create type public.app_role as enum ('customer','admin','delivery');
create type public.product_category as enum ('vegetables','fruits','meat','fish','dairy','groceries');
create type public.order_status as enum ('placed','confirmed','packing','ready_for_pickup','out_for_delivery','delivered','cancelled');
create type public.payment_status as enum ('pending','paid','failed','refunded');
create type public.payment_method as enum ('upi','card','cash_on_delivery');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  role public.app_role not null default 'customer',
  created_at timestamptz not null default now()
);

create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text default 'Home',
  recipient_name text not null,
  phone text not null,
  address_line text not null,
  landmark text,
  city text not null,
  state text not null,
  postal_code text not null,
  latitude double precision,
  longitude double precision,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  sku text unique,
  name text not null,
  description text,
  category public.product_category not null,
  image_url text,
  unit_label text not null, -- e.g. 500 g, 1 kg, 1 litre, 6 pcs
  price_paise integer not null check (price_paise >= 0),
  compare_at_price_paise integer check (compare_at_price_paise is null or compare_at_price_paise >= price_paise),
  is_weighted boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.inventory (
  product_id uuid primary key references public.products(id) on delete cascade,
  quantity numeric(12,3) not null default 0 check (quantity >= 0),
  low_stock_threshold numeric(12,3) not null default 5,
  updated_at timestamptz not null default now()
);

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id),
  change_quantity numeric(12,3) not null,
  reason text not null,
  reference_id uuid,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number bigint generated always as identity unique,
  customer_id uuid not null references public.profiles(id),
  address_id uuid not null references public.addresses(id),
  status public.order_status not null default 'placed',
  payment_method public.payment_method not null,
  payment_status public.payment_status not null default 'pending',
  subtotal_paise integer not null check (subtotal_paise >= 0),
  delivery_fee_paise integer not null default 0 check (delivery_fee_paise >= 0),
  discount_paise integer not null default 0 check (discount_paise >= 0),
  total_paise integer not null check (total_paise >= 0),
  customer_note text,
  placed_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  product_name_snapshot text not null,
  unit_label_snapshot text not null,
  unit_price_paise integer not null check (unit_price_paise >= 0),
  quantity numeric(12,3) not null check (quantity > 0),
  line_total_paise integer not null check (line_total_paise >= 0)
);

create table public.delivery_assignments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null unique references public.orders(id) on delete cascade,
  delivery_partner_id uuid references public.profiles(id),
  assigned_at timestamptz,
  picked_up_at timestamptz,
  delivered_at timestamptz,
  delivery_note text
);

create index products_category_active_idx on public.products(category, is_active);
create index orders_customer_placed_idx on public.orders(customer_id, placed_at desc);
create index orders_status_idx on public.orders(status);
create index addresses_user_idx on public.addresses(user_id);

-- Enable RLS. Production policies should be added before connecting the client.
alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.products enable row level security;
alter table public.inventory enable row level security;
alter table public.inventory_movements enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.delivery_assignments enable row level security;

-- Public catalogue reads only active products. Do not expose inventory quantities publicly.
create policy "Anyone can read active products" on public.products
for select using (is_active = true);
