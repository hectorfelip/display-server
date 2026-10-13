-- Run this once in Supabase: SQL Editor > New query > Run

create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),
  title text,
  image_url text not null,
  storage_path text not null,
  active boolean not null default true,
  position int not null default 0,
  duration_seconds int not null default 8,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

-- RLS (Row Level Security) = rules that say who can read/write each row
alter table public.promotions enable row level security;

create policy "anyone can read active promos"
  on public.promotions for select
  to anon, authenticated
  using (active = true or auth.role() = 'authenticated');

create policy "logged users manage promos"
  on public.promotions for all
  to authenticated
  using (true) with check (true);

-- Storage bucket (folder) for the images, public so the display page can load them
insert into storage.buckets (id, name, public)
values ('promos', 'promos', true)
on conflict (id) do nothing;

create policy "anyone can view promo images"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'promos');

create policy "logged users upload promo images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'promos');

create policy "logged users delete promo images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'promos');
