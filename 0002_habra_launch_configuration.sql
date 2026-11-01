-- Habra launch configuration and operational audit support.
-- Apply after 0001_initial_schema.sql. Values are provisional and must be verified.
create table if not exists public.store_settings (
  id boolean primary key default true check (id = true),
  store_name text not null default 'Freshly Harvested',
  stock_point_label text not null default 'Near Habra Bazar, Habra, West Bengal',
  city text not null default 'Habra',
  state text not null default 'West Bengal',
  country_code text not null default 'IN',
  primary_postal_code text not null default '743263',
  currency_code text not null default 'INR',
  default_language text not null default 'bn-IN',
  updated_at timestamptz not null default now()
);

create table if not exists public.delivery_zones (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  center_label text not null,
  center_latitude double precision,
  center_longitude double precision,
  radius_km numeric(5,2) not null check (radius_km > 0),
  delivery_fee_paise integer not null default 2500 check (delivery_fee_paise >= 0),
  free_delivery_threshold_paise integer check (free_delivery_threshold_paise is null or free_delivery_threshold_paise >= 0),
  minimum_order_paise integer not null default 9900 check (minimum_order_paise >= 0),
  serviceable_postal_codes text[] not null default array['743263']::text[],
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_status_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  from_status public.order_status,
  to_status public.order_status not null,
  changed_by uuid references public.profiles(id),
  note text,
  created_at timestamptz not null default now()
);

insert into public.store_settings (id) values (true)
on conflict (id) do nothing;

insert into public.delivery_zones
  (name, center_label, radius_km, delivery_fee_paise, free_delivery_threshold_paise, minimum_order_paise, serviceable_postal_codes)
select 'Habra Bazar & nearby', 'Near Habra Bazar, Habra', 4.00, 2500, 49900, 9900, array['743263']::text[]
where not exists (select 1 from public.delivery_zones where name = 'Habra Bazar & nearby');

alter table public.store_settings enable row level security;
alter table public.delivery_zones enable row level security;
alter table public.order_status_events enable row level security;

-- Intentionally no write policies are added here. Add narrowly scoped admin policies
-- and server-side order/stock functions before connecting a client application.
