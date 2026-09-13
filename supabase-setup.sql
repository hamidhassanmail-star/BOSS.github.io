-- HAMID HASSAN BOSS posting system
-- Run this in Supabase SQL Editor after creating your project.
create extension if not exists pgcrypto;

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text default '',
  image_url text,
  youtube_url text,
  link_url text,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.posts enable row level security;

-- Visitors can only read published posts.
drop policy if exists "public read published posts" on public.posts;
create policy "public read published posts"
on public.posts for select
to anon, authenticated
using (published = true);

-- Signed-in users may manage posts only if their email is the admin email.
drop policy if exists "admin insert posts" on public.posts;
create policy "admin insert posts"
on public.posts for insert
to authenticated
with check ((auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com');

drop policy if exists "admin update posts" on public.posts;
create policy "admin update posts"
on public.posts for update
to authenticated
using ((auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com')
with check ((auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com');

drop policy if exists "admin delete posts" on public.posts;
create policy "admin delete posts"
on public.posts for delete
to authenticated
using ((auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com');

-- Storage bucket for future direct image uploads.
insert into storage.buckets (id, name, public)
values ('post-images','post-images',true)
on conflict (id) do nothing;

-- Public can view files in the post-images bucket.
drop policy if exists "public view post images" on storage.objects;
create policy "public view post images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'post-images');

-- Only the admin email can upload/update/delete images.
drop policy if exists "admin upload post images" on storage.objects;
create policy "admin upload post images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'post-images' and (auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com');

drop policy if exists "admin update post images" on storage.objects;
create policy "admin update post images"
on storage.objects for update
to authenticated
using (bucket_id = 'post-images' and (auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com')
with check (bucket_id = 'post-images' and (auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com');

drop policy if exists "admin delete post images" on storage.objects;
create policy "admin delete post images"
on storage.objects for delete
to authenticated
using (bucket_id = 'post-images' and (auth.jwt() ->> 'email') = 'hamidhassanmail@gmail.com');
