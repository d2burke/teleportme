-- Recalibrate vibe tag strengths for existing cities to improve Compass heading results.
--
-- Root cause: Many cities are missing key vibe tags or have tags at incorrect strengths,
-- causing them to underperform in the blended scoring algorithm (30% category + 70% vibe tags).
--
-- Strategy: Add missing vibe tags and adjust strengths for cities that should rank
-- highly for specific compass headings but currently don't.

BEGIN;

-- ============================================================
-- Helper: Get vibe tag IDs as variables (for readability)
-- ============================================================
-- Affordable:       a5000000-0000-0000-0000-000000000004
-- Arts & Music:     a2000000-0000-0000-0000-000000000001
-- Beach Life:       a1000000-0000-0000-0000-000000000004
-- Bohemian:         a2000000-0000-0000-0000-000000000004
-- Coffee Culture:   a1000000-0000-0000-0000-000000000006
-- Cosmopolitan:     a2000000-0000-0000-0000-000000000003
-- Digital Nomad:    a5000000-0000-0000-0000-000000000002
-- Eco-Conscious:    a4000000-0000-0000-0000-000000000003
-- Family Friendly:  a4000000-0000-0000-0000-000000000002
-- Fast-Paced:       a3000000-0000-0000-0000-000000000001
-- Foodie:           a1000000-0000-0000-0000-000000000003
-- Historic:         a2000000-0000-0000-0000-000000000002
-- LGBTQ+ Friendly:  a4000000-0000-0000-0000-000000000001
-- Luxury:           a1000000-0000-0000-0000-000000000007
-- Nightlife:        a1000000-0000-0000-0000-000000000002
-- Outdoorsy:        a1000000-0000-0000-0000-000000000005
-- Quiet & Peaceful: a3000000-0000-0000-0000-000000000002
-- Startup Hub:      a5000000-0000-0000-0000-000000000001
-- Student Friendly: a5000000-0000-0000-0000-000000000003
-- Walkable:         a1000000-0000-0000-0000-000000000001


-- ============================================================
-- CLIMATE signal fixes (Beach Life, Outdoorsy)
-- ============================================================

-- Lisbon: boost Beach Life for Sunset Chaser (climate+culture)
UPDATE city_vibe_tags SET strength = 0.80
WHERE city_id = 'lisbon' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000004'; -- Beach Life

-- Chiang Mai: boost Outdoorsy for Nomad Soul (climate+cost)
UPDATE city_vibe_tags SET strength = 0.85
WHERE city_id = 'chiang-mai' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000005'; -- Outdoorsy

-- Austin: add Beach Life (Lake Travis/Barton Springs culture), add Outdoorsy for Sun & Hustle
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('austin', 'a1000000-0000-0000-0000-000000000005', 0.70) -- Outdoorsy
ON CONFLICT DO NOTHING;

-- Dubai: boost Beach Life for Sun & Hustle (climate+career)
UPDATE city_vibe_tags SET strength = 0.85
WHERE city_id = 'dubai' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000004'; -- Beach Life

-- Dubai: add Startup Hub for Sun & Hustle
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('dubai', 'a5000000-0000-0000-0000-000000000001', 0.80) -- Startup Hub
ON CONFLICT DO NOTHING;

-- Tel Aviv: add Outdoorsy for climate signal
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('tel-aviv', 'a1000000-0000-0000-0000-000000000005', 0.70) -- Outdoorsy
ON CONFLICT DO NOTHING;

-- Bangkok: add Beach Life (proximity to islands is part of the appeal)
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('bangkok', 'a1000000-0000-0000-0000-000000000004', 0.60) -- Beach Life
ON CONFLICT DO NOTHING;


-- ============================================================
-- SAFETY signal fixes (Family Friendly, LGBTQ+ Friendly)
-- ============================================================

-- Vienna: add LGBTQ+ Friendly (very progressive city)
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('vienna', 'a4000000-0000-0000-0000-000000000001', 0.80) -- LGBTQ+ Friendly
ON CONFLICT DO NOTHING;

-- Prague: add Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('prague', 'a4000000-0000-0000-0000-000000000002', 0.70) -- Family Friendly
ON CONFLICT DO NOTHING;

