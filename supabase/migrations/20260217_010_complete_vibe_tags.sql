-- Migration: Complete vibe tag mappings for all curated cities
-- Generated for cities in curated_cities_data.json that were not
-- already mapped in 20260213_007_seed_vibe_tags.sql

BEGIN;

-- Algiers
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('algiers', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('algiers', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('algiers', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('algiers', 'a1000000-0000-0000-0000-000000000004', 0.50)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Cairo
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cairo', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('cairo', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('cairo', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('cairo', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('cairo', 'a2000000-0000-0000-0000-000000000001', 0.70)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Addis Ababa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('addis-ababa', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('addis-ababa', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('addis-ababa', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('addis-ababa', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('addis-ababa', 'a1000000-0000-0000-0000-000000000005', 0.50)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Accra
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('accra', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('accra', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('accra', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('accra', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('accra', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Casablanca
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('casablanca', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('casablanca', 'a2000000-0000-0000-0000-000000000003', 0.60),  -- Cosmopolitan
  ('casablanca', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('casablanca', 'a1000000-0000-0000-0000-000000000004', 0.50),  -- Beach Life
  ('casablanca', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Lagos
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lagos', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('lagos', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('lagos', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('lagos', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('lagos', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('lagos', 'a1000000-0000-0000-0000-000000000004', 0.40)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kigali
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kigali', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('kigali', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('kigali', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('kigali', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('kigali', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Dakar
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dakar', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('dakar', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('dakar', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('dakar', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('dakar', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Johannesburg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('johannesburg', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('johannesburg', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('johannesburg', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('johannesburg', 'a2000000-0000-0000-0000-000000000003', 0.60),  -- Cosmopolitan
  ('johannesburg', 'a5000000-0000-0000-0000-000000000004', 0.60)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Dar es Salaam
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dar-es-salaam', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('dar-es-salaam', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('dar-es-salaam', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('dar-es-salaam', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('dar-es-salaam', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tunis
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tunis', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('tunis', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('tunis', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('tunis', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('tunis', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kampala
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kampala', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('kampala', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('kampala', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('kampala', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Harare
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('harare', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('harare', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('harare', 'a3000000-0000-0000-0000-000000000002', 0.50),  -- Quiet & Relaxed
  ('harare', 'a2000000-0000-0000-0000-000000000001', 0.40)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Dhaka
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dhaka', 'a5000000-0000-0000-0000-000000000004', 1.00),  -- Affordable
  ('dhaka', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('dhaka', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('dhaka', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Beijing
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('beijing', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('beijing', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('beijing', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('beijing', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('beijing', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('beijing', 'a2000000-0000-0000-0000-000000000003', 0.60)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Chengdu
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('chengdu', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('chengdu', 'a1000000-0000-0000-0000-000000000006', 0.70),  -- Coffee Culture
  ('chengdu', 'a3000000-0000-0000-0000-000000000002', 0.60),  -- Quiet & Relaxed
  ('chengdu', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('chengdu', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('chengdu', 'a2000000-0000-0000-0000-000000000001', 0.50)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Guangzhou
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('guangzhou', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('guangzhou', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('guangzhou', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('guangzhou', 'a2000000-0000-0000-0000-000000000003', 0.50),  -- Cosmopolitan
  ('guangzhou', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Shanghai
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('shanghai', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('shanghai', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('shanghai', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('shanghai', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('shanghai', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('shanghai', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('shanghai', 'a1000000-0000-0000-0000-000000000007', 0.70),  -- Luxury
  ('shanghai', 'a1000000-0000-0000-0000-000000000001', 0.60)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Shenzhen
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('shenzhen', 'a5000000-0000-0000-0000-000000000001', 1.00),  -- Startup Hub
  ('shenzhen', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('shenzhen', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('shenzhen', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('shenzhen', 'a2000000-0000-0000-0000-000000000003', 0.50)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Ahmedabad
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('ahmedabad', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('ahmedabad', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('ahmedabad', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('ahmedabad', 'a3000000-0000-0000-0000-000000000001', 0.60)  -- Fast-Paced
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Bengaluru
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bengaluru', 'a5000000-0000-0000-0000-000000000001', 0.90),  -- Startup Hub
  ('bengaluru', 'a1000000-0000-0000-0000-000000000006', 0.70),  -- Coffee Culture
  ('bengaluru', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('bengaluru', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('bengaluru', 'a5000000-0000-0000-0000-000000000002', 0.60),  -- Digital Nomad Hub
  ('bengaluru', 'a4000000-0000-0000-0000-000000000001', 0.50)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Chennai
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('chennai', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('chennai', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('chennai', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('chennai', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('chennai', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('chennai', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Delhi
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('delhi', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('delhi', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('delhi', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('delhi', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('delhi', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('delhi', 'a5000000-0000-0000-0000-000000000001', 0.60)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Hyderabad
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('hyderabad', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('hyderabad', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('hyderabad', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('hyderabad', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('hyderabad', 'a2000000-0000-0000-0000-000000000001', 0.50)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kolkata
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kolkata', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('kolkata', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('kolkata', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('kolkata', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('kolkata', 'a1000000-0000-0000-0000-000000000001', 0.50)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Mumbai
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('mumbai', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('mumbai', 'a3000000-0000-0000-0000-000000000001', 0.90),  -- Fast-Paced
  ('mumbai', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('mumbai', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('mumbai', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('mumbai', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('mumbai', 'a1000000-0000-0000-0000-000000000004', 0.40)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Surat
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('surat', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('surat', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('surat', 'a3000000-0000-0000-0000-000000000001', 0.60),  -- Fast-Paced
  ('surat', 'a4000000-0000-0000-0000-000000000002', 0.60)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Jakarta
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('jakarta', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('jakarta', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('jakarta', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('jakarta', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('jakarta', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('jakarta', 'a2000000-0000-0000-0000-000000000003', 0.50)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Medan
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('medan', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('medan', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('medan', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('medan', 'a2000000-0000-0000-0000-000000000003', 0.50)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Baghdad
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('baghdad', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('baghdad', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('baghdad', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('baghdad', 'a2000000-0000-0000-0000-000000000001', 0.50)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Almaty
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('almaty', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('almaty', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('almaty', 'a1000000-0000-0000-0000-000000000006', 0.50),  -- Coffee Culture
  ('almaty', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('almaty', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Wellington
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('wellington', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('wellington', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('wellington', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('wellington', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('wellington', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('wellington', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('wellington', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('wellington', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Karachi
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('karachi', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('karachi', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('karachi', 'a1000000-0000-0000-0000-000000000004', 0.50),  -- Beach Life
  ('karachi', 'a1000000-0000-0000-0000-000000000003', 0.70)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Lahore
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lahore', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('lahore', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('lahore', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('lahore', 'a5000000-0000-0000-0000-000000000004', 0.80)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Manila
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('manila', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('manila', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('manila', 'a3000000-0000-0000-0000-000000000001', 0.70),  -- Fast-Paced
  ('manila', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('manila', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Riyadh
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('riyadh', 'a1000000-0000-0000-0000-000000000007', 0.80),  -- Luxury
  ('riyadh', 'a3000000-0000-0000-0000-000000000001', 0.70),  -- Fast-Paced
  ('riyadh', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('riyadh', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Busan
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('busan', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('busan', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('busan', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('busan', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('busan', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('busan', 'a1000000-0000-0000-0000-000000000001', 0.70)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Taichung
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('taichung', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('taichung', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('taichung', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('taichung', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('taichung', 'a3000000-0000-0000-0000-000000000002', 0.60),  -- Quiet & Relaxed
  ('taichung', 'a4000000-0000-0000-0000-000000000001', 0.60)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tashkent
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tashkent', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('tashkent', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('tashkent', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('tashkent', 'a2000000-0000-0000-0000-000000000001', 0.50),  -- Arts & Culture
  ('tashkent', 'a1000000-0000-0000-0000-000000000001', 0.50)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Ho Chi Minh City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('ho-chi-minh-city', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('ho-chi-minh-city', 'a5000000-0000-0000-0000-000000000002', 0.80),  -- Digital Nomad Hub
  ('ho-chi-minh-city', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('ho-chi-minh-city', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('ho-chi-minh-city', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('ho-chi-minh-city', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('ho-chi-minh-city', 'a1000000-0000-0000-0000-000000000006', 0.70)  -- Coffee Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- San José
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-jose-costa-rica', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('san-jose-costa-rica', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('san-jose-costa-rica', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('san-jose-costa-rica', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('san-jose-costa-rica', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- San Salvador
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-salvador', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('san-salvador', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('san-salvador', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('san-salvador', 'a5000000-0000-0000-0000-000000000002', 0.50)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Guatemala City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('guatemala-city', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('guatemala-city', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('guatemala-city', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('guatemala-city', 'a1000000-0000-0000-0000-000000000003', 0.50)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tegucigalpa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tegucigalpa', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('tegucigalpa', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('tegucigalpa', 'a2000000-0000-0000-0000-000000000002', 0.40),  -- Historic
  ('tegucigalpa', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Managua
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('managua', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('managua', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('managua', 'a3000000-0000-0000-0000-000000000002', 0.50),  -- Quiet & Relaxed
  ('managua', 'a1000000-0000-0000-0000-000000000004', 0.40)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Panama City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('panama-city', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('panama-city', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('panama-city', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('panama-city', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('panama-city', 'a1000000-0000-0000-0000-000000000007', 0.50)  -- Luxury
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tirana
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tirana', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('tirana', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('tirana', 'a5000000-0000-0000-0000-000000000002', 0.70),  -- Digital Nomad Hub
  ('tirana', 'a1000000-0000-0000-0000-000000000006', 0.60),  -- Coffee Culture
  ('tirana', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Graz
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('graz', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('graz', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('graz', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('graz', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('graz', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('graz', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('graz', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Baku
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('baku', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('baku', 'a1000000-0000-0000-0000-000000000007', 0.60),  -- Luxury
  ('baku', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('baku', 'a2000000-0000-0000-0000-000000000003', 0.50),  -- Cosmopolitan
  ('baku', 'a2000000-0000-0000-0000-000000000001', 0.50)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Minsk
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('minsk', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('minsk', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('minsk', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('minsk', 'a2000000-0000-0000-0000-000000000002', 0.50),  -- Historic
  ('minsk', 'a4000000-0000-0000-0000-000000000002', 0.60)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Antwerp
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('antwerp', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('antwerp', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('antwerp', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('antwerp', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('antwerp', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('antwerp', 'a1000000-0000-0000-0000-000000000007', 0.60)  -- Luxury
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Brussels
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('brussels', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('brussels', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('brussels', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('brussels', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('brussels', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('brussels', 'a2000000-0000-0000-0000-000000000002', 0.60)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Plovdiv
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('plovdiv', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('plovdiv', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('plovdiv', 'a2000000-0000-0000-0000-000000000004', 0.70),  -- Bohemian
  ('plovdiv', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('plovdiv', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('plovdiv', 'a5000000-0000-0000-0000-000000000002', 0.60)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Sofia
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('sofia', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('sofia', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('sofia', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('sofia', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('sofia', 'a5000000-0000-0000-0000-000000000002', 0.70),  -- Digital Nomad Hub
  ('sofia', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Varna
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('varna', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('varna', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('varna', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('varna', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('varna', 'a3000000-0000-0000-0000-000000000002', 0.60),  -- Quiet & Relaxed
  ('varna', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Zagreb
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('zagreb', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('zagreb', 'a1000000-0000-0000-0000-000000000006', 0.70),  -- Coffee Culture
  ('zagreb', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('zagreb', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('zagreb', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('zagreb', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('zagreb', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Lyon
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lyon', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('lyon', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('lyon', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('lyon', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('lyon', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('lyon', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Marseille
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('marseille', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('marseille', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('marseille', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('marseille', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('marseille', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('marseille', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Montpellier
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('montpellier', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student City
  ('montpellier', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('montpellier', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('montpellier', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('montpellier', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('montpellier', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Nantes
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('nantes', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('nantes', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('nantes', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('nantes', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('nantes', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('nantes', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tbilisi
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tbilisi', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('tbilisi', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('tbilisi', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad Hub
  ('tbilisi', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('tbilisi', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('tbilisi', 'a1000000-0000-0000-0000-000000000006', 0.60),  -- Coffee Culture
  ('tbilisi', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Bremen
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bremen', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('bremen', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('bremen', 'a1000000-0000-0000-0000-000000000006', 0.60),  -- Coffee Culture
  ('bremen', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('bremen', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Dortmund
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dortmund', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('dortmund', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('dortmund', 'a5000000-0000-0000-0000-000000000003', 0.50),  -- Student City
  ('dortmund', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('dortmund', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Dresden
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dresden', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('dresden', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('dresden', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('dresden', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('dresden', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('dresden', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Düsseldorf
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dusseldorf', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('dusseldorf', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('dusseldorf', 'a1000000-0000-0000-0000-000000000007', 0.60),  -- Luxury
  ('dusseldorf', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('dusseldorf', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('dusseldorf', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Frankfurt am Main
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('frankfurt-am-main', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('frankfurt-am-main', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('frankfurt-am-main', 'a3000000-0000-0000-0000-000000000001', 0.70),  -- Fast-Paced
  ('frankfurt-am-main', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('frankfurt-am-main', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('frankfurt-am-main', 'a2000000-0000-0000-0000-000000000001', 0.60)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Hamburg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('hamburg', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('hamburg', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('hamburg', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('hamburg', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('hamburg', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('hamburg', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('hamburg', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Leipzig
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('leipzig', 'a2000000-0000-0000-0000-000000000004', 0.90),  -- Bohemian
  ('leipzig', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('leipzig', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('leipzig', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('leipzig', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('leipzig', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Nuremberg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('nuremberg', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('nuremberg', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('nuremberg', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('nuremberg', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('nuremberg', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('nuremberg', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Stuttgart
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('stuttgart', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('stuttgart', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('stuttgart', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('stuttgart', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('stuttgart', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('stuttgart', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Athens
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('athens', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('athens', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('athens', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('athens', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('athens', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('athens', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('athens', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Budapest
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('budapest', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('budapest', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('budapest', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('budapest', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('budapest', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('budapest', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('budapest', 'a5000000-0000-0000-0000-000000000002', 0.70)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Bologna
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bologna', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('bologna', 'a5000000-0000-0000-0000-000000000003', 0.90),  -- Student City
  ('bologna', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('bologna', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('bologna', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('bologna', 'a2000000-0000-0000-0000-000000000001', 0.70)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Genoa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('genoa', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('genoa', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('genoa', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('genoa', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('genoa', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Milan
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('milan', 'a1000000-0000-0000-0000-000000000007', 0.90),  -- Luxury
  ('milan', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('milan', 'a2000000-0000-0000-0000-000000000003', 0.90),  -- Cosmopolitan
  ('milan', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('milan', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('milan', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('milan', 'a5000000-0000-0000-0000-000000000001', 0.60)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Naples
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('naples', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('naples', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('naples', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('naples', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('naples', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('naples', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Palermo
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('palermo', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('palermo', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('palermo', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('palermo', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('palermo', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('palermo', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Rome
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('rome', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('rome', 'a2000000-0000-0000-0000-000000000001', 1.00),  -- Arts & Culture
  ('rome', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('rome', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('rome', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('rome', 'a1000000-0000-0000-0000-000000000007', 0.50)  -- Luxury
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Turin
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('turin', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('turin', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('turin', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('turin', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('turin', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('turin', 'a1000000-0000-0000-0000-000000000001', 0.60)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Astana
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('astana', 'a2000000-0000-0000-0000-000000000001', 0.50),  -- Arts & Culture
  ('astana', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('astana', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('astana', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Riga
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('riga', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('riga', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('riga', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('riga', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('riga', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('riga', 'a5000000-0000-0000-0000-000000000002', 0.50)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kaunas
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kaunas', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('kaunas', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('kaunas', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('kaunas', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('kaunas', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Vilnius
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('vilnius', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('vilnius', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('vilnius', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('vilnius', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('vilnius', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('vilnius', 'a2000000-0000-0000-0000-000000000001', 0.60)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Luxembourg City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('luxembourg-city', 'a1000000-0000-0000-0000-000000000007', 0.80),  -- Luxury
  ('luxembourg-city', 'a4000000-0000-0000-0000-000000000002', 0.90),  -- Family Friendly
  ('luxembourg-city', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('luxembourg-city', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('luxembourg-city', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('luxembourg-city', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('luxembourg-city', 'a2000000-0000-0000-0000-000000000002', 0.60)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Monaco
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('monaco', 'a1000000-0000-0000-0000-000000000007', 1.00),  -- Luxury
  ('monaco', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('monaco', 'a4000000-0000-0000-0000-000000000002', 0.90),  -- Family Friendly
  ('monaco', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('monaco', 'a1000000-0000-0000-0000-000000000001', 0.70)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Rotterdam
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('rotterdam', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('rotterdam', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('rotterdam', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('rotterdam', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('rotterdam', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('rotterdam', 'a4000000-0000-0000-0000-000000000003', 0.60),  -- Eco-Conscious
  ('rotterdam', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- The Hague
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('the-hague', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('the-hague', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('the-hague', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('the-hague', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('the-hague', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('the-hague', 'a4000000-0000-0000-0000-000000000003', 0.70)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Skopje
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('skopje', 'a5000000-0000-0000-0000-000000000004', 0.90),  -- Affordable
  ('skopje', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('skopje', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('skopje', 'a5000000-0000-0000-0000-000000000002', 0.50)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Oslo
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('oslo', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('oslo', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('oslo', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('oslo', 'a4000000-0000-0000-0000-000000000002', 0.90),  -- Family Friendly
  ('oslo', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('oslo', 'a2000000-0000-0000-0000-000000000001', 0.70)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kraków
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('krakow', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('krakow', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('krakow', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('krakow', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('krakow', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('krakow', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('krakow', 'a1000000-0000-0000-0000-000000000001', 0.60)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Poznań
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('poznań', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('poznań', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('poznań', 'a5000000-0000-0000-0000-000000000003', 0.60),  -- Student City
  ('poznań', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('poznań', 'a4000000-0000-0000-0000-000000000002', 0.70)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Wrocław
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('wrocław', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('wrocław', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('wrocław', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('wrocław', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('wrocław', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('wrocław', 'a4000000-0000-0000-0000-000000000001', 0.50)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Porto
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('porto', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('porto', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('porto', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('porto', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('porto', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('porto', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('porto', 'a5000000-0000-0000-0000-000000000002', 0.70),  -- Digital Nomad Hub
  ('porto', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Bucharest
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bucharest', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('bucharest', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('bucharest', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('bucharest', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('bucharest', 'a5000000-0000-0000-0000-000000000002', 0.60),  -- Digital Nomad Hub
  ('bucharest', 'a2000000-0000-0000-0000-000000000001', 0.50)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Moscow
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('moscow', 'a2000000-0000-0000-0000-000000000001', 1.00),  -- Arts & Culture
  ('moscow', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('moscow', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('moscow', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('moscow', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('moscow', 'a1000000-0000-0000-0000-000000000001', 0.50)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Saint Petersburg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('saint-petersburg', 'a2000000-0000-0000-0000-000000000001', 1.00),  -- Arts & Culture
  ('saint-petersburg', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('saint-petersburg', 'a1000000-0000-0000-0000-000000000001', 0.50),  -- Walkable
  ('saint-petersburg', 'a2000000-0000-0000-0000-000000000003', 0.50),  -- Cosmopolitan
  ('saint-petersburg', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Belgrade
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('belgrade', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('belgrade', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('belgrade', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('belgrade', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('belgrade', 'a2000000-0000-0000-0000-000000000004', 0.60),  -- Bohemian
  ('belgrade', 'a5000000-0000-0000-0000-000000000002', 0.60)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Madrid
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('madrid', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('madrid', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('madrid', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('madrid', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('madrid', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('madrid', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('madrid', 'a5000000-0000-0000-0000-000000000001', 0.60)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Málaga
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('malaga', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('malaga', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('malaga', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('malaga', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('malaga', 'a5000000-0000-0000-0000-000000000002', 0.70),  -- Digital Nomad Hub
  ('malaga', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('malaga', 'a2000000-0000-0000-0000-000000000001', 0.60)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Seville
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('seville', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('seville', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('seville', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('seville', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('seville', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('seville', 'a5000000-0000-0000-0000-000000000004', 0.60)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Valencia
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('valencia', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('valencia', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('valencia', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('valencia', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('valencia', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('valencia', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('valencia', 'a4000000-0000-0000-0000-000000000003', 0.60),  -- Eco-Conscious
  ('valencia', 'a5000000-0000-0000-0000-000000000002', 0.60)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Zaragoza
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('zaragoza', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('zaragoza', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('zaragoza', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('zaragoza', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('zaragoza', 'a4000000-0000-0000-0000-000000000002', 0.70)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Gothenburg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('gothenburg', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('gothenburg', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('gothenburg', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('gothenburg', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('gothenburg', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('gothenburg', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('gothenburg', 'a1000000-0000-0000-0000-000000000006', 0.70)  -- Coffee Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Malmö
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('malmo', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('malmo', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('malmo', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('malmo', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('malmo', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('malmo', 'a5000000-0000-0000-0000-000000000003', 0.50)  -- Student City
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kyiv
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kyiv', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('kyiv', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('kyiv', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('kyiv', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('kyiv', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('kyiv', 'a1000000-0000-0000-0000-000000000003', 0.50)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Lviv
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lviv', 'a1000000-0000-0000-0000-000000000006', 0.90),  -- Coffee Culture
  ('lviv', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('lviv', 'a5000000-0000-0000-0000-000000000004', 0.90),  -- Affordable
  ('lviv', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('lviv', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('lviv', 'a2000000-0000-0000-0000-000000000004', 0.60),  -- Bohemian
  ('lviv', 'a5000000-0000-0000-0000-000000000002', 0.60)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Birmingham
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('birmingham', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('birmingham', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('birmingham', 'a2000000-0000-0000-0000-000000000003', 0.60),  -- Cosmopolitan
  ('birmingham', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('birmingham', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('birmingham', 'a5000000-0000-0000-0000-000000000003', 0.50)  -- Student City
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Glasgow
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('glasgow', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('glasgow', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('glasgow', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('glasgow', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('glasgow', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('glasgow', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('glasgow', 'a2000000-0000-0000-0000-000000000004', 0.60)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Manchester
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('manchester', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('manchester', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('manchester', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('manchester', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('manchester', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('manchester', 'a5000000-0000-0000-0000-000000000003', 0.60),  -- Student City
  ('manchester', 'a2000000-0000-0000-0000-000000000003', 0.60)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tehran
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tehran', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('tehran', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('tehran', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('tehran', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('tehran', 'a3000000-0000-0000-0000-000000000001', 0.60)  -- Fast-Paced
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Amman
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('amman', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('amman', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('amman', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('amman', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('amman', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Beirut
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('beirut', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('beirut', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('beirut', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('beirut', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('beirut', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('beirut', 'a1000000-0000-0000-0000-000000000004', 0.50)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Muscat
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('muscat', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('muscat', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('muscat', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('muscat', 'a1000000-0000-0000-0000-000000000007', 0.60),  -- Luxury
  ('muscat', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Relaxed
  ('muscat', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Doha
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('doha', 'a1000000-0000-0000-0000-000000000007', 0.90),  -- Luxury
  ('doha', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('doha', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('doha', 'a3000000-0000-0000-0000-000000000001', 0.60),  -- Fast-Paced
  ('doha', 'a1000000-0000-0000-0000-000000000004', 0.50)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Jeddah
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('jeddah', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('jeddah', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('jeddah', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('jeddah', 'a2000000-0000-0000-0000-000000000003', 0.50),  -- Cosmopolitan
  ('jeddah', 'a4000000-0000-0000-0000-000000000002', 0.70)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Istanbul
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('istanbul', 'a2000000-0000-0000-0000-000000000002', 1.00),  -- Historic
  ('istanbul', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('istanbul', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('istanbul', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('istanbul', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('istanbul', 'a1000000-0000-0000-0000-000000000001', 0.50),  -- Walkable
  ('istanbul', 'a5000000-0000-0000-0000-000000000002', 0.60)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Abu Dhabi
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('abu-dhabi', 'a1000000-0000-0000-0000-000000000007', 0.90),  -- Luxury
  ('abu-dhabi', 'a4000000-0000-0000-0000-000000000002', 0.90),  -- Family Friendly
  ('abu-dhabi', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('abu-dhabi', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('abu-dhabi', 'a3000000-0000-0000-0000-000000000001', 0.50)  -- Fast-Paced
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Calgary
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('calgary', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('calgary', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('calgary', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('calgary', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('calgary', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Edmonton
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('edmonton', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('edmonton', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('edmonton', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('edmonton', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('edmonton', 'a4000000-0000-0000-0000-000000000003', 0.60),  -- Eco-Conscious
  ('edmonton', 'a4000000-0000-0000-0000-000000000002', 0.60)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Halifax
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('halifax', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('halifax', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('halifax', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('halifax', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('halifax', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('halifax', 'a4000000-0000-0000-0000-000000000001', 0.70)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Ottawa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('ottawa', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('ottawa', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('ottawa', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('ottawa', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('ottawa', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('ottawa', 'a1000000-0000-0000-0000-000000000001', 0.60)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Quebec City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('quebec-city', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('quebec-city', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('quebec-city', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('quebec-city', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('quebec-city', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('quebec-city', 'a2000000-0000-0000-0000-000000000001', 0.60)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Victoria
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('victoria', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('victoria', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('victoria', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('victoria', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('victoria', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('victoria', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Relaxed
  ('victoria', 'a1000000-0000-0000-0000-000000000006', 0.60)  -- Coffee Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Winnipeg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('winnipeg', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('winnipeg', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('winnipeg', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('winnipeg', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('winnipeg', 'a4000000-0000-0000-0000-000000000002', 0.60)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Guadalajara
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('guadalajara', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('guadalajara', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('guadalajara', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('guadalajara', 'a4000000-0000-0000-0000-000000000001', 0.60),  -- LGBTQ+ Friendly
  ('guadalajara', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('guadalajara', 'a5000000-0000-0000-0000-000000000002', 0.60)  -- Digital Nomad Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Monterrey
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('monterrey', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('monterrey', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('monterrey', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('monterrey', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('monterrey', 'a3000000-0000-0000-0000-000000000001', 0.60)  -- Fast-Paced
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Puebla
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('puebla', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('puebla', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('puebla', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('puebla', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('puebla', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Albuquerque
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('albuquerque', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('albuquerque', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('albuquerque', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('albuquerque', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('albuquerque', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Anaheim
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('anaheim', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('anaheim', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('anaheim', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('anaheim', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('anaheim', 'a1000000-0000-0000-0000-000000000005', 0.50)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Atlanta
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('atlanta', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('atlanta', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('atlanta', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('atlanta', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('atlanta', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('atlanta', 'a1000000-0000-0000-0000-000000000002', 0.60)  -- Nightlife
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Baltimore
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('baltimore', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('baltimore', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('baltimore', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('baltimore', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('baltimore', 'a5000000-0000-0000-0000-000000000003', 0.60)  -- Student City
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Boise
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('boise', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('boise', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('boise', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('boise', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('boise', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Charlotte
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('charlotte', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('charlotte', 'a4000000-0000-0000-0000-000000000002', 0.50),  -- Family Friendly
  ('charlotte', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('charlotte', 'a1000000-0000-0000-0000-000000000005', 0.50),  -- Outdoorsy
  ('charlotte', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Cincinnati
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cincinnati', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('cincinnati', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('cincinnati', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('cincinnati', 'a1000000-0000-0000-0000-000000000001', 0.50),  -- Walkable
  ('cincinnati', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Cleveland
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cleveland', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('cleveland', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('cleveland', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('cleveland', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Colorado Springs
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('colorado-springs', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('colorado-springs', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('colorado-springs', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('colorado-springs', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Columbus
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('columbus', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('columbus', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('columbus', 'a4000000-0000-0000-0000-000000000001', 0.60),  -- LGBTQ+ Friendly
  ('columbus', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('columbus', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Dallas
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('dallas', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('dallas', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('dallas', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('dallas', 'a3000000-0000-0000-0000-000000000001', 0.70),  -- Fast-Paced
  ('dallas', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('dallas', 'a2000000-0000-0000-0000-000000000003', 0.50)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Detroit
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('detroit', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('detroit', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('detroit', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('detroit', 'a2000000-0000-0000-0000-000000000004', 0.60),  -- Bohemian
  ('detroit', 'a1000000-0000-0000-0000-000000000003', 0.50)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Durham
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('durham', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('durham', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('durham', 'a5000000-0000-0000-0000-000000000003', 0.70),  -- Student City
  ('durham', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('durham', 'a1000000-0000-0000-0000-000000000005', 0.50)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- El Paso
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('el-paso', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('el-paso', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('el-paso', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('el-paso', 'a2000000-0000-0000-0000-000000000002', 0.50),  -- Historic
  ('el-paso', 'a1000000-0000-0000-0000-000000000003', 0.50)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Fort Worth
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('fort-worth', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('fort-worth', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('fort-worth', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('fort-worth', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('fort-worth', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Fresno
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('fresno', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('fresno', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('fresno', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('fresno', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Honolulu
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('honolulu', 'a1000000-0000-0000-0000-000000000004', 1.00),  -- Beach Life
  ('honolulu', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('honolulu', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('honolulu', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('honolulu', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('honolulu', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('honolulu', 'a1000000-0000-0000-0000-000000000007', 0.60)  -- Luxury
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Houston
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('houston', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('houston', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('houston', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('houston', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('houston', 'a5000000-0000-0000-0000-000000000004', 0.60)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Indianapolis
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('indianapolis', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('indianapolis', 'a2000000-0000-0000-0000-000000000001', 0.50),  -- Arts & Culture
  ('indianapolis', 'a4000000-0000-0000-0000-000000000002', 0.50),  -- Family Friendly
  ('indianapolis', 'a1000000-0000-0000-0000-000000000003', 0.50)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Jacksonville
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('jacksonville', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('jacksonville', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('jacksonville', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('jacksonville', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Kansas City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kansas-city', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie Paradise
  ('kansas-city', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('kansas-city', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('kansas-city', 'a1000000-0000-0000-0000-000000000002', 0.50),  -- Nightlife
  ('kansas-city', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Las Vegas
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('las-vegas', 'a1000000-0000-0000-0000-000000000002', 1.00),  -- Nightlife
  ('las-vegas', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('las-vegas', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('las-vegas', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('las-vegas', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('las-vegas', 'a1000000-0000-0000-0000-000000000007', 0.60)  -- Luxury
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Long Beach
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('long-beach', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('long-beach', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('long-beach', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('long-beach', 'a1000000-0000-0000-0000-000000000006', 0.50),  -- Coffee Culture
  ('long-beach', 'a1000000-0000-0000-0000-000000000005', 0.60)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Louisville
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('louisville', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('louisville', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('louisville', 'a2000000-0000-0000-0000-000000000002', 0.50),  -- Historic
  ('louisville', 'a2000000-0000-0000-0000-000000000001', 0.50)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Madison
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('madison', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student City
  ('madison', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('madison', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('madison', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('madison', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('madison', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('madison', 'a4000000-0000-0000-0000-000000000002', 0.70)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Memphis
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('memphis', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('memphis', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('memphis', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('memphis', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('memphis', 'a1000000-0000-0000-0000-000000000002', 0.60)  -- Nightlife
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Mesa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('mesa', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('mesa', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('mesa', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('mesa', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Milwaukee
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('milwaukee', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('milwaukee', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('milwaukee', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('milwaukee', 'a1000000-0000-0000-0000-000000000005', 0.50),  -- Outdoorsy
  ('milwaukee', 'a1000000-0000-0000-0000-000000000001', 0.50)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Minneapolis
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('minneapolis', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('minneapolis', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('minneapolis', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('minneapolis', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('minneapolis', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('minneapolis', 'a4000000-0000-0000-0000-000000000003', 0.60),  -- Eco-Conscious
  ('minneapolis', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- New Orleans
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('new-orleans', 'a2000000-0000-0000-0000-000000000001', 1.00),  -- Arts & Culture
  ('new-orleans', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('new-orleans', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('new-orleans', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('new-orleans', 'a2000000-0000-0000-0000-000000000004', 0.80),  -- Bohemian
  ('new-orleans', 'a4000000-0000-0000-0000-000000000001', 0.70)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Oakland
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('oakland', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('oakland', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('oakland', 'a2000000-0000-0000-0000-000000000004', 0.70),  -- Bohemian
  ('oakland', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('oakland', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('oakland', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('oakland', 'a2000000-0000-0000-0000-000000000003', 0.60)  -- Cosmopolitan
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Oklahoma City
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('oklahoma-city', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('oklahoma-city', 'a1000000-0000-0000-0000-000000000005', 0.50),  -- Outdoorsy
  ('oklahoma-city', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('oklahoma-city', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Omaha
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('omaha', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('omaha', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('omaha', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('omaha', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Orlando
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('orlando', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('orlando', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('orlando', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('orlando', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('orlando', 'a4000000-0000-0000-0000-000000000001', 0.60)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Philadelphia
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('philadelphia', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('philadelphia', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('philadelphia', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('philadelphia', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('philadelphia', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('philadelphia', 'a5000000-0000-0000-0000-000000000003', 0.60),  -- Student City
  ('philadelphia', 'a5000000-0000-0000-0000-000000000001', 0.60)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Phoenix
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('phoenix', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('phoenix', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('phoenix', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('phoenix', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Pittsburgh
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('pittsburgh', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('pittsburgh', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('pittsburgh', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('pittsburgh', 'a5000000-0000-0000-0000-000000000003', 0.60),  -- Student City
  ('pittsburgh', 'a1000000-0000-0000-0000-000000000005', 0.50),  -- Outdoorsy
  ('pittsburgh', 'a1000000-0000-0000-0000-000000000001', 0.50)  -- Walkable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Raleigh
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('raleigh', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('raleigh', 'a5000000-0000-0000-0000-000000000003', 0.60),  -- Student City
  ('raleigh', 'a4000000-0000-0000-0000-000000000002', 0.60),  -- Family Friendly
  ('raleigh', 'a1000000-0000-0000-0000-000000000005', 0.50),  -- Outdoorsy
  ('raleigh', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Reno
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('reno', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('reno', 'a1000000-0000-0000-0000-000000000002', 0.50),  -- Nightlife
  ('reno', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('reno', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Richmond
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('richmond', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('richmond', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('richmond', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('richmond', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('richmond', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Sacramento
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('sacramento', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('sacramento', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('sacramento', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('sacramento', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- San Antonio
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-antonio', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('san-antonio', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('san-antonio', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('san-antonio', 'a4000000-0000-0000-0000-000000000002', 0.50)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- San Diego
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-diego', 'a1000000-0000-0000-0000-000000000004', 1.00),  -- Beach Life
  ('san-diego', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('san-diego', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('san-diego', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('san-diego', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('san-diego', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('san-diego', 'a4000000-0000-0000-0000-000000000002', 0.60)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- San Jose
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-jose', 'a5000000-0000-0000-0000-000000000001', 1.00),  -- Startup Hub
  ('san-jose', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('san-jose', 'a2000000-0000-0000-0000-000000000003', 0.60),  -- Cosmopolitan
  ('san-jose', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('san-jose', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- St. Louis
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('st-louis', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('st-louis', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('st-louis', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('st-louis', 'a2000000-0000-0000-0000-000000000002', 0.60)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- St. Petersburg
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('st-petersburg', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('st-petersburg', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('st-petersburg', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('st-petersburg', 'a1000000-0000-0000-0000-000000000001', 0.50),  -- Walkable
  ('st-petersburg', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('st-petersburg', 'a1000000-0000-0000-0000-000000000003', 0.60)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tampa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tampa', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('tampa', 'a1000000-0000-0000-0000-000000000003', 0.60),  -- Foodie Paradise
  ('tampa', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('tampa', 'a5000000-0000-0000-0000-000000000001', 0.50),  -- Startup Hub
  ('tampa', 'a1000000-0000-0000-0000-000000000002', 0.50)  -- Nightlife
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tucson
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tucson', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('tucson', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('tucson', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('tucson', 'a2000000-0000-0000-0000-000000000002', 0.50),  -- Historic
  ('tucson', 'a5000000-0000-0000-0000-000000000003', 0.50)  -- Student City
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Tulsa
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('tulsa', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('tulsa', 'a2000000-0000-0000-0000-000000000001', 0.50),  -- Arts & Culture
  ('tulsa', 'a5000000-0000-0000-0000-000000000002', 0.60),  -- Digital Nomad Hub
  ('tulsa', 'a1000000-0000-0000-0000-000000000005', 0.50)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Virginia Beach
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('virginia-beach', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('virginia-beach', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('virginia-beach', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('virginia-beach', 'a4000000-0000-0000-0000-000000000003', 0.60),  -- Eco-Conscious
  ('virginia-beach', 'a5000000-0000-0000-0000-000000000004', 0.50)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Washington
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('washington', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('washington', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('washington', 'a1000000-0000-0000-0000-000000000001', 0.70),  -- Walkable
  ('washington', 'a4000000-0000-0000-0000-000000000001', 0.90),  -- LGBTQ+ Friendly
  ('washington', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('washington', 'a5000000-0000-0000-0000-000000000001', 0.70),  -- Startup Hub
  ('washington', 'a1000000-0000-0000-0000-000000000003', 0.70)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Adelaide
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('adelaide', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('adelaide', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('adelaide', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('adelaide', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('adelaide', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('adelaide', 'a4000000-0000-0000-0000-000000000001', 0.70)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Brisbane
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('brisbane', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('brisbane', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('brisbane', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('brisbane', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('brisbane', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('brisbane', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Canberra
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('canberra', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('canberra', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('canberra', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('canberra', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('canberra', 'a3000000-0000-0000-0000-000000000002', 0.70)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Gold Coast
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('gold-coast', 'a1000000-0000-0000-0000-000000000004', 1.00),  -- Beach Life
  ('gold-coast', 'a1000000-0000-0000-0000-000000000005', 1.00),  -- Outdoorsy
  ('gold-coast', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('gold-coast', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('gold-coast', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Hobart
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('hobart', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('hobart', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie Paradise
  ('hobart', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('hobart', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('hobart', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('hobart', 'a3000000-0000-0000-0000-000000000002', 0.70)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Newcastle
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('newcastle', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('newcastle', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('newcastle', 'a5000000-0000-0000-0000-000000000004', 0.50),  -- Affordable
  ('newcastle', 'a4000000-0000-0000-0000-000000000003', 0.70),  -- Eco-Conscious
  ('newcastle', 'a4000000-0000-0000-0000-000000000002', 0.70),  -- Family Friendly
  ('newcastle', 'a2000000-0000-0000-0000-000000000004', 0.50)  -- Bohemian
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Perth
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('perth', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('perth', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('perth', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('perth', 'a4000000-0000-0000-0000-000000000002', 0.80),  -- Family Friendly
  ('perth', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('perth', 'a3000000-0000-0000-0000-000000000002', 0.60)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Córdoba
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cordoba', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student City
  ('cordoba', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('cordoba', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('cordoba', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('cordoba', 'a2000000-0000-0000-0000-000000000002', 0.60),  -- Historic
  ('cordoba', 'a2000000-0000-0000-0000-000000000001', 0.60)  -- Arts & Culture
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Rosario
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('rosario', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('rosario', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('rosario', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('rosario', 'a4000000-0000-0000-0000-000000000001', 0.70),  -- LGBTQ+ Friendly
  ('rosario', 'a1000000-0000-0000-0000-000000000004', 0.50)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Santa Cruz de la Sierra
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('santa-cruz-de-la-sierra', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('santa-cruz-de-la-sierra', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('santa-cruz-de-la-sierra', 'a3000000-0000-0000-0000-000000000002', 0.50),  -- Quiet & Relaxed
  ('santa-cruz-de-la-sierra', 'a1000000-0000-0000-0000-000000000003', 0.40)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Belo Horizonte
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('belo-horizonte', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('belo-horizonte', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('belo-horizonte', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('belo-horizonte', 'a2000000-0000-0000-0000-000000000001', 0.50),  -- Arts & Culture
  ('belo-horizonte', 'a1000000-0000-0000-0000-000000000005', 0.50)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Brasília
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('brasilia', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('brasilia', 'a1000000-0000-0000-0000-000000000001', 0.50),  -- Walkable
  ('brasilia', 'a4000000-0000-0000-0000-000000000002', 0.50),  -- Family Friendly
  ('brasilia', 'a4000000-0000-0000-0000-000000000003', 0.50)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Campinas
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('campinas', 'a5000000-0000-0000-0000-000000000001', 0.60),  -- Startup Hub
  ('campinas', 'a5000000-0000-0000-0000-000000000003', 0.60),  -- Student City
  ('campinas', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('campinas', 'a3000000-0000-0000-0000-000000000002', 0.50)  -- Quiet & Relaxed
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Curitiba
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('curitiba', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('curitiba', 'a1000000-0000-0000-0000-000000000001', 0.60),  -- Walkable
  ('curitiba', 'a4000000-0000-0000-0000-000000000002', 0.50),  -- Family Friendly
  ('curitiba', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('curitiba', 'a5000000-0000-0000-0000-000000000004', 0.60)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Fortaleza
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('fortaleza', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('fortaleza', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('fortaleza', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('fortaleza', 'a1000000-0000-0000-0000-000000000005', 0.70)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Manaus
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('manaus', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('manaus', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('manaus', 'a2000000-0000-0000-0000-000000000002', 0.50),  -- Historic
  ('manaus', 'a4000000-0000-0000-0000-000000000003', 0.50)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Porto Alegre
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('porto-alegre', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('porto-alegre', 'a1000000-0000-0000-0000-000000000002', 0.60),  -- Nightlife
  ('porto-alegre', 'a5000000-0000-0000-0000-000000000004', 0.60),  -- Affordable
  ('porto-alegre', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('porto-alegre', 'a4000000-0000-0000-0000-000000000001', 0.60)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Recife
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('recife', 'a1000000-0000-0000-0000-000000000004', 0.70),  -- Beach Life
  ('recife', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('recife', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('recife', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('recife', 'a5000000-0000-0000-0000-000000000001', 0.50)  -- Startup Hub
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Rio de Janeiro
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('rio-de-janeiro', 'a1000000-0000-0000-0000-000000000004', 1.00),  -- Beach Life
  ('rio-de-janeiro', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('rio-de-janeiro', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('rio-de-janeiro', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('rio-de-janeiro', 'a2000000-0000-0000-0000-000000000003', 0.70),  -- Cosmopolitan
  ('rio-de-janeiro', 'a4000000-0000-0000-0000-000000000001', 0.60)  -- LGBTQ+ Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Salvador
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('salvador', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Culture
  ('salvador', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('salvador', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('salvador', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('salvador', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('salvador', 'a1000000-0000-0000-0000-000000000003', 0.70)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Valparaíso
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('valparaiso', 'a2000000-0000-0000-0000-000000000004', 0.90),  -- Bohemian
  ('valparaiso', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Culture
  ('valparaiso', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('valparaiso', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('valparaiso', 'a2000000-0000-0000-0000-000000000002', 0.70),  -- Historic
  ('valparaiso', 'a5000000-0000-0000-0000-000000000004', 0.60)  -- Affordable
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Cali
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cali', 'a1000000-0000-0000-0000-000000000002', 0.90),  -- Nightlife
  ('cali', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('cali', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('cali', 'a1000000-0000-0000-0000-000000000003', 0.50),  -- Foodie Paradise
  ('cali', 'a1000000-0000-0000-0000-000000000005', 0.50)  -- Outdoorsy
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Guayaquil
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('guayaquil', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('guayaquil', 'a1000000-0000-0000-0000-000000000005', 0.50),  -- Outdoorsy
  ('guayaquil', 'a1000000-0000-0000-0000-000000000004', 0.50),  -- Beach Life
  ('guayaquil', 'a2000000-0000-0000-0000-000000000002', 0.50)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Quito
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('quito', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('quito', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('quito', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('quito', 'a2000000-0000-0000-0000-000000000001', 0.60),  -- Arts & Culture
  ('quito', 'a4000000-0000-0000-0000-000000000003', 0.60)  -- Eco-Conscious
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Asunción
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('asuncion', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('asuncion', 'a2000000-0000-0000-0000-000000000002', 0.50),  -- Historic
  ('asuncion', 'a3000000-0000-0000-0000-000000000002', 0.60),  -- Quiet & Relaxed
  ('asuncion', 'a1000000-0000-0000-0000-000000000003', 0.40)  -- Foodie Paradise
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Lima
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lima', 'a1000000-0000-0000-0000-000000000003', 1.00),  -- Foodie Paradise
  ('lima', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('lima', 'a2000000-0000-0000-0000-000000000001', 0.70),  -- Arts & Culture
  ('lima', 'a2000000-0000-0000-0000-000000000003', 0.60),  -- Cosmopolitan
  ('lima', 'a5000000-0000-0000-0000-000000000004', 0.70),  -- Affordable
  ('lima', 'a1000000-0000-0000-0000-000000000004', 0.50)  -- Beach Life
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Montevideo
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('montevideo', 'a4000000-0000-0000-0000-000000000001', 0.80),  -- LGBTQ+ Friendly
  ('montevideo', 'a1000000-0000-0000-0000-000000000005', 0.60),  -- Outdoorsy
  ('montevideo', 'a1000000-0000-0000-0000-000000000003', 0.70),  -- Foodie Paradise
  ('montevideo', 'a3000000-0000-0000-0000-000000000002', 0.60),  -- Quiet & Relaxed
  ('montevideo', 'a1000000-0000-0000-0000-000000000004', 0.60),  -- Beach Life
  ('montevideo', 'a4000000-0000-0000-0000-000000000003', 0.60),  -- Eco-Conscious
  ('montevideo', 'a4000000-0000-0000-0000-000000000002', 0.60)  -- Family Friendly
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

-- Caracas
INSERT INTO public.city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('caracas', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('caracas', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('caracas', 'a2000000-0000-0000-0000-000000000001', 0.50),  -- Arts & Culture
  ('caracas', 'a2000000-0000-0000-0000-000000000002', 0.40)  -- Historic
ON CONFLICT (city_id, vibe_tag_id) DO UPDATE SET strength = EXCLUDED.strength;

COMMIT;