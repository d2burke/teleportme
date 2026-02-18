-- ============================================================
-- TeleportMe — Seed Vibe Tags + City-Vibe Mappings
-- ============================================================

-- Clear existing vibe data (safe for fresh deploy)
DELETE FROM public.city_vibe_tags;
DELETE FROM public.vibe_tags;

-- ============================================================
-- INSERT VIBE TAGS (20 tags across 5 categories)
-- ============================================================

-- Lifestyle
INSERT INTO public.vibe_tags (id, name, emoji, category) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Walkable',       '🚶', 'lifestyle'),
  ('a1000000-0000-0000-0000-000000000002', 'Nightlife',      '🌙', 'lifestyle'),
  ('a1000000-0000-0000-0000-000000000003', 'Foodie',         '🍜', 'lifestyle'),
  ('a1000000-0000-0000-0000-000000000004', 'Beach Life',     '🏖️', 'lifestyle'),
  ('a1000000-0000-0000-0000-000000000005', 'Outdoorsy',      '🏔️', 'lifestyle'),
  ('a1000000-0000-0000-0000-000000000006', 'Coffee Culture', '☕', 'lifestyle'),
  ('a1000000-0000-0000-0000-000000000007', 'Luxury',         '✨', 'lifestyle');

-- Culture
INSERT INTO public.vibe_tags (id, name, emoji, category) VALUES
  ('a2000000-0000-0000-0000-000000000001', 'Arts & Music',   '🎨', 'culture'),
  ('a2000000-0000-0000-0000-000000000002', 'Historic',       '🏛️', 'culture'),
  ('a2000000-0000-0000-0000-000000000003', 'Cosmopolitan',   '🌍', 'culture'),
  ('a2000000-0000-0000-0000-000000000004', 'Bohemian',       '🎭', 'culture');

-- Pace
INSERT INTO public.vibe_tags (id, name, emoji, category) VALUES
  ('a3000000-0000-0000-0000-000000000001', 'Fast-Paced',       '⚡', 'pace'),
  ('a3000000-0000-0000-0000-000000000002', 'Quiet & Peaceful', '🧘', 'pace');

-- Values
INSERT INTO public.vibe_tags (id, name, emoji, category) VALUES
  ('a4000000-0000-0000-0000-000000000001', 'LGBTQ+ Friendly',  '🏳️‍🌈', 'values'),
  ('a4000000-0000-0000-0000-000000000002', 'Family Friendly',  '👨‍👩‍👧', 'values'),
  ('a4000000-0000-0000-0000-000000000003', 'Eco-Conscious',    '🌱', 'values');

-- Environment
INSERT INTO public.vibe_tags (id, name, emoji, category) VALUES
  ('a5000000-0000-0000-0000-000000000001', 'Startup Hub',     '🚀', 'environment'),
  ('a5000000-0000-0000-0000-000000000002', 'Digital Nomad',   '💻', 'environment'),
  ('a5000000-0000-0000-0000-000000000003', 'Student Friendly', '🎓', 'environment'),
  ('a5000000-0000-0000-0000-000000000004', 'Affordable',      '💰', 'environment');

-- ============================================================
-- CITY-VIBE MAPPINGS
-- strength: 0.3 (weak) to 1.0 (defining characteristic)
-- Each city gets 5-10 vibes that best describe it
-- ============================================================

-- Aliases for readability
-- lifestyle: walkable=01, nightlife=02, foodie=03, beach=04, outdoorsy=05, coffee=06, luxury=07
-- culture: arts=01, historic=02, cosmopolitan=03, bohemian=04
-- pace: fast=01, quiet=02
-- values: lgbtq=01, family=02, eco=03
-- environment: startup=01, nomad=02, student=03, affordable=04