-- Osaka: add Family Friendly + LGBTQ+ Friendly (Japan is very safe/family oriented)
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('osaka', 'a4000000-0000-0000-0000-000000000002', 0.85), -- Family Friendly
('osaka', 'a4000000-0000-0000-0000-000000000001', 0.65) -- LGBTQ+ Friendly
ON CONFLICT DO NOTHING;

-- Helsinki: add Foodie (Nordic food renaissance)
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('helsinki', 'a1000000-0000-0000-0000-000000000003', 0.75) -- Foodie
ON CONFLICT DO NOTHING;

-- Taipei: add Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('taipei', 'a4000000-0000-0000-0000-000000000002', 0.80) -- Family Friendly
ON CONFLICT DO NOTHING;

-- Stockholm: add Nightlife + Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('stockholm', 'a1000000-0000-0000-0000-000000000002', 0.75), -- Nightlife
('stockholm', 'a4000000-0000-0000-0000-000000000002', 0.80) -- Family Friendly
ON CONFLICT DO NOTHING;

-- Amsterdam: add Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('amsterdam', 'a4000000-0000-0000-0000-000000000002', 0.70) -- Family Friendly
ON CONFLICT DO NOTHING;

-- Melbourne: add Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('melbourne', 'a4000000-0000-0000-0000-000000000002', 0.80), -- Family Friendly
('melbourne', 'a1000000-0000-0000-0000-000000000002', 0.80) -- Nightlife
ON CONFLICT DO NOTHING;

-- Copenhagen: add Nightlife
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('copenhagen', 'a1000000-0000-0000-0000-000000000002', 0.75) -- Nightlife
ON CONFLICT DO NOTHING;

-- Singapore: add LGBTQ+ Friendly (improving), Nightlife
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('singapore', 'a4000000-0000-0000-0000-000000000001', 0.65), -- LGBTQ+ Friendly
('singapore', 'a1000000-0000-0000-0000-000000000002', 0.80) -- Nightlife
ON CONFLICT DO NOTHING;

-- Zurich: add Startup Hub (crypto valley, fintech)
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('zurich', 'a5000000-0000-0000-0000-000000000001', 0.80), -- Startup Hub
('zurich', 'a4000000-0000-0000-0000-000000000001', 0.80) -- LGBTQ+ Friendly
ON CONFLICT DO NOTHING;


-- ============================================================
-- CAREER signal fixes (Startup Hub, Student Friendly)
-- ============================================================

-- London: add Startup Hub
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('london', 'a5000000-0000-0000-0000-000000000001', 0.85), -- Startup Hub
('london', 'a5000000-0000-0000-0000-000000000003', 0.80) -- Student Friendly
ON CONFLICT DO NOTHING;

-- Tokyo: add Startup Hub
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('tokyo', 'a5000000-0000-0000-0000-000000000001', 0.75), -- Startup Hub
('tokyo', 'a2000000-0000-0000-0000-000000000002', 0.85) -- Historic
ON CONFLICT DO NOTHING;

-- New York: add Startup Hub
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('new-york', 'a5000000-0000-0000-0000-000000000001', 0.90) -- Startup Hub
ON CONFLICT DO NOTHING;

-- Seoul: add Cosmopolitan, Student Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('seoul', 'a2000000-0000-0000-0000-000000000003', 0.85), -- Cosmopolitan
('seoul', 'a5000000-0000-0000-0000-000000000003', 0.80) -- Student Friendly
ON CONFLICT DO NOTHING;

