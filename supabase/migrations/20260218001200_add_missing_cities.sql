-- Migration: Add 35 missing cities to the TeleportMe database
-- Includes city records, category scores, and vibe tags
-- All inserts use ON CONFLICT DO NOTHING for idempotency

BEGIN;

-- ============================================================================
-- 1. INSERT CITIES
-- ============================================================================

INSERT INTO cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES
  ('medellin', 'Medellín', 'Medellín, Colombia', 'Colombia', 'South America', 6.2579, -75.5899, 2500000, 58.0, 'Once notorious, now a vibrant city of innovation with perfect spring-like weather year-round, a thriving digital nomad scene, and affordable mountain living.', NULL),
  ('reykjavik', 'Reykjavík', 'Reykjavík, Iceland', 'Iceland', 'Europe', 64.1466, -21.9426, 130000, 66.0, 'The world''s northernmost capital offers pristine volcanic landscapes, incredible safety, a unique creative culture, and front-row seats to the Northern Lights.', NULL),
  ('florence', 'Florence', 'Florence, Italy', 'Italy', 'Europe', 43.7696, 11.2558, 380000, 62.0, 'The cradle of the Renaissance, where world-class art, architecture, and Tuscan cuisine converge in one of the most beautiful cities on Earth.', NULL),
  ('kyoto', 'Kyoto', 'Kyoto, Japan', 'Japan', 'Asia', 35.0116, 135.7681, 1500000, 68.0, 'Japan''s ancient imperial capital, home to thousands of temples, traditional tea houses, stunning gardens, and some of the finest cuisine in Asia.', NULL),
  ('granada', 'Granada', 'Granada, Spain', 'Spain', 'Europe', 37.1773, -3.5986, 230000, 55.0, 'A jewel of Andalusia crowned by the Alhambra palace, where Moorish history meets flamenco passion and the Sierra Nevada mountains rise in the backdrop.', NULL),
  ('split', 'Split', 'Split, Croatia', 'Croatia', 'Europe', 43.5081, 16.4402, 180000, 52.0, 'Croatia''s second city built around a Roman emperor''s palace, offering Adriatic coastline, vibrant nightlife, and island-hopping adventures.', NULL),
  ('sarajevo', 'Sarajevo', 'Sarajevo, Bosnia and Herzegovina', 'Bosnia and Herzegovina', 'Europe', 43.8563, 18.4131, 275000, 45.0, 'A deeply historic crossroads of East and West, nestled in a mountain valley, offering incredible affordability, warm hospitality, and a resilient spirit.', NULL),
  ('thessaloniki', 'Thessaloniki', 'Thessaloniki, Greece', 'Greece', 'Europe', 40.6401, 22.9444, 325000, 52.0, 'Greece''s cultural capital, a waterfront city bursting with ancient ruins, legendary street food, lively nightlife, and a youthful university energy.', NULL),
  ('canggu', 'Canggu', 'Canggu, Bali, Indonesia', 'Indonesia', 'Asia', -8.6478, 115.1385, 30000, NULL, 'Bali''s surf and digital nomad hotspot, where rice paddies meet trendy cafes, co-working spaces, and world-class sunsets at a fraction of Western prices.', NULL),
  ('bansko', 'Bansko', 'Bansko, Bulgaria', 'Bulgaria', 'Europe', 41.8375, 23.4883, 10000, NULL, 'A Bulgarian ski town reborn as Europe''s most affordable digital nomad hub, surrounded by Pirin Mountain wilderness and cozy mountain lodges.', NULL),
  ('cluj-napoca', 'Cluj-Napoca', 'Cluj-Napoca, Romania', 'Romania', 'Europe', 46.7712, 23.6236, 325000, 48.0, 'Romania''s unofficial second capital and tech hub, a vibrant university city with a growing startup ecosystem, rich Transylvanian heritage, and incredible value.', NULL),
  ('cuenca', 'Cuenca', 'Cuenca, Ecuador', 'Ecuador', 'South America', -2.9001, -79.0059, 600000, 42.0, 'A UNESCO World Heritage colonial city in the Ecuadorian highlands, beloved by expats for its eternal spring climate, low cost of living, and mountain charm.', NULL),
  ('san-cristobal-de-las-casas', 'San Cristóbal de las Casas', 'San Cristóbal de las Casas, Mexico', 'Mexico', 'North America', 16.7370, -92.6376, 210000, NULL, 'A bohemian highland town in Chiapas where indigenous Mayan culture, colonial architecture, and misty mountain jungles create an unforgettable atmosphere.', NULL),
  ('banff', 'Banff', 'Banff, Alberta, Canada', 'Canada', 'North America', 51.1784, -115.5708, 8000, NULL, 'A postcard-perfect Rocky Mountain town inside Canada''s first national park, offering world-class skiing, turquoise lakes, and wildlife encounters at every turn.', NULL),
  ('boulder', 'Boulder', 'Boulder, Colorado, USA', 'United States', 'North America', 40.0150, -105.2705, 105000, 65.0, 'A health-conscious university town nestled against the Flatirons, blending outdoor adventure culture, a thriving tech scene, and craft food and drink.', NULL),
  ('bergen', 'Bergen', 'Bergen, Norway', 'Norway', 'Europe', 60.3913, 5.3221, 285000, 62.0, 'Norway''s gateway to the fjords, a colorful Hanseatic wharf city where dramatic mountain scenery meets Scandinavian culture and world-class safety.', NULL),
  ('cairns', 'Cairns', 'Cairns, Queensland, Australia', 'Australia', 'Oceania', -16.9186, 145.7781, 155000, 50.0, 'Tropical North Queensland''s adventure capital, the jumping-off point for the Great Barrier Reef and Daintree Rainforest, with a laid-back coastal lifestyle.', NULL),
  ('townsville', 'Townsville', 'Townsville, Queensland, Australia', 'Australia', 'Oceania', -19.2590, 146.8169, 180000, 44.0, 'A sunny tropical city on Queensland''s coast offering reef access, affordable Australian living, and an emerging food and culture scene.', NULL),
  ('nosara', 'Nosara', 'Nosara, Costa Rica', 'Costa Rica', 'North America', 9.9772, -85.6528, 6000, NULL, 'A jungle-wrapped surf and yoga sanctuary on Costa Rica''s Pacific coast, where eco-conscious living, pristine beaches, and wildlife coexist in harmony.', NULL),
  ('puerto-viejo', 'Puerto Viejo', 'Puerto Viejo de Talamanca, Costa Rica', 'Costa Rica', 'North America', 9.6566, -82.7537, 7000, NULL, 'A laid-back Caribbean beach town with reggae rhythms, jungle hikes, affordable living, and a vibrant multicultural community.', NULL),
  ('san-sebastian', 'San Sebastián', 'San Sebastián, Spain', 'Spain', 'Europe', 43.3183, -1.9812, 190000, 60.0, 'The culinary capital of the Basque Country, boasting more Michelin stars per capita than anywhere on Earth, set on a stunning crescent bay.', NULL),
  ('lausanne', 'Lausanne', 'Lausanne, Switzerland', 'Switzerland', 'Europe', 46.5197, 6.6323, 140000, 72.0, 'The Olympic capital perched above Lake Geneva, offering Swiss precision, world-class healthcare, stunning Alpine panoramas, and an exceptional quality of life.', NULL),
  ('george-town', 'George Town', 'George Town, Penang, Malaysia', 'Malaysia', 'Asia', 5.4141, 100.3288, 710000, 48.0, 'Penang''s UNESCO-listed capital, a street food paradise where Chinese, Malay, Indian, and colonial influences blend into one of Asia''s most flavorful cities.', NULL),
  ('izmir', 'Izmir', 'Izmir, Turkey', 'Turkey', 'Asia', 38.4237, 27.1428, 4400000, 50.0, 'Turkey''s most progressive and livable city, a sun-soaked Aegean metropolis with legendary bazaars, ancient ruins, and a cosmopolitan seaside promenade.', NULL),
  ('freiburg', 'Freiburg', 'Freiburg im Breisgau, Germany', 'Germany', 'Europe', 47.9990, 7.8421, 230000, 60.0, 'Germany''s sunniest city and green capital, a charming university town at the edge of the Black Forest with world-leading sustainability and cycling culture.', NULL),
  ('ljubljana', 'Ljubljana', 'Ljubljana, Slovenia', 'Slovenia', 'Europe', 46.0569, 14.5058, 290000, 58.0, 'Europe''s greenest capital, a car-free old town along a willow-lined river, offering exceptional safety, a rising food scene, and easy access to Alps and coast.', NULL),
  ('salzburg', 'Salzburg', 'Salzburg, Austria', 'Austria', 'Europe', 47.8095, 13.0550, 155000, 64.0, 'Mozart''s birthplace and the setting of The Sound of Music, a baroque jewel framed by Alpine peaks with a world-renowned festival culture.', NULL),
  ('bratislava', 'Bratislava', 'Bratislava, Slovakia', 'Slovakia', 'Europe', 48.1486, 17.1077, 475000, 50.0, 'A compact, walkable capital on the Danube, offering surprisingly affordable Central European charm just an hour from Vienna.', NULL),
  ('innsbruck', 'Innsbruck', 'Innsbruck, Austria', 'Austria', 'Europe', 47.2692, 11.4041, 135000, 62.0, 'A university city surrounded by towering Alpine peaks, offering world-class skiing and hiking literally minutes from the city center.', NULL),
  ('las-palmas', 'Las Palmas', 'Las Palmas de Gran Canaria, Spain', 'Spain', 'Europe', 28.1235, -15.4363, 380000, 55.0, 'The largest city in the Canary Islands, a digital nomad favorite with year-round warm weather, Atlantic surf beaches, and a relaxed island pace.', NULL),
  ('ibiza-town', 'Ibiza Town', 'Ibiza Town, Spain', 'Spain', 'Europe', 38.9088, 1.4328, 50000, NULL, 'The legendary Mediterranean party island''s capital, where world-famous clubs meet a charming UNESCO-listed old town and turquoise cove beaches.', NULL),
  ('asheville', 'Asheville', 'Asheville, North Carolina, USA', 'United States', 'North America', 35.5951, -82.5515, 95000, 52.0, 'The craft beer capital of America, nestled in the Blue Ridge Mountains with a thriving arts scene, farm-to-table dining, and stunning Appalachian nature.', NULL),
  ('nelson', 'Nelson', 'Nelson, New Zealand', 'New Zealand', 'Oceania', -41.2706, 173.2840, 52000, NULL, 'New Zealand''s sunniest city at the top of the South Island, a gateway to three national parks with world-class wine, craft beer, and outdoor adventure.', NULL),
  ('pune', 'Pune', 'Pune, India', 'India', 'Asia', 18.5204, 73.8567, 7400000, 40.0, 'India''s second-largest IT hub and the Oxford of the East, offering a pleasant Deccan Plateau climate, rich cultural heritage, and incredible affordability.', NULL),
  ('bangalore', 'Bangalore', 'Bangalore (Bengaluru), India', 'India', 'Asia', 12.9716, 77.5946, 12300000, 44.0, 'India''s Silicon Valley, a massive tech metropolis with a pleasant year-round climate, booming startup ecosystem, vibrant nightlife, and unbeatable value.', NULL)