-- San Francisco
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-francisco', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('san-francisco', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('san-francisco', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('san-francisco', 'a2000000-0000-0000-0000-000000000003', 0.85),  -- Cosmopolitan
  ('san-francisco', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('san-francisco', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('san-francisco', 'a5000000-0000-0000-0000-000000000001', 0.95);  -- Startup Hub

-- New York
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('new-york', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('new-york', 'a1000000-0000-0000-0000-000000000002', 0.95),  -- Nightlife
  ('new-york', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('new-york', 'a1000000-0000-0000-0000-000000000007', 0.85),  -- Luxury
  ('new-york', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Music
  ('new-york', 'a2000000-0000-0000-0000-000000000003', 0.95),  -- Cosmopolitan
  ('new-york', 'a3000000-0000-0000-0000-000000000001', 0.95),  -- Fast-Paced
  ('new-york', 'a4000000-0000-0000-0000-000000000001', 0.85);  -- LGBTQ+ Friendly

-- Austin
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('austin', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('austin', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('austin', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('austin', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Music
  ('austin', 'a2000000-0000-0000-0000-000000000004', 0.75),  -- Bohemian
  ('austin', 'a5000000-0000-0000-0000-000000000001', 0.85);  -- Startup Hub

-- Seattle
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('seattle', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('seattle', 'a1000000-0000-0000-0000-000000000005', 0.85),  -- Outdoorsy
  ('seattle', 'a1000000-0000-0000-0000-000000000006', 0.95),  -- Coffee Culture
  ('seattle', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('seattle', 'a4000000-0000-0000-0000-000000000003', 0.75),  -- Eco-Conscious
  ('seattle', 'a5000000-0000-0000-0000-000000000001', 0.85);  -- Startup Hub

-- Portland
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('portland', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('portland', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('portland', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('portland', 'a2000000-0000-0000-0000-000000000004', 0.85),  -- Bohemian
  ('portland', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('portland', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('portland', 'a5000000-0000-0000-0000-000000000004', 0.65);  -- Affordable

-- Denver
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('denver', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('denver', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('denver', 'a1000000-0000-0000-0000-000000000006', 0.75),  -- Coffee Culture
  ('denver', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('denver', 'a5000000-0000-0000-0000-000000000001', 0.70);  -- Startup Hub

-- Miami
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('miami', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('miami', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('miami', 'a1000000-0000-0000-0000-000000000004', 0.95),  -- Beach Life
  ('miami', 'a1000000-0000-0000-0000-000000000007', 0.85),  -- Luxury
  ('miami', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('miami', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('miami', 'a4000000-0000-0000-0000-000000000001', 0.75);  -- LGBTQ+ Friendly

-- Nashville
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('nashville', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('nashville', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('nashville', 'a2000000-0000-0000-0000-000000000001', 0.95),  -- Arts & Music
  ('nashville', 'a4000000-0000-0000-0000-000000000002', 0.75),  -- Family Friendly
  ('nashville', 'a5000000-0000-0000-0000-000000000004', 0.65);  -- Affordable

-- Charleston
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('charleston', 'a1000000-0000-0000-0000-000000000001', 0.75),  -- Walkable
  ('charleston', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('charleston', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('charleston', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('charleston', 'a3000000-0000-0000-0000-000000000002', 0.75);  -- Quiet & Peaceful

-- Chicago
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('chicago', 'a1000000-0000-0000-0000-000000000001', 0.75),  -- Walkable
  ('chicago', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('chicago', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('chicago', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('chicago', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('chicago', 'a4000000-0000-0000-0000-000000000002', 0.75);  -- Family Friendly

-- Los Angeles
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('los-angeles', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('los-angeles', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('los-angeles', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('los-angeles', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('los-angeles', 'a1000000-0000-0000-0000-000000000007', 0.80),  -- Luxury
  ('los-angeles', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('los-angeles', 'a2000000-0000-0000-0000-000000000003', 0.85),  -- Cosmopolitan
  ('los-angeles', 'a5000000-0000-0000-0000-000000000001', 0.75);  -- Startup Hub

-- Boston
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('boston', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('boston', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('boston', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('boston', 'a5000000-0000-0000-0000-000000000003', 0.90),  -- Student Friendly
  ('boston', 'a4000000-0000-0000-0000-000000000001', 0.70);  -- LGBTQ+ Friendly

-- Toronto
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('toronto', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('toronto', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Music
  ('toronto', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('toronto', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('toronto', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('toronto', 'a5000000-0000-0000-0000-000000000001', 0.75);  -- Startup Hub

-- Vancouver
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('vancouver', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('vancouver', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('vancouver', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('vancouver', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('vancouver', 'a4000000-0000-0000-0000-000000000003', 0.85),  -- Eco-Conscious
  ('vancouver', 'a5000000-0000-0000-0000-000000000002', 0.70);  -- Digital Nomad

-- Montreal
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('montreal', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('montreal', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('montreal', 'a1000000-0000-0000-0000-000000000006', 0.80),  -- Coffee Culture
  ('montreal', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Music
  ('montreal', 'a2000000-0000-0000-0000-000000000004', 0.80),  -- Bohemian
  ('montreal', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('montreal', 'a5000000-0000-0000-0000-000000000003', 0.85),  -- Student Friendly
  ('montreal', 'a5000000-0000-0000-0000-000000000004', 0.75);  -- Affordable

-- Mexico City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('mexico-city', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('mexico-city', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('mexico-city', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('mexico-city', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('mexico-city', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('mexico-city', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('mexico-city', 'a5000000-0000-0000-0000-000000000002', 0.85),  -- Digital Nomad
  ('mexico-city', 'a5000000-0000-0000-0000-000000000004', 0.85);  -- Affordable

-- Lisbon
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lisbon', 'a1000000-0000-0000-0000-000000000001', 0.75),  -- Walkable
  ('lisbon', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('lisbon', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('lisbon', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('lisbon', 'a2000000-0000-0000-0000-000000000002', 0.85),  -- Historic
  ('lisbon', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('lisbon', 'a5000000-0000-0000-0000-000000000004', 0.75);  -- Affordable

-- London
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('london', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('london', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('london', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('london', 'a1000000-0000-0000-0000-000000000007', 0.80),  -- Luxury
  ('london', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Music
  ('london', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('london', 'a2000000-0000-0000-0000-000000000003', 0.95),  -- Cosmopolitan
  ('london', 'a3000000-0000-0000-0000-000000000001', 0.85),  -- Fast-Paced
  ('london', 'a4000000-0000-0000-0000-000000000001', 0.80);  -- LGBTQ+ Friendly

-- Berlin
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('berlin', 'a1000000-0000-0000-0000-000000000002', 0.95),  -- Nightlife
  ('berlin', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('berlin', 'a2000000-0000-0000-0000-000000000001', 0.95),  -- Arts & Music
  ('berlin', 'a2000000-0000-0000-0000-000000000004', 0.90),  -- Bohemian
  ('berlin', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('berlin', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('berlin', 'a5000000-0000-0000-0000-000000000002', 0.80),  -- Digital Nomad
  ('berlin', 'a5000000-0000-0000-0000-000000000004', 0.70);  -- Affordable

-- Barcelona
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('barcelona', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('barcelona', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('barcelona', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('barcelona', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('barcelona', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('barcelona', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('barcelona', 'a5000000-0000-0000-0000-000000000002', 0.80);  -- Digital Nomad

-- Amsterdam
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('amsterdam', 'a1000000-0000-0000-0000-000000000001', 0.90),  -- Walkable
  ('amsterdam', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('amsterdam', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('amsterdam', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Music
  ('amsterdam', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('amsterdam', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('amsterdam', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('amsterdam', 'a5000000-0000-0000-0000-000000000002', 0.75);  -- Digital Nomad

-- Paris
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('paris', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('paris', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('paris', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('paris', 'a1000000-0000-0000-0000-000000000007', 0.90),  -- Luxury
  ('paris', 'a2000000-0000-0000-0000-000000000001', 0.95),  -- Arts & Music
  ('paris', 'a2000000-0000-0000-0000-000000000002', 0.95),  -- Historic
  ('paris', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('paris', 'a3000000-0000-0000-0000-000000000001', 0.75);  -- Fast-Paced

-- Prague
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('prague', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('prague', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('prague', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('prague', 'a2000000-0000-0000-0000-000000000004', 0.75),  -- Bohemian
  ('prague', 'a5000000-0000-0000-0000-000000000002', 0.75),  -- Digital Nomad
  ('prague', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student Friendly
  ('prague', 'a5000000-0000-0000-0000-000000000004', 0.80);  -- Affordable

-- Copenhagen
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('copenhagen', 'a1000000-0000-0000-0000-000000000001', 0.90),  -- Walkable
  ('copenhagen', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('copenhagen', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('copenhagen', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('copenhagen', 'a4000000-0000-0000-0000-000000000002', 0.85),  -- Family Friendly
  ('copenhagen', 'a4000000-0000-0000-0000-000000000003', 0.90);  -- Eco-Conscious

-- Stockholm
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('stockholm', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('stockholm', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('stockholm', 'a2000000-0000-0000-0000-000000000001', 0.75),  -- Arts & Music
  ('stockholm', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('stockholm', 'a4000000-0000-0000-0000-000000000003', 0.85),  -- Eco-Conscious
  ('stockholm', 'a5000000-0000-0000-0000-000000000001', 0.80);  -- Startup Hub

-- Dublin
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dublin', 'a1000000-0000-0000-0000-000000000001', 0.75),  -- Walkable
  ('dublin', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('dublin', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('dublin', 'a4000000-0000-0000-0000-000000000001', 0.75),  -- LGBTQ+ Friendly
  ('dublin', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('dublin', 'a5000000-0000-0000-0000-000000000003', 0.75);  -- Student Friendly

-- Tallinn
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tallinn', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('tallinn', 'a2000000-0000-0000-0000-000000000002', 0.85),  -- Historic
  ('tallinn', 'a3000000-0000-0000-0000-000000000002', 0.75),  -- Quiet & Peaceful
  ('tallinn', 'a5000000-0000-0000-0000-000000000001', 0.85),  -- Startup Hub
  ('tallinn', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('tallinn', 'a5000000-0000-0000-0000-000000000004', 0.75);  -- Affordable

-- Zurich
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('zurich', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('zurich', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('zurich', 'a1000000-0000-0000-0000-000000000007', 0.90),  -- Luxury
  ('zurich', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Peaceful
  ('zurich', 'a4000000-0000-0000-0000-000000000002', 0.80);  -- Family Friendly

-- Vienna
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('vienna', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('vienna', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('vienna', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Music
  ('vienna', 'a2000000-0000-0000-0000-000000000002', 0.95),  -- Historic
  ('vienna', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Peaceful
  ('vienna', 'a4000000-0000-0000-0000-000000000002', 0.85);  -- Family Friendly

-- Munich
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('munich', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('munich', 'a1000000-0000-0000-0000-000000000002', 0.75),  -- Nightlife
  ('munich', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('munich', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('munich', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('munich', 'a4000000-0000-0000-0000-000000000002', 0.85);  -- Family Friendly

-- Tokyo
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tokyo', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('tokyo', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('tokyo', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('tokyo', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('tokyo', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('tokyo', 'a3000000-0000-0000-0000-000000000001', 0.90);  -- Fast-Paced

-- Singapore
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('singapore', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('singapore', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('singapore', 'a1000000-0000-0000-0000-000000000007', 0.85),  -- Luxury
  ('singapore', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('singapore', 'a3000000-0000-0000-0000-000000000001', 0.85),  -- Fast-Paced
  ('singapore', 'a4000000-0000-0000-0000-000000000002', 0.85),  -- Family Friendly
  ('singapore', 'a5000000-0000-0000-0000-000000000001', 0.80);  -- Startup Hub

-- Bangkok
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bangkok', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('bangkok', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('bangkok', 'a2000000-0000-0000-0000-000000000002', 0.75),  -- Historic
  ('bangkok', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('bangkok', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('bangkok', 'a5000000-0000-0000-0000-000000000004', 0.90);  -- Affordable

-- Seoul
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('seoul', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('seoul', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('seoul', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('seoul', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('seoul', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('seoul', 'a5000000-0000-0000-0000-000000000001', 0.75);  -- Startup Hub

-- Taipei
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('taipei', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('taipei', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('taipei', 'a1000000-0000-0000-0000-000000000006', 0.80),  -- Coffee Culture
  ('taipei', 'a4000000-0000-0000-0000-000000000001', 0.75),  -- LGBTQ+ Friendly
  ('taipei', 'a5000000-0000-0000-0000-000000000002', 0.80),  -- Digital Nomad
  ('taipei', 'a5000000-0000-0000-0000-000000000004', 0.80);  -- Affordable

-- Hong Kong
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('hong-kong', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('hong-kong', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('hong-kong', 'a1000000-0000-0000-0000-000000000007', 0.85),  -- Luxury
  ('hong-kong', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('hong-kong', 'a3000000-0000-0000-0000-000000000001', 0.90);  -- Fast-Paced

-- Melbourne
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('melbourne', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('melbourne', 'a1000000-0000-0000-0000-000000000006', 0.95),  -- Coffee Culture
  ('melbourne', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('melbourne', 'a2000000-0000-0000-0000-000000000004', 0.80),  -- Bohemian
  ('melbourne', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('melbourne', 'a5000000-0000-0000-0000-000000000001', 0.70);  -- Startup Hub

-- Sydney
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('sydney', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('sydney', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('sydney', 'a2000000-0000-0000-0000-000000000003', 0.85),  -- Cosmopolitan
  ('sydney', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('sydney', 'a4000000-0000-0000-0000-000000000002', 0.75);  -- Family Friendly

-- Auckland
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('auckland', 'a1000000-0000-0000-0000-000000000004', 0.75),  -- Beach Life
  ('auckland', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('auckland', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Peaceful
  ('auckland', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('auckland', 'a4000000-0000-0000-0000-000000000003', 0.80);  -- Eco-Conscious

-- Buenos Aires
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('buenos-aires', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('buenos-aires', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('buenos-aires', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('buenos-aires', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('buenos-aires', 'a2000000-0000-0000-0000-000000000004', 0.80),  -- Bohemian
  ('buenos-aires', 'a5000000-0000-0000-0000-000000000002', 0.80),  -- Digital Nomad
  ('buenos-aires', 'a5000000-0000-0000-0000-000000000004', 0.85);  -- Affordable

-- Medellin
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('medellin', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('medellin', 'a1000000-0000-0000-0000-000000000005', 0.75),  -- Outdoorsy
  ('medellin', 'a1000000-0000-0000-0000-000000000006', 0.80),  -- Coffee Culture
  ('medellin', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('medellin', 'a5000000-0000-0000-0000-000000000004', 0.90);  -- Affordable

-- Sao Paulo
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('sao-paulo', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('sao-paulo', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('sao-paulo', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Music
  ('sao-paulo', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('sao-paulo', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('sao-paulo', 'a4000000-0000-0000-0000-000000000001', 0.75);  -- LGBTQ+ Friendly

-- Santiago
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('santiago', 'a1000000-0000-0000-0000-000000000003', 0.75),  -- Foodie
  ('santiago', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('santiago', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('santiago', 'a5000000-0000-0000-0000-000000000004', 0.70);  -- Affordable

-- Bogota
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bogota', 'a1000000-0000-0000-0000-000000000002', 0.75),  -- Nightlife
  ('bogota', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('bogota', 'a1000000-0000-0000-0000-000000000006', 0.80),  -- Coffee Culture
  ('bogota', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Music
  ('bogota', 'a5000000-0000-0000-0000-000000000002', 0.75),  -- Digital Nomad
  ('bogota', 'a5000000-0000-0000-0000-000000000004', 0.85);  -- Affordable

-- Dubai
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dubai', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('dubai', 'a1000000-0000-0000-0000-000000000004', 0.75),  -- Beach Life
  ('dubai', 'a1000000-0000-0000-0000-000000000007', 0.95),  -- Luxury
  ('dubai', 'a2000000-0000-0000-0000-000000000003', 0.85),  -- Cosmopolitan
  ('dubai', 'a3000000-0000-0000-0000-000000000001', 0.85),  -- Fast-Paced
  ('dubai', 'a5000000-0000-0000-0000-000000000002', 0.75);  -- Digital Nomad

-- Tel Aviv
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tel-aviv', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('tel-aviv', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('tel-aviv', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('tel-aviv', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('tel-aviv', 'a5000000-0000-0000-0000-000000000001', 0.90);  -- Startup Hub

-- Cape Town
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cape-town', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('cape-town', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('cape-town', 'a1000000-0000-0000-0000-000000000005', 0.85),  -- Outdoorsy
  ('cape-town', 'a5000000-0000-0000-0000-000000000002', 0.80),  -- Digital Nomad
  ('cape-town', 'a5000000-0000-0000-0000-000000000004', 0.75);  -- Affordable

-- Nairobi
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('nairobi', 'a1000000-0000-0000-0000-000000000005', 0.75),  -- Outdoorsy
  ('nairobi', 'a3000000-0000-0000-0000-000000000001', 0.70),  -- Fast-Paced
  ('nairobi', 'a5000000-0000-0000-0000-000000000001', 0.75),  -- Startup Hub
  ('nairobi', 'a5000000-0000-0000-0000-000000000002', 0.70),  -- Digital Nomad
  ('nairobi', 'a5000000-0000-0000-0000-000000000004', 0.80);  -- Affordable

-- Helsinki
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('helsinki', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('helsinki', 'a1000000-0000-0000-0000-000000000006', 0.85),  -- Coffee Culture
  ('helsinki', 'a3000000-0000-0000-0000-000000000002', 0.75),  -- Quiet & Peaceful
  ('helsinki', 'a4000000-0000-0000-0000-000000000002', 0.85),  -- Family Friendly
  ('helsinki', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('helsinki', 'a5000000-0000-0000-0000-000000000001', 0.75);  -- Startup Hub

-- Osaka
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('osaka', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('osaka', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('osaka', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('osaka', 'a3000000-0000-0000-0000-000000000001', 0.75),  -- Fast-Paced
  ('osaka', 'a4000000-0000-0000-0000-000000000002', 0.75);  -- Family Friendly

-- Kuala Lumpur
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kuala-lumpur', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('kuala-lumpur', 'a2000000-0000-0000-0000-000000000003', 0.75),  -- Cosmopolitan
  ('kuala-lumpur', 'a5000000-0000-0000-0000-000000000002', 0.80),  -- Digital Nomad
  ('kuala-lumpur', 'a5000000-0000-0000-0000-000000000004', 0.85);  -- Affordable

-- Warsaw
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('warsaw', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('warsaw', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('warsaw', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('warsaw', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student Friendly
  ('warsaw', 'a5000000-0000-0000-0000-000000000004', 0.80);  -- Affordable

-- Reykjavik
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('reykjavik', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('reykjavik', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('reykjavik', 'a3000000-0000-0000-0000-000000000002', 0.80),  -- Quiet & Peaceful
  ('reykjavik', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('reykjavik', 'a4000000-0000-0000-0000-000000000003', 0.90);  -- Eco-Conscious

-- Edinburgh
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('edinburgh', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('edinburgh', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Music
  ('edinburgh', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('edinburgh', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Peaceful
  ('edinburgh', 'a5000000-0000-0000-0000-000000000003', 0.80);  -- Student Friendly

-- Bali
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bali', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('bali', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('bali', 'a3000000-0000-0000-0000-000000000002', 0.75),  -- Quiet & Peaceful
  ('bali', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('bali', 'a5000000-0000-0000-0000-000000000002', 0.95),  -- Digital Nomad
  ('bali', 'a5000000-0000-0000-0000-000000000004', 0.90);  -- Affordable