-- Paris: add Startup Hub (Station F is world's largest startup campus)
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('paris', 'a5000000-0000-0000-0000-000000000001', 0.75) -- Startup Hub
ON CONFLICT DO NOTHING;

-- Milan: add Startup Hub, Cosmopolitan, Foodie, Fast-Paced
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('milan', 'a5000000-0000-0000-0000-000000000001', 0.70), -- Startup Hub
('milan', 'a1000000-0000-0000-0000-000000000003', 0.85), -- Foodie
('milan', 'a3000000-0000-0000-0000-000000000001', 0.85) -- Fast-Paced
ON CONFLICT DO NOTHING;

-- Hong Kong: add Startup Hub, Foodie, Cosmopolitan
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('hong-kong', 'a5000000-0000-0000-0000-000000000001', 0.80), -- Startup Hub
('hong-kong', 'a1000000-0000-0000-0000-000000000003', 0.90), -- Foodie
('hong-kong', 'a2000000-0000-0000-0000-000000000003', 0.90), -- Cosmopolitan
('hong-kong', 'a3000000-0000-0000-0000-000000000001', 0.90) -- Fast-Paced
ON CONFLICT DO NOTHING;

-- Shanghai: add Startup Hub, Nightlife, Cosmopolitan
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('shanghai', 'a5000000-0000-0000-0000-000000000001', 0.80), -- Startup Hub
('shanghai', 'a1000000-0000-0000-0000-000000000002', 0.85), -- Nightlife
('shanghai', 'a2000000-0000-0000-0000-000000000003', 0.85), -- Cosmopolitan
('shanghai', 'a3000000-0000-0000-0000-000000000001', 0.90) -- Fast-Paced
ON CONFLICT DO NOTHING;


-- ============================================================
-- CULTURE signal fixes (Arts & Music, Historic, Bohemian, Cosmopolitan)
-- ============================================================

-- Buenos Aires: boost Bohemian
UPDATE city_vibe_tags SET strength = 0.85
WHERE city_id = 'buenos-aires' AND vibe_tag_id = 'a2000000-0000-0000-0000-000000000004'; -- Bohemian

-- Mexico City: add Bohemian, boost Historic
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('mexico-city', 'a2000000-0000-0000-0000-000000000004', 0.80) -- Bohemian
ON CONFLICT DO NOTHING;


-- ============================================================
-- NATURE signal fixes (Outdoorsy, Beach Life, Eco-Conscious)
-- ============================================================

-- Queenstown: boost Outdoorsy, add Beach Life (lake beaches)
UPDATE city_vibe_tags SET strength = 0.95
WHERE city_id = 'queenstown' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000005'; -- Outdoorsy

-- Cape Town: boost Eco-Conscious
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('cape-town', 'a4000000-0000-0000-0000-000000000003', 0.80), -- Eco-Conscious
('cape-town', 'a1000000-0000-0000-0000-000000000002', 0.85) -- Nightlife
ON CONFLICT DO NOTHING;

-- Denver: add Eco-Conscious, boost Outdoorsy
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('denver', 'a5000000-0000-0000-0000-000000000001', 0.75) -- Startup Hub (tech scene)
ON CONFLICT DO NOTHING;

-- Vancouver: add Eco-Conscious
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('vancouver', 'a4000000-0000-0000-0000-000000000003', 0.85) -- Eco-Conscious
ON CONFLICT DO NOTHING;

-- Portland: boost Outdoorsy
UPDATE city_vibe_tags SET strength = 0.85
WHERE city_id = 'portland' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000005';

-- If Portland doesn't have Outdoorsy, add it
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('portland', 'a1000000-0000-0000-0000-000000000005', 0.85) -- Outdoorsy
ON CONFLICT DO NOTHING;


-- ============================================================
-- COST signal fixes (Affordable, Digital Nomad)
-- ============================================================

-- Kraków: boost Affordable (Poland is very cheap)
UPDATE city_vibe_tags SET strength = 0.85
WHERE city_id = 'krakow' AND vibe_tag_id = 'a5000000-0000-0000-0000-000000000004'; -- Affordable

-- Belgrade: boost Affordable + Digital Nomad
UPDATE city_vibe_tags SET strength = 0.85
WHERE city_id = 'belgrade' AND vibe_tag_id = 'a5000000-0000-0000-0000-000000000004'; -- Affordable
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('belgrade', 'a5000000-0000-0000-0000-000000000002', 0.75) -- Digital Nomad
ON CONFLICT DO NOTHING;

-- Budapest: boost Affordable
UPDATE city_vibe_tags SET strength = 0.80
WHERE city_id = 'budapest' AND vibe_tag_id = 'a5000000-0000-0000-0000-000000000004'; -- Affordable

-- Sofia: add Affordable + Digital Nomad + Nightlife
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('sofia', 'a5000000-0000-0000-0000-000000000004', 0.90), -- Affordable
('sofia', 'a5000000-0000-0000-0000-000000000002', 0.75), -- Digital Nomad
('sofia', 'a1000000-0000-0000-0000-000000000002', 0.70) -- Nightlife
ON CONFLICT DO NOTHING;

-- Bucharest: add Nightlife, Affordable, Digital Nomad
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('bucharest', 'a1000000-0000-0000-0000-000000000002', 0.75), -- Nightlife
('bucharest', 'a5000000-0000-0000-0000-000000000004', 0.85), -- Affordable
('bucharest', 'a5000000-0000-0000-0000-000000000002', 0.70) -- Digital Nomad
ON CONFLICT DO NOTHING;

-- Tallinn: add Digital Nomad, Startup Hub
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('tallinn', 'a5000000-0000-0000-0000-000000000002', 0.85), -- Digital Nomad
('tallinn', 'a5000000-0000-0000-0000-000000000004', 0.80), -- Affordable
('tallinn', 'a4000000-0000-0000-0000-000000000002', 0.75) -- Family Friendly
ON CONFLICT DO NOTHING;

-- Vilnius: add Affordable, Digital Nomad, Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('vilnius', 'a5000000-0000-0000-0000-000000000004', 0.85), -- Affordable
('vilnius', 'a5000000-0000-0000-0000-000000000002', 0.80), -- Digital Nomad
('vilnius', 'a4000000-0000-0000-0000-000000000002', 0.75), -- Family Friendly
('vilnius', 'a4000000-0000-0000-0000-000000000001', 0.70) -- LGBTQ+ Friendly
ON CONFLICT DO NOTHING;

-- Porto: add Affordable, Digital Nomad
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('porto', 'a5000000-0000-0000-0000-000000000004', 0.80), -- Affordable
('porto', 'a5000000-0000-0000-0000-000000000002', 0.80), -- Digital Nomad
('porto', 'a4000000-0000-0000-0000-000000000002', 0.75) -- Family Friendly
ON CONFLICT DO NOTHING;

-- Valencia: add Affordable, Digital Nomad, Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('valencia', 'a5000000-0000-0000-0000-000000000004', 0.80), -- Affordable
('valencia', 'a5000000-0000-0000-0000-000000000002', 0.80), -- Digital Nomad
('valencia', 'a4000000-0000-0000-0000-000000000002', 0.80) -- Family Friendly
ON CONFLICT DO NOTHING;


-- ============================================================
-- FOOD signal fixes (Foodie, Coffee Culture)
-- ============================================================

-- Hanoi: boost Foodie
UPDATE city_vibe_tags SET strength = 0.95
WHERE city_id = 'hanoi' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000003'; -- Foodie

-- Barcelona: boost Foodie for Late Night Foodie
UPDATE city_vibe_tags SET strength = 0.95
WHERE city_id = 'barcelona' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000003'; -- Foodie

-- Taipei: boost Foodie (night market capital)
UPDATE city_vibe_tags SET strength = 0.95
WHERE city_id = 'taipei' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000003'; -- Foodie

-- Naples: add Foodie + Coffee Culture
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('naples', 'a1000000-0000-0000-0000-000000000003', 0.95), -- Foodie
('naples', 'a1000000-0000-0000-0000-000000000006', 0.90) -- Coffee Culture
ON CONFLICT DO NOTHING;


-- ============================================================
-- NIGHTLIFE signal fixes (Nightlife, Fast-Paced)
-- ============================================================

-- Barcelona: boost Nightlife
UPDATE city_vibe_tags SET strength = 0.95
WHERE city_id = 'barcelona' AND vibe_tag_id = 'a1000000-0000-0000-0000-000000000002'; -- Nightlife

-- Buenos Aires: add Fast-Paced
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('buenos-aires', 'a3000000-0000-0000-0000-000000000001', 0.80) -- Fast-Paced
ON CONFLICT DO NOTHING;

-- Madrid: add Fast-Paced
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
('madrid', 'a3000000-0000-0000-0000-000000000001', 0.80) -- Fast-Paced
ON CONFLICT DO NOTHING;

COMMIT;