ON CONFLICT (id) DO NOTHING;


-- ============================================================================
-- 2. INSERT CITY SCORES (8 primary + bonus categories)
-- ============================================================================

-- Medellín
INSERT INTO city_scores (city_id, category, score) VALUES
  ('medellin', 'Cost of Living', 8.5),
  ('medellin', 'Environmental Quality', 8.0),
  ('medellin', 'Leisure & Culture', 7.0),
  ('medellin', 'Economy', 5.5),
  ('medellin', 'Safety', 5.0),
  ('medellin', 'Commute', 5.5),
  ('medellin', 'Healthcare', 6.5),
  ('medellin', 'Outdoors', 7.5),
  ('medellin', 'Housing', 8.0),
  ('medellin', 'Startups', 6.0),
  ('medellin', 'Internet Access', 6.5),
  ('medellin', 'Travel Connectivity', 5.5)
ON CONFLICT DO NOTHING;

-- Reykjavík
INSERT INTO city_scores (city_id, category, score) VALUES
  ('reykjavik', 'Cost of Living', 2.5),
  ('reykjavik', 'Environmental Quality', 9.0),
  ('reykjavik', 'Leisure & Culture', 7.0),
  ('reykjavik', 'Economy', 7.0),
  ('reykjavik', 'Safety', 9.5),
  ('reykjavik', 'Commute', 6.0),
  ('reykjavik', 'Healthcare', 8.5),
  ('reykjavik', 'Outdoors', 9.5),
  ('reykjavik', 'Housing', 3.0),
  ('reykjavik', 'Internet Access', 8.5),
  ('reykjavik', 'Tolerance', 9.0),
  ('reykjavik', 'Education', 7.5)
ON CONFLICT DO NOTHING;

-- Florence
INSERT INTO city_scores (city_id, category, score) VALUES
  ('florence', 'Cost of Living', 5.0),
  ('florence', 'Environmental Quality', 7.0),
  ('florence', 'Leisure & Culture', 9.5),
  ('florence', 'Economy', 5.5),
  ('florence', 'Safety', 7.5),
  ('florence', 'Commute', 6.0),
  ('florence', 'Healthcare', 7.0),
  ('florence', 'Outdoors', 7.0),
  ('florence', 'Travel Connectivity', 6.5),
  ('florence', 'Education', 7.0),
  ('florence', 'Tolerance', 7.0)
