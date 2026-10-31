
-- THE BOSS public journal. Run once in Supabase SQL Editor if recreating this project.
create extension if not exists pgcrypto;

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(btrim(title)) between 1 and 120),
  description text not null default '' check (char_length(description) <= 2000),
  image_url text check (image_url is null or image_url ~* '^https://'),
  youtube_url text check (youtube_url is null or youtube_url ~* '^https://(www\.)?(youtube\.com|youtu\.be)/'),
  link_url text check (link_url is null or link_url ~* '^https://'),
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists posts_published_created_at_idx
  on public.posts (published, created_at desc);

alter table public.posts enable row level security;
revoke all on table public.posts from public;
grant usage on schema public to anon, authenticated;
grant select on table public.posts to anon;
grant select, insert, update, delete on table public.posts to authenticated;

drop policy if exists "posts_read_published_or_admin" on public.posts;
create policy "posts_read_published_or_admin"
on public.posts for select
to anon, authenticated
using (
  published = true
  or lower((select auth.jwt() ->> 'email')) = 'hamidhassanmail@gmail.com'
);

drop policy if exists "posts_admin_insert" on public.posts;
create policy "posts_admin_insert"
on public.posts for insert
to authenticated
with check (lower((select auth.jwt() ->> 'email')) = 'hamidhassanmail@gmail.com');

drop policy if exists "posts_admin_update" on public.posts;
create policy "posts_admin_update"
on public.posts for update
to authenticated
using (lower((select auth.jwt() ->> 'email')) = 'hamidhassanmail@gmail.com')
with check (lower((select auth.jwt() ->> 'email')) = 'hamidhassanmail@gmail.com');

drop policy if exists "posts_admin_delete" on public.posts;
create policy "posts_admin_delete"
on public.posts for delete
to authenticated
using (lower((select auth.jwt() ->> 'email')) = 'hamidhassanmail@gmail.com');
