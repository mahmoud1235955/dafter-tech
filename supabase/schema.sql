-- =============================================================
--  دفترك | DaftarTech — تجهيز قاعدة بيانات Supabase
--  شغّل الملف من: Dashboard → SQL Editor → New query → Run
--  (أو: supabase db execute -f supabase/schema.sql)
-- =============================================================

-- 1) جدول الملفات الشخصية (مرتبط بجدول مستخدمي Supabase Auth)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text not null,
  business_type smallint not null default 0,
  created_at timestamptz not null default now()
);

comment on table public.profiles is
  'بيانات أصحاب المحلات - business_type: 0 = بقالة/محل، 1 = موزع/جملة، 2 = مشروع منزلي/أونلاين';

-- فهرسة للبحث برقم الهاتف
-- (مش unique عن قصد: نفس الرقم ممكن يرجع يحساب جديد بعد حذف القديم)
create index if not exists profiles_phone_idx on public.profiles (phone);

-- 2) تفعيل الحماية على مستوى الصفوف (RLS)
alter table public.profiles enable row level security;

-- 3) السياسات: كل مستخدم يشوف ويعدّل صفه هو بس
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- =============================================================
--  ملاحظات على باقي الجداول (المزامنة مش جزء من الشاشة دي):
--  الـ CustomerModel بتكتب الأعمدة بصيغة camelCase (totalDebt, isSynced, ...)
--  وبوستجريس بيحوّل أي معرّف غير مقتبص إلى lowercase،
--  فلازم قبل تفعيل مزامنة العملاء نوحّد الأسماء (snake_case) في الموديل والجدول.
-- =============================================================