ON CONFLICT DO NOTHING;

-- Kyoto
INSERT INTO city_scores (city_id, category, score) VALUES
  ('kyoto', 'Cost of Living', 5.5),
  ('kyoto', 'Environmental Quality', 7.5),
  ('kyoto', 'Leisure & Culture', 9.0),
  ('kyoto', 'Economy', 6.0),
  ('kyoto', 'Safety', 9.0),
  ('kyoto', 'Commute', 7.5),
  ('kyoto', 'Healthcare', 8.5),
  ('kyoto', 'Outdoors', 7.5),
  ('kyoto', 'Education', 8.0),
  ('kyoto', 'Travel Connectivity', 7.5),
  ('kyoto', 'Tolerance', 6.5)
ON CONFLICT DO NOTHING;

-- Granada
INSERT INTO city_scores (city_id, category, score) VALUES
  ('granada', 'Cost of Living', 7.5),
  ('granada', 'Environmental Quality', 7.5),
  ('granada', 'Leisure & Culture', 8.5),
  ('granada', 'Economy', 4.5),
  ('granada', 'Safety', 7.5),
  ('granada', 'Commute', 5.0),
  ('granada', 'Healthcare', 7.0),
  ('granada', 'Outdoors', 8.0),
  ('granada', 'Education', 7.0),
  ('granada', 'Housing', 7.5),
  ('granada', 'Tolerance', 7.0)
ON CONFLICT DO NOTHING;

-- Split
INSERT INTO city_scores (city_id, category, score) VALUES
  ('split', 'Cost of Living', 6.5),
  ('split', 'Environmental Quality', 8.0),
  ('split', 'Leisure & Culture', 7.5),
  ('split', 'Economy', 5.0),
  ('split', 'Safety', 8.0),
  ('split', 'Commute', 5.0),
  ('split', 'Healthcare', 6.5),
  ('split', 'Outdoors', 8.5),
  ('split', 'Travel Connectivity', 6.0),
  ('split', 'Housing', 5.5)
ON CONFLICT DO NOTHING;

-- Sarajevo
INSERT INTO city_scores (city_id, category, score) VALUES
  ('sarajevo', 'Cost of Living', 8.5),
  ('sarajevo', 'Environmental Quality', 6.0),
  ('sarajevo', 'Leisure & Culture', 7.5),
  ('sarajevo', 'Economy', 4.0),
  ('sarajevo', 'Safety', 6.5),
  ('sarajevo', 'Commute', 5.0),
  ('sarajevo', 'Healthcare', 5.5),
  ('sarajevo', 'Outdoors', 7.0),
  ('sarajevo', 'Housing', 8.5),
  ('sarajevo', 'Internet Access', 5.5),
  ('sarajevo', 'Tolerance', 6.0)
ON CONFLICT DO NOTHING;

-- Thessaloniki
INSERT INTO city_scores (city_id, category, score) VALUES
  ('thessaloniki', 'Cost of Living', 7.0),
  ('thessaloniki', 'Environmental Quality', 7.0),
  ('thessaloniki', 'Leisure & Culture', 8.0),
  ('thessaloniki', 'Economy', 4.5),
  ('thessaloniki', 'Safety', 7.0),
  ('thessaloniki', 'Commute', 5.5),
  ('thessaloniki', 'Healthcare', 6.5),
  ('thessaloniki', 'Outdoors', 6.5),
  ('thessaloniki', 'Education', 7.0),
  ('thessaloniki', 'Housing', 7.0),
  ('thessaloniki', 'Tolerance', 6.0)
ON CONFLICT DO NOTHING;

-- Canggu
INSERT INTO city_scores (city_id, category, score) VALUES
  ('canggu', 'Cost of Living', 9.0),
  ('canggu', 'Environmental Quality', 7.5),
  ('canggu', 'Leisure & Culture', 6.5),
  ('canggu', 'Economy', 4.0),
  ('canggu', 'Safety', 6.0),
  ('canggu', 'Commute', 3.5),
  ('canggu', 'Healthcare', 4.5),
  ('canggu', 'Outdoors', 8.0),
  ('canggu', 'Internet Access', 5.5),
  ('canggu', 'Housing', 8.5)
ON CONFLICT DO NOTHING;

-- Bansko
INSERT INTO city_scores (city_id, category, score) VALUES
  ('bansko', 'Cost of Living', 9.0),
  ('bansko', 'Environmental Quality', 7.5),
  ('bansko', 'Leisure & Culture', 5.0),
  ('bansko', 'Economy', 4.0),
  ('bansko', 'Safety', 7.5),
  ('bansko', 'Commute', 3.5),
  ('bansko', 'Healthcare', 5.0),
  ('bansko', 'Outdoors', 8.5),
  ('bansko', 'Internet Access', 7.0),
  ('bansko', 'Housing', 9.0)
ON CONFLICT DO NOTHING;

-- Cluj-Napoca
INSERT INTO city_scores (city_id, category, score) VALUES
  ('cluj-napoca', 'Cost of Living', 8.0),
  ('cluj-napoca', 'Environmental Quality', 6.5),
  ('cluj-napoca', 'Leisure & Culture', 7.0),
  ('cluj-napoca', 'Economy', 6.5),
  ('cluj-napoca', 'Safety', 7.5),
  ('cluj-napoca', 'Commute', 5.5),
  ('cluj-napoca', 'Healthcare', 6.0),
  ('cluj-napoca', 'Outdoors', 6.5),
  ('cluj-napoca', 'Startups', 6.5),
  ('cluj-napoca', 'Education', 7.5),
  ('cluj-napoca', 'Internet Access', 8.5)
ON CONFLICT DO NOTHING;

-- Cuenca
INSERT INTO city_scores (city_id, category, score) VALUES
  ('cuenca', 'Cost of Living', 9.0),
  ('cuenca', 'Environmental Quality', 7.5),
  ('cuenca', 'Leisure & Culture', 6.5),
  ('cuenca', 'Economy', 4.0),
  ('cuenca', 'Safety', 5.5),
  ('cuenca', 'Commute', 4.5),
  ('cuenca', 'Healthcare', 5.5),
  ('cuenca', 'Outdoors', 7.5),
  ('cuenca', 'Housing', 9.0),
  ('cuenca', 'Internet Access', 5.0)
ON CONFLICT DO NOTHING;

-- San Cristóbal de las Casas
INSERT INTO city_scores (city_id, category, score) VALUES
  ('san-cristobal-de-las-casas', 'Cost of Living', 9.5),
  ('san-cristobal-de-las-casas', 'Environmental Quality', 7.0),
  ('san-cristobal-de-las-casas', 'Leisure & Culture', 7.0),
  ('san-cristobal-de-las-casas', 'Economy', 3.5),
  ('san-cristobal-de-las-casas', 'Safety', 5.0),
  ('san-cristobal-de-las-casas', 'Commute', 3.0),
  ('san-cristobal-de-las-casas', 'Healthcare', 4.5),
  ('san-cristobal-de-las-casas', 'Outdoors', 8.0),
  ('san-cristobal-de-las-casas', 'Housing', 9.5),
  ('san-cristobal-de-las-casas', 'Internet Access', 4.5)
