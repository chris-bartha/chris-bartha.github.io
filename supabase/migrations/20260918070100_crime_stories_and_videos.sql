-- The crime corner: something to read and something to watch when she does not
-- feel like a quiz. Stories are read inside the app; videos open on YouTube.
--
-- Nothing here is per-player except which videos she has already opened. A
-- clicked video stays on the list for three hours -- long enough to go back to
-- it -- and then drops out of the way. The click itself is never deleted, so
-- "Amiket már megnéztem" can always show it again.

create table public.crime_stories (
  id text primary key,
  title text not null,
  teaser text not null,
  body text not null,
  year_label text not null default '',
  place text not null default '',
  closing text not null default '',
  minutes smallint not null default 8,
  language_code text not null default 'hu' check (language_code in ('en', 'hu')),
  display_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint crime_stories_title_not_blank check (length(btrim(title)) > 0),
  constraint crime_stories_teaser_not_blank check (length(btrim(teaser)) > 0),
  -- A "story" that is three sentences long is a caption. This is the one thing
  -- worth failing loudly over.
  constraint crime_stories_body_long_enough check (length(btrim(body)) >= 1200),
  constraint crime_stories_minutes_sane check (minutes between 1 and 60)
);

create table public.crime_videos (
  id text primary key,
  youtube_id text not null unique,
  title text not null,
  channel text not null default '',
  summary text not null default '',
  case_name text not null default '',
  language_code text not null default 'hu' check (language_code in ('en', 'hu')),
  display_order integer not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint crime_videos_title_not_blank check (length(btrim(title)) > 0),
  -- Eleven characters from YouTube's own alphabet. A malformed id is a dead end
  -- she has no way to diagnose, so it must never reach the table.
  constraint crime_videos_youtube_id_shape
    check (youtube_id ~ '^[A-Za-z0-9_-]{11}$')
);

create table public.crime_video_views (
  user_id uuid not null references auth.users(id) on delete cascade,
  video_id text not null references public.crime_videos(id) on delete cascade,
  first_clicked_at timestamptz not null default now(),
  last_clicked_at timestamptz not null default now(),
  click_count integer not null default 1 check (click_count > 0),
  primary key (user_id, video_id)
);

create index crime_stories_order_idx on public.crime_stories (display_order)
  where is_active;
create index crime_videos_order_idx on public.crime_videos (display_order)
  where is_active;
create index crime_video_views_user_idx
  on public.crime_video_views (user_id, first_clicked_at desc);

alter table public.crime_stories enable row level security;
alter table public.crime_videos enable row level security;
alter table public.crime_video_views enable row level security;

create policy "Players can read active crime stories"
  on public.crime_stories for select
  to authenticated
  using (is_active);

create policy "Players can read active crime videos"
  on public.crime_videos for select
  to authenticated
  using (is_active);

create policy "Players can read their own crime video history"
  on public.crime_video_views for select
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on table public.crime_stories from anon, authenticated;
revoke all on table public.crime_videos from anon, authenticated;
revoke all on table public.crime_video_views from anon, authenticated;
grant select on table public.crime_stories to authenticated;
grant select on table public.crime_videos to authenticated;
grant select on table public.crime_video_views to authenticated;
grant all on table public.crime_stories to service_role;
grant all on table public.crime_videos to service_role;
grant all on table public.crime_video_views to service_role;

-- Recording a click is an upsert with a counter, which would need insert and
-- update policies and a read-back to do from the browser. One function does it
-- in a single round trip and can only ever write the caller's own row.
create or replace function public.record_crime_video_click(target_video_id text)
returns timestamptz
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_user uuid := (select auth.uid());
  first_seen timestamptz;
begin
  if request_user is null then
    raise exception 'Only a signed-in player can record a video click'
      using errcode = '42501';
  end if;

  if not exists (
    select 1 from public.crime_videos
    where id = target_video_id and is_active
  ) then
    raise exception 'No such crime video' using errcode = '22023';
  end if;

  insert into public.crime_video_views (user_id, video_id)
  values (request_user, target_video_id)
  on conflict (user_id, video_id) do update set
    last_clicked_at = now(),
    click_count = public.crime_video_views.click_count + 1
  returning public.crime_video_views.first_clicked_at into first_seen;

  return first_seen;
end;
$$;

revoke all on function public.record_crime_video_click(text)
  from public, anon, authenticated;
grant execute on function public.record_crime_video_click(text) to authenticated;

comment on table public.crime_stories is
  'Long-form Hungarian true-crime stories read inside the app. No quiz, no scoring.';
comment on table public.crime_videos is
  'Hand-picked Hungarian-language crime videos on YouTube. Every id was checked against YouTube oEmbed before it was inserted.';
comment on table public.crime_video_views is
  'Which videos this player has opened. Never deleted: the app only hides a video three hours after the click.';
comment on function public.record_crime_video_click(text) is
  'Records that the current player opened a video and returns when they first opened it.';
