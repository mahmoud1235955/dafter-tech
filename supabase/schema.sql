-- =============================================================
--  دفترك | DaftarTech — تجهيز قاعدة بيانات Supabase
--
--  الحالة: مُطبَّق فعلياً على مشروع `gkmswfzekvqxdcwyphot`
--  (دا نفس المشروع المكتوب في AppConstants.defaultSupabaseUrl)
--
--  لإعادة التطبيق على مشروع جديد:
--  Dashboard → SQL Editor → New query → الصق الملف → Run
--  (أو: supabase db execute -f supabase/schema.sql)
-- =============================================================

-- -------------------------------------------------------------
-- 1) جدول الملفات الشخصية (مرتبط بجدول مستخدمي Supabase Auth)
--    ملاحظة: `id` هنا نص (text) مش uuid، وUserModel.toJson() بيبعت
--    authUser.id كنص — فلا تغيّر النوع من غير تعديل الموديل.
-- -------------------------------------------------------------
create table if not exists public.profiles (
  id            text primary key,
  phone         text not null,
  business_type smallint not null default 0,
  created_at    timestamptz not null default now()
);

comment on table public.profiles is
  'بيانات أصحاب المحلات - business_type: 0 = بقالة/محل، 1 = موزع/جملة، 2 = مشروع منزلي/أونلاين';

create index if not exists profiles_phone_idx on public.profiles (phone);

-- -------------------------------------------------------------
-- 2) جدول العملاء
--    أسماء الأعمدة snake_case علشان تطابق CustomerModel.toJson()،
--    بينما جدول SQLite المحلي لسه camelCase (toMap/fromMap).
--    owner_id بتتملأ تلقائياً بـ auth.uid() — العميل مش بيبعتها.
-- -------------------------------------------------------------
create table if not exists public.customers (
  id                  text primary key,
  owner_id            uuid not null default auth.uid(),
  name                text not null,
  phone               text not null,
  address             text,
  total_debt          double precision not null default 0,
  credit_limit        double precision not null default 0,
  last_transaction_at timestamptz not null default now(),
  is_synced           boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

comment on table public.customers is
  'عملاء المحل (دفاتر الآجل) - كل صف مملوك لصاحب حساب في auth.users';

-- -------------------------------------------------------------
-- 3) جدول المعاملات
-- -------------------------------------------------------------
create table if not exists public.transactions (
  id                    text primary key,
  owner_id              uuid not null default auth.uid(),
  customer_id           text not null references public.customers (id) on delete cascade,
  amount                double precision not null,
  type                  smallint not null,
  payment_method        smallint not null,
  notes                 text,
  receipt_image_url     text,
  bank_reference_number text,
  transaction_date      timestamptz not null default now(),
  is_verified           boolean not null default false,
  created_at            timestamptz not null default now()
);

comment on table public.transactions is
  'المعاملات المالية - type: 0 = بضاعة مسلّمة (دين), 1 = سداد مستلم';
comment on column public.transactions.type is
  '0 = goodsDelivered (دين على العميل), 1 = paymentReceived (سداد)';
comment on column public.transactions.payment_method is
  '0=cash, 1=instaPay, 2=vodafoneCash, 3=bankTransfer, 4=other';

-- -------------------------------------------------------------
-- 4) الفهارس
-- -------------------------------------------------------------
create index if not exists customers_owner_idx         on public.customers (owner_id);
create index if not exists customers_owner_last_tx_idx on public.customers (owner_id, last_transaction_at desc);
create index if not exists customers_phone_idx         on public.customers (owner_id, phone);
create index if not exists transactions_customer_idx   on public.transactions (customer_id);
create index if not exists transactions_owner_date_idx on public.transactions (owner_id, transaction_date desc);

-- -------------------------------------------------------------
-- 5) تحديث updated_at تلقائياً
-- -------------------------------------------------------------
create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists customers_touch_updated_at on public.customers;
create trigger customers_touch_updated_at
  before update on public.customers
  for each row execute function public.touch_updated_at();

-- -------------------------------------------------------------
-- 6) الحماية على مستوى الصفوف (RLS) — كل مستخدم يشوف صفوفه هو بس
-- -------------------------------------------------------------
alter table public.profiles    enable row level security;
alter table public.customers   enable row level security;
alter table public.transactions enable row level security;

-- profiles
drop policy if exists "Allow public access for profiles" on public.profiles;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select using (id::text = auth.uid()::text);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert with check (id::text = auth.uid()::text);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id::text = auth.uid()::text)
  with check (id::text = auth.uid()::text);

-- customers
drop policy if exists "customers_select_own" on public.customers;
create policy "customers_select_own" on public.customers
  for select using (owner_id = auth.uid());

drop policy if exists "customers_insert_own" on public.customers;
create policy "customers_insert_own" on public.customers
  for insert with check (owner_id = auth.uid());

drop policy if exists "customers_update_own" on public.customers;
create policy "customers_update_own" on public.customers
  for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists "customers_delete_own" on public.customers;
create policy "customers_delete_own" on public.customers
  for delete using (owner_id = auth.uid());

-- transactions
drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own" on public.transactions
  for select using (owner_id = auth.uid());

drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own" on public.transactions
  for insert with check (owner_id = auth.uid());

drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own" on public.transactions
  for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists "transactions_delete_own" on public.transactions;
create policy "transactions_delete_own" on public.transactions
  for delete using (owner_id = auth.uid());