ON CONFLICT DO NOTHING;

-- Banff
INSERT INTO city_scores (city_id, category, score) VALUES
  ('banff', 'Cost of Living', 3.0),
  ('banff', 'Environmental Quality', 9.5),
  ('banff', 'Leisure & Culture', 5.5),
  ('banff', 'Economy', 5.5),
  ('banff', 'Safety', 9.5),
  ('banff', 'Commute', 4.0),
  ('banff', 'Healthcare', 7.5),
  ('banff', 'Outdoors', 10.0),
  ('banff', 'Housing', 2.5),
  ('banff', 'Travel Connectivity', 4.0)
ON CONFLICT DO NOTHING;

-- Boulder
INSERT INTO city_scores (city_id, category, score) VALUES
  ('boulder', 'Cost of Living', 3.5),
  ('boulder', 'Environmental Quality', 8.5),
  ('boulder', 'Leisure & Culture', 7.0),
  ('boulder', 'Economy', 7.5),
  ('boulder', 'Safety', 8.0),
  ('boulder', 'Commute', 6.0),
  ('boulder', 'Healthcare', 8.0),
  ('boulder', 'Outdoors', 9.5),
  ('boulder', 'Startups', 7.5),
  ('boulder', 'Education', 8.5),
  ('boulder', 'Venture Capital', 7.0),
  ('boulder', 'Housing', 3.0)
ON CONFLICT DO NOTHING;

-- Bergen
INSERT INTO city_scores (city_id, category, score) VALUES
  ('bergen', 'Cost of Living', 2.5),
  ('bergen', 'Environmental Quality', 8.5),
  ('bergen', 'Leisure & Culture', 7.0),
  ('bergen', 'Economy', 7.0),
  ('bergen', 'Safety', 9.0),
  ('bergen', 'Commute', 6.5),
  ('bergen', 'Healthcare', 8.5),
  ('bergen', 'Outdoors', 9.5),
  ('bergen', 'Education', 7.5),
  ('bergen', 'Tolerance', 8.5),
  ('bergen', 'Housing', 3.0)
ON CONFLICT DO NOTHING;

-- Cairns
INSERT INTO city_scores (city_id, category, score) VALUES
  ('cairns', 'Cost of Living', 5.5),
  ('cairns', 'Environmental Quality', 8.5),
  ('cairns', 'Leisure & Culture', 6.0),
  ('cairns', 'Economy', 5.5),
  ('cairns', 'Safety', 7.5),
  ('cairns', 'Commute', 5.0),
  ('cairns', 'Healthcare', 7.0),
  ('cairns', 'Outdoors', 9.5),
  ('cairns', 'Travel Connectivity', 5.5),
  ('cairns', 'Housing', 6.0)
ON CONFLICT DO NOTHING;

-- Townsville
INSERT INTO city_scores (city_id, category, score) VALUES
  ('townsville', 'Cost of Living', 6.0),
  ('townsville', 'Environmental Quality', 7.5),
  ('townsville', 'Leisure & Culture', 5.0),
  ('townsville', 'Economy', 5.5),
  ('townsville', 'Safety', 7.0),
  ('townsville', 'Commute', 5.0),
  ('townsville', 'Healthcare', 6.5),
  ('townsville', 'Outdoors', 8.5),
  ('townsville', 'Housing', 7.0)
ON CONFLICT DO NOTHING;

-- Nosara
INSERT INTO city_scores (city_id, category, score) VALUES
  ('nosara', 'Cost of Living', 5.5),
  ('nosara', 'Environmental Quality', 9.0),
  ('nosara', 'Leisure & Culture', 5.0),
  ('nosara', 'Economy', 4.0),
  ('nosara', 'Safety', 7.0),
  ('nosara', 'Commute', 2.5),
  ('nosara', 'Healthcare', 4.0),
  ('nosara', 'Outdoors', 9.5),
  ('nosara', 'Housing', 4.5),
  ('nosara', 'Internet Access', 4.5)
ON CONFLICT DO NOTHING;

-- Puerto Viejo
INSERT INTO city_scores (city_id, category, score) VALUES
  ('puerto-viejo', 'Cost of Living', 7.0),
  ('puerto-viejo', 'Environmental Quality', 8.5),
  ('puerto-viejo', 'Leisure & Culture', 5.5),
  ('puerto-viejo', 'Economy', 3.5),
  ('puerto-viejo', 'Safety', 5.5),
  ('puerto-viejo', 'Commute', 2.5),
  ('puerto-viejo', 'Healthcare', 4.0),
  ('puerto-viejo', 'Outdoors', 9.0),
  ('puerto-viejo', 'Housing', 6.5),
  ('puerto-viejo', 'Internet Access', 4.0)
ON CONFLICT DO NOTHING;

-- San Sebastián
INSERT INTO city_scores (city_id, category, score) VALUES
  ('san-sebastian', 'Cost of Living', 4.0),
  ('san-sebastian', 'Environmental Quality', 8.0),
  ('san-sebastian', 'Leisure & Culture', 9.0),
  ('san-sebastian', 'Economy', 6.0),
  ('san-sebastian', 'Safety', 8.5),
  ('san-sebastian', 'Commute', 6.5),
  ('san-sebastian', 'Healthcare', 8.0),
  ('san-sebastian', 'Outdoors', 8.0),
  ('san-sebastian', 'Housing', 3.5),
  ('san-sebastian', 'Travel Connectivity', 6.0),
  ('san-sebastian', 'Tolerance', 8.0)
ON CONFLICT DO NOTHING;

-- Lausanne
INSERT INTO city_scores (city_id, category, score) VALUES
  ('lausanne', 'Cost of Living', 2.0),
  ('lausanne', 'Environmental Quality', 9.0),
  ('lausanne', 'Leisure & Culture', 7.5),
  ('lausanne', 'Economy', 7.5),
  ('lausanne', 'Safety', 9.5),
  ('lausanne', 'Commute', 7.0),
  ('lausanne', 'Healthcare', 9.5),
  ('lausanne', 'Outdoors', 8.5),
  ('lausanne', 'Education', 9.0),
  ('lausanne', 'Housing', 2.0),
  ('lausanne', 'Taxation', 5.0),
  ('lausanne', 'Business Freedom', 8.0)
ON CONFLICT DO NOTHING;

-- George Town
INSERT INTO city_scores (city_id, category, score) VALUES
  ('george-town', 'Cost of Living', 8.5),
  ('george-town', 'Environmental Quality', 6.5),
  ('george-town', 'Leisure & Culture', 7.5),
  ('george-town', 'Economy', 5.5),
  ('george-town', 'Safety', 6.5),
  ('george-town', 'Commute', 5.0),
  ('george-town', 'Healthcare', 6.5),
  ('george-town', 'Outdoors', 5.5),
  ('george-town', 'Housing', 8.0),
  ('george-town', 'Internet Access', 7.0)
ON CONFLICT DO NOTHING;

-- Izmir
INSERT INTO city_scores (city_id, category, score) VALUES
  ('izmir', 'Cost of Living', 8.0),
  ('izmir', 'Environmental Quality', 7.0),
  ('izmir', 'Leisure & Culture', 7.0),
  ('izmir', 'Economy', 5.5),
  ('izmir', 'Safety', 6.0),
  ('izmir', 'Commute', 6.0),
  ('izmir', 'Healthcare', 6.5),
  ('izmir', 'Outdoors', 7.0),
  ('izmir', 'Housing', 7.5),
  ('izmir', 'Travel Connectivity', 6.5),
  ('izmir', 'Tolerance', 6.5)
ON CONFLICT DO NOTHING;

-- Freiburg
INSERT INTO city_scores (city_id, category, score) VALUES
  ('freiburg', 'Cost of Living', 5.5),
  ('freiburg', 'Environmental Quality', 9.0),
  ('freiburg', 'Leisure & Culture', 7.0),
  ('freiburg', 'Economy', 6.5),
  ('freiburg', 'Safety', 8.5),
  ('freiburg', 'Commute', 7.0),
  ('freiburg', 'Healthcare', 8.5),
  ('freiburg', 'Outdoors', 9.0),
  ('freiburg', 'Education', 8.0),
  ('freiburg', 'Tolerance', 8.0),
  ('freiburg', 'Internet Access', 7.5)
ON CONFLICT DO NOTHING;

-- Ljubljana
INSERT INTO city_scores (city_id, category, score) VALUES
  ('ljubljana', 'Cost of Living', 6.5),
  ('ljubljana', 'Environmental Quality', 8.5),
  ('ljubljana', 'Leisure & Culture', 7.5),
  ('ljubljana', 'Economy', 6.0),
  ('ljubljana', 'Safety', 8.5),
  ('ljubljana', 'Commute', 6.5),
  ('ljubljana', 'Healthcare', 7.5),
  ('ljubljana', 'Outdoors', 8.0),
  ('ljubljana', 'Education', 7.0),
  ('ljubljana', 'Housing', 5.5),
  ('ljubljana', 'Tolerance', 7.0)
ON CONFLICT DO NOTHING;

-- Salzburg
INSERT INTO city_scores (city_id, category, score) VALUES
  ('salzburg', 'Cost of Living', 4.5),
  ('salzburg', 'Environmental Quality', 9.0),
  ('salzburg', 'Leisure & Culture', 8.5),
  ('salzburg', 'Economy', 6.5),
  ('salzburg', 'Safety', 9.0),
  ('salzburg', 'Commute', 6.5),
  ('salzburg', 'Healthcare', 8.5),
  ('salzburg', 'Outdoors', 9.0),
  ('salzburg', 'Travel Connectivity', 7.0),
  ('salzburg', 'Education', 7.5),
  ('salzburg', 'Housing', 4.0)
ON CONFLICT DO NOTHING;

-- Bratislava
INSERT INTO city_scores (city_id, category, score) VALUES
  ('bratislava', 'Cost of Living', 7.0),
  ('bratislava', 'Environmental Quality', 6.5),
  ('bratislava', 'Leisure & Culture', 6.5),
  ('bratislava', 'Economy', 6.5),
  ('bratislava', 'Safety', 7.5),
  ('bratislava', 'Commute', 6.5),
  ('bratislava', 'Healthcare', 7.0),
  ('bratislava', 'Outdoors', 6.0),
  ('bratislava', 'Housing', 6.0),
  ('bratislava', 'Business Freedom', 6.5),
  ('bratislava', 'Travel Connectivity', 7.5)
ON CONFLICT DO NOTHING;

-- Innsbruck
INSERT INTO city_scores (city_id, category, score) VALUES
  ('innsbruck', 'Cost of Living', 4.5),
  ('innsbruck', 'Environmental Quality', 9.5),
  ('innsbruck', 'Leisure & Culture', 7.0),
  ('innsbruck', 'Economy', 6.5),
  ('innsbruck', 'Safety', 9.0),
  ('innsbruck', 'Commute', 6.5),
  ('innsbruck', 'Healthcare', 8.5),
  ('innsbruck', 'Outdoors', 10.0),
  ('innsbruck', 'Education', 8.0),
  ('innsbruck', 'Housing', 3.5),
  ('innsbruck', 'Travel Connectivity', 6.5)
ON CONFLICT DO NOTHING;

-- Las Palmas
INSERT INTO city_scores (city_id, category, score) VALUES
  ('las-palmas', 'Cost of Living', 7.0),
  ('las-palmas', 'Environmental Quality', 8.5),
  ('las-palmas', 'Leisure & Culture', 7.0),
  ('las-palmas', 'Economy', 5.0),
  ('las-palmas', 'Safety', 7.5),
  ('las-palmas', 'Commute', 5.5),
  ('las-palmas', 'Healthcare', 7.0),
  ('las-palmas', 'Outdoors', 8.0),
  ('las-palmas', 'Internet Access', 7.5),
  ('las-palmas', 'Housing', 6.5)
ON CONFLICT DO NOTHING;

-- Ibiza Town
INSERT INTO city_scores (city_id, category, score) VALUES
  ('ibiza-town', 'Cost of Living', 4.0),
  ('ibiza-town', 'Environmental Quality', 8.0),
  ('ibiza-town', 'Leisure & Culture', 8.0),
  ('ibiza-town', 'Economy', 5.0),
  ('ibiza-town', 'Safety', 8.0),
  ('ibiza-town', 'Commute', 4.0),
  ('ibiza-town', 'Healthcare', 6.5),
  ('ibiza-town', 'Outdoors', 7.5),
  ('ibiza-town', 'Housing', 3.0),
  ('ibiza-town', 'Tolerance', 8.5)
ON CONFLICT DO NOTHING;

-- Asheville
INSERT INTO city_scores (city_id, category, score) VALUES
  ('asheville', 'Cost of Living', 5.5),
  ('asheville', 'Environmental Quality', 8.5),
  ('asheville', 'Leisure & Culture', 7.5),
  ('asheville', 'Economy', 5.5),
  ('asheville', 'Safety', 7.0),
  ('asheville', 'Commute', 5.0),
  ('asheville', 'Healthcare', 7.0),
  ('asheville', 'Outdoors', 9.0),
  ('asheville', 'Housing', 5.0),
  ('asheville', 'Tolerance', 7.5)
ON CONFLICT DO NOTHING;

-- Nelson
INSERT INTO city_scores (city_id, category, score) VALUES
  ('nelson', 'Cost of Living', 5.0),
  ('nelson', 'Environmental Quality', 9.5),
  ('nelson', 'Leisure & Culture', 6.5),
  ('nelson', 'Economy', 5.0),
  ('nelson', 'Safety', 9.0),
  ('nelson', 'Commute', 4.5),
  ('nelson', 'Healthcare', 7.5),
  ('nelson', 'Outdoors', 9.5),
  ('nelson', 'Housing', 4.5),
  ('nelson', 'Internet Access', 6.5)
ON CONFLICT DO NOTHING;

-- Pune
INSERT INTO city_scores (city_id, category, score) VALUES
  ('pune', 'Cost of Living', 9.0),
  ('pune', 'Environmental Quality', 5.0),
  ('pune', 'Leisure & Culture', 5.5),
  ('pune', 'Economy', 7.0),
  ('pune', 'Safety', 5.5),
  ('pune', 'Commute', 4.5),
  ('pune', 'Healthcare', 6.0),
  ('pune', 'Outdoors', 5.0),
  ('pune', 'Startups', 7.0),
  ('pune', 'Education', 8.0),
  ('pune', 'Housing', 8.5),
  ('pune', 'Internet Access', 6.0)
ON CONFLICT DO NOTHING;

-- Bangalore
INSERT INTO city_scores (city_id, category, score) VALUES
  ('bangalore', 'Cost of Living', 8.5),
  ('bangalore', 'Environmental Quality', 5.0),
  ('bangalore', 'Leisure & Culture', 6.0),
  ('bangalore', 'Economy', 7.5),
  ('bangalore', 'Safety', 5.5),
  ('bangalore', 'Commute', 3.5),
  ('bangalore', 'Healthcare', 6.5),
  ('bangalore', 'Outdoors', 5.0),
  ('bangalore', 'Startups', 8.5),
  ('bangalore', 'Venture Capital', 7.5),
  ('bangalore', 'Education', 7.5),
  ('bangalore', 'Internet Access', 6.5),
  ('bangalore', 'Housing', 8.0)
ON CONFLICT DO NOTHING;


-- ============================================================================
-- 3. INSERT CITY VIBE TAGS
-- ============================================================================

-- Medellín: Digital Nomad, Affordable, Outdoorsy, Coffee Culture
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('medellin', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('medellin', 'a5000000-0000-0000-0000-000000000004', 0.90),  -- Affordable
  ('medellin', 'a1000000-0000-0000-0000-000000000005', 0.70),  -- Outdoorsy
  ('medellin', 'a1000000-0000-0000-0000-000000000006', 0.85)   -- Coffee Culture
ON CONFLICT DO NOTHING;

-- Reykjavík: Outdoorsy, Eco-Conscious, Quiet & Peaceful, LGBTQ+ Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('reykjavik', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('reykjavik', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('reykjavik', 'a3000000-0000-0000-0000-000000000002', 0.85),  -- Quiet & Peaceful
  ('reykjavik', 'a4000000-0000-0000-0000-000000000001', 0.80)   -- LGBTQ+ Friendly
ON CONFLICT DO NOTHING;

-- Florence: Historic, Arts & Music, Foodie, Walkable
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('florence', 'a2000000-0000-0000-0000-000000000002', 0.95),  -- Historic
  ('florence', 'a2000000-0000-0000-0000-000000000001', 0.95),  -- Arts & Music
  ('florence', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('florence', 'a1000000-0000-0000-0000-000000000001', 0.85)   -- Walkable
ON CONFLICT DO NOTHING;

-- Kyoto: Historic, Quiet & Peaceful, Foodie, Eco-Conscious, Walkable
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('kyoto', 'a2000000-0000-0000-0000-000000000002', 0.95),  -- Historic
  ('kyoto', 'a3000000-0000-0000-0000-000000000002', 0.90),  -- Quiet & Peaceful
  ('kyoto', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('kyoto', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('kyoto', 'a1000000-0000-0000-0000-000000000001', 0.85)   -- Walkable
ON CONFLICT DO NOTHING;

-- Granada: Historic, Affordable, Arts & Music, Outdoorsy, Student Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('granada', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('granada', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('granada', 'a2000000-0000-0000-0000-000000000001', 0.80),  -- Arts & Music
  ('granada', 'a1000000-0000-0000-0000-000000000005', 0.75),  -- Outdoorsy
  ('granada', 'a5000000-0000-0000-0000-000000000003', 0.75)   -- Student Friendly
ON CONFLICT DO NOTHING;

-- Split: Beach Life, Historic, Nightlife, Outdoorsy
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('split', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('split', 'a2000000-0000-0000-0000-000000000002', 0.85),  -- Historic
  ('split', 'a1000000-0000-0000-0000-000000000002', 0.80),  -- Nightlife
  ('split', 'a1000000-0000-0000-0000-000000000005', 0.75)   -- Outdoorsy
ON CONFLICT DO NOTHING;

-- Sarajevo: Historic, Affordable, Foodie, Coffee Culture
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('sarajevo', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('sarajevo', 'a5000000-0000-0000-0000-000000000004', 0.90),  -- Affordable
  ('sarajevo', 'a1000000-0000-0000-0000-000000000003', 0.75),  -- Foodie
  ('sarajevo', 'a1000000-0000-0000-0000-000000000006', 0.80)   -- Coffee Culture
ON CONFLICT DO NOTHING;

-- Thessaloniki: Foodie, Nightlife, Historic, Student Friendly, Walkable
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('thessaloniki', 'a1000000-0000-0000-0000-000000000003', 0.90),  -- Foodie
  ('thessaloniki', 'a1000000-0000-0000-0000-000000000002', 0.85),  -- Nightlife
  ('thessaloniki', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('thessaloniki', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student Friendly
  ('thessaloniki', 'a1000000-0000-0000-0000-000000000001', 0.75)   -- Walkable
ON CONFLICT DO NOTHING;

-- Canggu: Digital Nomad, Beach Life, Affordable, Coffee Culture
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('canggu', 'a5000000-0000-0000-0000-000000000002', 0.95),  -- Digital Nomad
  ('canggu', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('canggu', 'a5000000-0000-0000-0000-000000000004', 0.90),  -- Affordable
  ('canggu', 'a1000000-0000-0000-0000-000000000006', 0.80)   -- Coffee Culture
ON CONFLICT DO NOTHING;

-- Bansko: Digital Nomad, Affordable, Outdoorsy, Quiet & Peaceful
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bansko', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('bansko', 'a5000000-0000-0000-0000-000000000004', 0.95),  -- Affordable
  ('bansko', 'a1000000-0000-0000-0000-000000000005', 0.85),  -- Outdoorsy
  ('bansko', 'a3000000-0000-0000-0000-000000000002', 0.75)   -- Quiet & Peaceful
ON CONFLICT DO NOTHING;

-- Cluj-Napoca: Startup Hub, Affordable, Student Friendly, Digital Nomad
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cluj-napoca', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('cluj-napoca', 'a5000000-0000-0000-0000-000000000004', 0.85),  -- Affordable
  ('cluj-napoca', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student Friendly
  ('cluj-napoca', 'a5000000-0000-0000-0000-000000000002', 0.75)   -- Digital Nomad
ON CONFLICT DO NOTHING;

-- Cuenca: Affordable, Historic, Quiet & Peaceful, Outdoorsy
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cuenca', 'a5000000-0000-0000-0000-000000000004', 0.95),  -- Affordable
  ('cuenca', 'a2000000-0000-0000-0000-000000000002', 0.80),  -- Historic
  ('cuenca', 'a3000000-0000-0000-0000-000000000002', 0.80),  -- Quiet & Peaceful
  ('cuenca', 'a1000000-0000-0000-0000-000000000005', 0.70)   -- Outdoorsy
ON CONFLICT DO NOTHING;

-- San Cristóbal de las Casas: Bohemian, Affordable, Outdoorsy, Coffee Culture, Historic
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-cristobal-de-las-casas', 'a2000000-0000-0000-0000-000000000004', 0.90),  -- Bohemian
  ('san-cristobal-de-las-casas', 'a5000000-0000-0000-0000-000000000004', 0.95),  -- Affordable
  ('san-cristobal-de-las-casas', 'a1000000-0000-0000-0000-000000000005', 0.75),  -- Outdoorsy
  ('san-cristobal-de-las-casas', 'a1000000-0000-0000-0000-000000000006', 0.80),  -- Coffee Culture
  ('san-cristobal-de-las-casas', 'a2000000-0000-0000-0000-000000000002', 0.75)   -- Historic
ON CONFLICT DO NOTHING;

-- Banff: Outdoorsy, Quiet & Peaceful, Eco-Conscious, Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('banff', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('banff', 'a3000000-0000-0000-0000-000000000002', 0.85),  -- Quiet & Peaceful
  ('banff', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('banff', 'a4000000-0000-0000-0000-000000000002', 0.75)   -- Family Friendly
ON CONFLICT DO NOTHING;

-- Boulder: Outdoorsy, Startup Hub, Eco-Conscious, Student Friendly, Coffee Culture
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('boulder', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('boulder', 'a5000000-0000-0000-0000-000000000001', 0.80),  -- Startup Hub
  ('boulder', 'a4000000-0000-0000-0000-000000000003', 0.85),  -- Eco-Conscious
  ('boulder', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student Friendly
  ('boulder', 'a1000000-0000-0000-0000-000000000006', 0.75)   -- Coffee Culture
ON CONFLICT DO NOTHING;

-- Bergen: Outdoorsy, Eco-Conscious, Quiet & Peaceful, Walkable
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bergen', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('bergen', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('bergen', 'a3000000-0000-0000-0000-000000000002', 0.75),  -- Quiet & Peaceful
  ('bergen', 'a1000000-0000-0000-0000-000000000001', 0.80)   -- Walkable
ON CONFLICT DO NOTHING;

-- Cairns: Outdoorsy, Beach Life, Eco-Conscious
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('cairns', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('cairns', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('cairns', 'a4000000-0000-0000-0000-000000000003', 0.75)   -- Eco-Conscious
ON CONFLICT DO NOTHING;

-- Townsville: Beach Life, Outdoorsy, Quiet & Peaceful, Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('townsville', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('townsville', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('townsville', 'a3000000-0000-0000-0000-000000000002', 0.70),  -- Quiet & Peaceful
  ('townsville', 'a4000000-0000-0000-0000-000000000002', 0.70)   -- Family Friendly
ON CONFLICT DO NOTHING;

-- Nosara: Beach Life, Eco-Conscious, Outdoorsy, Quiet & Peaceful, Bohemian
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('nosara', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('nosara', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('nosara', 'a1000000-0000-0000-0000-000000000005', 0.85),  -- Outdoorsy
  ('nosara', 'a3000000-0000-0000-0000-000000000002', 0.85),  -- Quiet & Peaceful
  ('nosara', 'a2000000-0000-0000-0000-000000000004', 0.75)   -- Bohemian
ON CONFLICT DO NOTHING;

-- Puerto Viejo: Beach Life, Affordable, Outdoorsy, Bohemian
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('puerto-viejo', 'a1000000-0000-0000-0000-000000000004', 0.90),  -- Beach Life
  ('puerto-viejo', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('puerto-viejo', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('puerto-viejo', 'a2000000-0000-0000-0000-000000000004', 0.80)   -- Bohemian
ON CONFLICT DO NOTHING;

-- San Sebastián: Foodie, Beach Life, Cosmopolitan, Walkable, Arts & Music
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('san-sebastian', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('san-sebastian', 'a1000000-0000-0000-0000-000000000004', 0.80),  -- Beach Life
  ('san-sebastian', 'a2000000-0000-0000-0000-000000000003', 0.80),  -- Cosmopolitan
  ('san-sebastian', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('san-sebastian', 'a2000000-0000-0000-0000-000000000001', 0.70)   -- Arts & Music
ON CONFLICT DO NOTHING;

-- Lausanne: Luxury, Outdoorsy, Eco-Conscious, Walkable, Family Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('lausanne', 'a1000000-0000-0000-0000-000000000007', 0.85),  -- Luxury
  ('lausanne', 'a1000000-0000-0000-0000-000000000005', 0.80),  -- Outdoorsy
  ('lausanne', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('lausanne', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('lausanne', 'a4000000-0000-0000-0000-000000000002', 0.75)   -- Family Friendly
ON CONFLICT DO NOTHING;

-- George Town: Foodie, Historic, Affordable, Cosmopolitan
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('george-town', 'a1000000-0000-0000-0000-000000000003', 0.95),  -- Foodie
  ('george-town', 'a2000000-0000-0000-0000-000000000002', 0.85),  -- Historic
  ('george-town', 'a5000000-0000-0000-0000-000000000004', 0.85),  -- Affordable
  ('george-town', 'a2000000-0000-0000-0000-000000000003', 0.75)   -- Cosmopolitan
ON CONFLICT DO NOTHING;

-- Izmir: Foodie, Affordable, Cosmopolitan, Historic, Beach Life
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('izmir', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('izmir', 'a5000000-0000-0000-0000-000000000004', 0.80),  -- Affordable
  ('izmir', 'a2000000-0000-0000-0000-000000000003', 0.75),  -- Cosmopolitan
  ('izmir', 'a2000000-0000-0000-0000-000000000002', 0.75),  -- Historic
  ('izmir', 'a1000000-0000-0000-0000-000000000004', 0.70)   -- Beach Life
ON CONFLICT DO NOTHING;

-- Freiburg: Eco-Conscious, Outdoorsy, Student Friendly, Walkable, Quiet & Peaceful
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('freiburg', 'a4000000-0000-0000-0000-000000000003', 0.95),  -- Eco-Conscious
  ('freiburg', 'a1000000-0000-0000-0000-000000000005', 0.85),  -- Outdoorsy
  ('freiburg', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student Friendly
  ('freiburg', 'a1000000-0000-0000-0000-000000000001', 0.85),  -- Walkable
  ('freiburg', 'a3000000-0000-0000-0000-000000000002', 0.70)   -- Quiet & Peaceful
ON CONFLICT DO NOTHING;

-- Ljubljana: Eco-Conscious, Walkable, Foodie, Quiet & Peaceful
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('ljubljana', 'a4000000-0000-0000-0000-000000000003', 0.90),  -- Eco-Conscious
  ('ljubljana', 'a1000000-0000-0000-0000-000000000001', 0.90),  -- Walkable
  ('ljubljana', 'a1000000-0000-0000-0000-000000000003', 0.80),  -- Foodie
  ('ljubljana', 'a3000000-0000-0000-0000-000000000002', 0.75)   -- Quiet & Peaceful
ON CONFLICT DO NOTHING;

-- Salzburg: Historic, Arts & Music, Outdoorsy, Luxury, Walkable
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('salzburg', 'a2000000-0000-0000-0000-000000000002', 0.90),  -- Historic
  ('salzburg', 'a2000000-0000-0000-0000-000000000001', 0.90),  -- Arts & Music
  ('salzburg', 'a1000000-0000-0000-0000-000000000005', 0.85),  -- Outdoorsy
  ('salzburg', 'a1000000-0000-0000-0000-000000000007', 0.75),  -- Luxury
  ('salzburg', 'a1000000-0000-0000-0000-000000000001', 0.80)   -- Walkable
ON CONFLICT DO NOTHING;

-- Bratislava: Affordable, Historic, Walkable, Nightlife
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bratislava', 'a5000000-0000-0000-0000-000000000004', 0.75),  -- Affordable
  ('bratislava', 'a2000000-0000-0000-0000-000000000002', 0.75),  -- Historic
  ('bratislava', 'a1000000-0000-0000-0000-000000000001', 0.80),  -- Walkable
  ('bratislava', 'a1000000-0000-0000-0000-000000000002', 0.70)   -- Nightlife
ON CONFLICT DO NOTHING;

-- Innsbruck: Outdoorsy, Eco-Conscious, Student Friendly, Historic
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('innsbruck', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('innsbruck', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('innsbruck', 'a5000000-0000-0000-0000-000000000003', 0.80),  -- Student Friendly
  ('innsbruck', 'a2000000-0000-0000-0000-000000000002', 0.75)   -- Historic
ON CONFLICT DO NOTHING;

-- Las Palmas: Digital Nomad, Beach Life, Affordable, Outdoorsy, Coffee Culture
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('las-palmas', 'a5000000-0000-0000-0000-000000000002', 0.90),  -- Digital Nomad
  ('las-palmas', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('las-palmas', 'a5000000-0000-0000-0000-000000000004', 0.75),  -- Affordable
  ('las-palmas', 'a1000000-0000-0000-0000-000000000005', 0.75),  -- Outdoorsy
  ('las-palmas', 'a1000000-0000-0000-0000-000000000006', 0.70)   -- Coffee Culture
ON CONFLICT DO NOTHING;

-- Ibiza Town: Nightlife, Beach Life, LGBTQ+ Friendly, Luxury
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('ibiza-town', 'a1000000-0000-0000-0000-000000000002', 0.95),  -- Nightlife
  ('ibiza-town', 'a1000000-0000-0000-0000-000000000004', 0.85),  -- Beach Life
  ('ibiza-town', 'a4000000-0000-0000-0000-000000000001', 0.85),  -- LGBTQ+ Friendly
  ('ibiza-town', 'a1000000-0000-0000-0000-000000000007', 0.80)   -- Luxury
ON CONFLICT DO NOTHING;

-- Asheville: Arts & Music, Foodie, Outdoorsy, Bohemian, LGBTQ+ Friendly
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('asheville', 'a2000000-0000-0000-0000-000000000001', 0.85),  -- Arts & Music
  ('asheville', 'a1000000-0000-0000-0000-000000000003', 0.85),  -- Foodie
  ('asheville', 'a1000000-0000-0000-0000-000000000005', 0.90),  -- Outdoorsy
  ('asheville', 'a2000000-0000-0000-0000-000000000004', 0.80),  -- Bohemian
  ('asheville', 'a4000000-0000-0000-0000-000000000001', 0.75)   -- LGBTQ+ Friendly
ON CONFLICT DO NOTHING;

-- Nelson: Outdoorsy, Eco-Conscious, Quiet & Peaceful, Foodie
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('nelson', 'a1000000-0000-0000-0000-000000000005', 0.95),  -- Outdoorsy
  ('nelson', 'a4000000-0000-0000-0000-000000000003', 0.80),  -- Eco-Conscious
  ('nelson', 'a3000000-0000-0000-0000-000000000002', 0.80),  -- Quiet & Peaceful
  ('nelson', 'a1000000-0000-0000-0000-000000000003', 0.75)   -- Foodie
ON CONFLICT DO NOTHING;

-- Pune: Affordable, Startup Hub, Student Friendly, Fast-Paced
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('pune', 'a5000000-0000-0000-0000-000000000004', 0.90),  -- Affordable
  ('pune', 'a5000000-0000-0000-0000-000000000001', 0.75),  -- Startup Hub
  ('pune', 'a5000000-0000-0000-0000-000000000003', 0.85),  -- Student Friendly
  ('pune', 'a3000000-0000-0000-0000-000000000001', 0.70)   -- Fast-Paced
ON CONFLICT DO NOTHING;

-- Bangalore: Startup Hub, Affordable, Fast-Paced, Cosmopolitan, Nightlife, Digital Nomad
INSERT INTO city_vibe_tags (city_id, vibe_tag_id, strength) VALUES
  ('bangalore', 'a5000000-0000-0000-0000-000000000001', 0.90),  -- Startup Hub
  ('bangalore', 'a5000000-0000-0000-0000-000000000004', 0.85),  -- Affordable
  ('bangalore', 'a3000000-0000-0000-0000-000000000001', 0.80),  -- Fast-Paced
  ('bangalore', 'a2000000-0000-0000-0000-000000000003', 0.75),  -- Cosmopolitan
  ('bangalore', 'a1000000-0000-0000-0000-000000000002', 0.70),  -- Nightlife
  ('bangalore', 'a5000000-0000-0000-0000-000000000002', 0.75)   -- Digital Nomad
ON CONFLICT DO NOTHING;

COMMIT;
