-- ============================================================
-- TeleportMe Seed Data — 55 Cities + Scores
-- Generated from teleport_cities.json
-- ============================================================

-- Clear existing data (safe for fresh deploy)
DELETE FROM public.city_scores;
DELETE FROM public.cities;

-- ============================================================
-- INSERT CITIES
-- ============================================================

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('san-francisco', 'San Francisco', 'San Francisco, California, United States', 'United States', 'North America', 37.7749, -122.4194, 874961, 65.59, 'A global hub for technology and innovation, San Francisco offers world-class startups and venture capital but struggles with extremely high housing costs.', 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('new-york', 'New York', 'New York City, New York, United States', 'United States', 'North America', 40.7128, -74.006, 8336817, 66.47, 'The cultural and financial capital of the world, New York City offers unmatched arts, dining, and economic opportunity alongside notoriously high living costs.', 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('austin', 'Austin', 'Austin, Texas, United States', 'United States', 'North America', 30.2672, -97.7431, 978908, 64.12, 'A vibrant tech hub with a thriving music scene, Austin offers strong startup culture and moderate costs compared to coastal cities.', 'https://images.unsplash.com/photo-1531218150217-54595bc2b934?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('seattle', 'Seattle', 'Seattle, Washington, United States', 'United States', 'North America', 47.6062, -122.3321, 737015, 64.71, 'Home to major tech giants, Seattle combines a strong innovation economy with stunning Pacific Northwest scenery and outdoor recreation.', 'https://images.unsplash.com/photo-1502175353174-a7a70e73b4c3?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('portland', 'Portland', 'Portland, Oregon, United States', 'United States', 'North America', 45.5152, -122.6784, 652503, 63.53, 'Known for its quirky culture and eco-consciousness, Portland offers excellent cycling infrastructure, a vibrant food scene, and easy access to nature.', 'https://images.unsplash.com/photo-1507245338956-23ef52481479?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('denver', 'Denver', 'Denver, Colorado, United States', 'United States', 'North America', 39.7392, -104.9903, 715522, 63.53, 'The Mile High City offers unmatched access to Rocky Mountain outdoor recreation alongside a growing tech sector and craft beer culture.', 'https://images.unsplash.com/photo-1546156929-a4c0ac411f47?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('miami', 'Miami', 'Miami, Florida, United States', 'United States', 'North America', 25.7617, -80.1918, 467963, 60.59, 'A tropical gateway to Latin America, Miami offers warm weather year-round, a vibrant nightlife, and a growing tech and finance sector.', 'https://images.unsplash.com/photo-1506966953602-c20cc11f75e3?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('nashville', 'Nashville', 'Nashville, Tennessee, United States', 'United States', 'North America', 36.1627, -86.7816, 689447, 59.41, 'Music City is booming with a growing economy, affordable living by major city standards, and a legendary country music and food scene.', 'https://images.unsplash.com/photo-1545419913-775e00e202ec?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('charleston', 'Charleston', 'Charleston, South Carolina, United States', 'United States', 'North America', 32.7765, -79.9311, 150227, 57.06, 'A charming Southern city known for its historic architecture, award-winning cuisine, and beautiful coastal scenery.', 'https://images.unsplash.com/photo-1569025743873-56e7e5e89e4a?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('chicago', 'Chicago', 'Chicago, Illinois, United States', 'United States', 'North America', 41.8781, -87.6298, 2693976, 65.29, 'The Windy City boasts world-class architecture, a diverse food scene, and a strong economy anchored by finance, manufacturing, and technology.', 'https://images.unsplash.com/photo-1494522855154-9297ac14b55f?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('los-angeles', 'Los Angeles', 'Los Angeles, California, United States', 'United States', 'North America', 34.0522, -118.2437, 3979576, 60.59, 'The entertainment capital of the world, Los Angeles offers year-round sunshine, cultural diversity, and a sprawling creative economy.', 'https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('boston', 'Boston', 'Boston, Massachusetts, United States', 'United States', 'North America', 42.3601, -71.0589, 692600, 66.47, 'A world leader in education and healthcare, Boston combines prestigious universities and cutting-edge biotech with rich colonial history.', 'https://images.unsplash.com/photo-1501979376754-2ff867a4f659?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('toronto', 'Toronto', 'Toronto, Ontario, Canada', 'Canada', 'North America', 43.6532, -79.3832, 2794356, 65.88, 'Canada''s largest city is one of the most multicultural places on Earth, with a strong financial sector and excellent public healthcare.', 'https://images.unsplash.com/photo-1517935706615-2717063c2225?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('vancouver', 'Vancouver', 'Vancouver, British Columbia, Canada', 'Canada', 'North America', 49.2827, -123.1207, 631486, 63.53, 'Nestled between mountains and ocean, Vancouver is one of the world''s most scenic cities, offering incredible natural beauty alongside a tolerant, multicultural society.', 'https://images.unsplash.com/photo-1559511260-66a68e7e2e09?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('montreal', 'Montreal', 'Montreal, Quebec, Canada', 'Canada', 'North America', 45.5017, -73.5673, 1762949, 66.47, 'A bilingual cultural powerhouse, Montreal combines European charm with North American energy, offering world-class festivals, affordable living, and excellent cuisine.', 'https://images.unsplash.com/photo-1519178614-68673b201f36?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('mexico-city', 'Mexico City', 'Mexico City, Mexico', 'Mexico', 'North America', 19.4326, -99.1332, 9209944, 58.24, 'One of the world''s largest metropolitan areas, Mexico City offers rich pre-Columbian and colonial history, incredible food, and an increasingly vibrant startup scene.', 'https://images.unsplash.com/photo-1518659526054-190340b32735?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('lisbon', 'Lisbon', 'Lisbon, Portugal', 'Portugal', 'Europe', 38.7223, -9.1393, 544851, 64.71, 'A sun-drenched European capital with a booming tech scene, Lisbon attracts digital nomads and entrepreneurs with its affordable living, rich history, and warm climate.', 'https://images.unsplash.com/photo-1536663815808-535e2280d2c2?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('london', 'London', 'London, United Kingdom', 'United Kingdom', 'Europe', 51.5074, -0.1278, 8982000, 67.06, 'A global financial and cultural capital, London offers unparalleled history, world-class museums, and exceptional international connectivity.', 'https://images.unsplash.com/photo-1486299267070-83823f5448dd?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('berlin', 'Berlin', 'Berlin, Germany', 'Germany', 'Europe', 52.52, 13.405, 3644826, 69.41, 'Europe''s creative capital, Berlin offers an unmatched arts and nightlife scene, affordable rent by Western European standards, and a thriving startup ecosystem.', 'https://images.unsplash.com/photo-1560969184-10fe8719e047?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('barcelona', 'Barcelona', 'Barcelona, Spain', 'Spain', 'Europe', 41.3874, 2.1686, 1620343, 65.88, 'A Mediterranean jewel blending Gaudi''s architecture with beach culture, Barcelona offers a superb quality of life with warm weather and vibrant nightlife.', 'https://images.unsplash.com/photo-1583422409516-2895a77efded?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('amsterdam', 'Amsterdam', 'Amsterdam, Netherlands', 'Netherlands', 'Europe', 52.3676, 4.9041, 872680, 68.82, 'Famous for its canals and cycling culture, Amsterdam is one of Europe''s most tolerant and well-connected cities with a strong tech and creative economy.', 'https://images.unsplash.com/photo-1534351590666-13e3e96b5017?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('paris', 'Paris', 'Paris, France', 'France', 'Europe', 48.8566, 2.3522, 2161000, 66.47, 'The City of Light remains the world''s cultural benchmark, offering unmatched art, cuisine, and fashion alongside a growing startup ecosystem.', 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('prague', 'Prague', 'Prague, Czech Republic', 'Czech Republic', 'Europe', 50.0755, 14.4378, 1309000, 63.53, 'A fairy-tale Central European capital, Prague offers stunning Gothic and Baroque architecture, affordable living, and a growing technology sector.', 'https://images.unsplash.com/photo-1519677100203-a0e668c92439?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('copenhagen', 'Copenhagen', 'Copenhagen, Denmark', 'Denmark', 'Europe', 55.6761, 12.5683, 794128, 66.47, 'A Scandinavian design capital that consistently ranks among the happiest cities, Copenhagen offers excellent cycling infrastructure, great healthcare, and a high quality of life.', 'https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('stockholm', 'Stockholm', 'Stockholm, Sweden', 'Sweden', 'Europe', 59.3293, 18.0686, 975904, 67.06, 'Built on 14 islands, Stockholm is a global leader in sustainability, innovation, and quality of life, producing more unicorn startups per capita than almost any other city.', 'https://images.unsplash.com/photo-1509356843151-3e7d96241e11?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('dublin', 'Dublin', 'Dublin, Ireland', 'Ireland', 'Europe', 53.3498, -6.2603, 544107, 63.53, 'Ireland''s vibrant capital is a European tech hub, hosting the headquarters of many global companies, with a lively pub culture and friendly locals.', 'https://images.unsplash.com/photo-1549918864-48ac978761a4?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('tallinn', 'Tallinn', 'Tallinn, Estonia', 'Estonia', 'Europe', 59.437, 24.7536, 437619, 67.65, 'The world''s most digitally advanced capital, Tallinn pioneered e-residency and digital government, making it a magnet for tech entrepreneurs and digital nomads.', 'https://images.unsplash.com/photo-1565008576549-57569a49371d?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('zurich', 'Zurich', 'Zurich, Switzerland', 'Switzerland', 'Europe', 47.3769, 8.5417, 421878, 67.65, 'Switzerland''s financial powerhouse offers exceptional safety, pristine Alpine scenery, and world-class healthcare, though at some of the highest living costs anywhere.', 'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('vienna', 'Vienna', 'Vienna, Austria', 'Austria', 'Europe', 48.2082, 16.3738, 1911728, 70.59, 'Repeatedly ranked the world''s most livable city, Vienna offers imperial architecture, legendary classical music, excellent public transport, and superb healthcare.', 'https://images.unsplash.com/photo-1516550893923-42d28e5677af?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('munich', 'Munich', 'Munich, Germany', 'Germany', 'Europe', 48.1351, 11.582, 1471508, 67.06, 'Bavaria''s capital combines German engineering excellence with Alpine proximity, offering Oktoberfest traditions, a strong automotive economy, and high quality of life.', 'https://images.unsplash.com/photo-1595867818082-083862f3d630?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('tokyo', 'Tokyo', 'Tokyo, Japan', 'Japan', 'Asia', 35.6762, 139.6503, 13960000, 70.59, 'The world''s largest metropolitan area seamlessly blends ultra-modern technology with ancient temples, offering incredible safety, cuisine, and public transport.', 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('singapore', 'Singapore', 'Singapore', 'Singapore', 'Asia', 1.3521, 103.8198, 5850342, 70.0, 'A gleaming city-state at the crossroads of Asia, Singapore offers extraordinary safety, a powerhouse economy, and world-class infrastructure in a tropical setting.', 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('bangkok', 'Bangkok', 'Bangkok, Thailand', 'Thailand', 'Asia', 13.7563, 100.5018, 10539000, 58.82, 'A sensory feast of ornate temples, bustling street markets, and legendary cuisine, Bangkok offers incredibly affordable living and a thriving digital nomad community.', 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('seoul', 'Seoul', 'Seoul, South Korea', 'South Korea', 'Asia', 37.5665, 126.978, 9776000, 67.65, 'A hyper-connected metropolis at the forefront of technology and pop culture, Seoul offers blazing-fast internet, rich history, and an electrifying urban energy.', 'https://images.unsplash.com/photo-1517154421773-0529f29ea451?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('taipei', 'Taipei', 'Taipei, Taiwan', 'Taiwan', 'Asia', 25.033, 121.5654, 2646204, 67.06, 'A friendly and affordable Asian capital, Taipei delights with incredible night markets, excellent public transit, and a thriving tech manufacturing ecosystem.', 'https://images.unsplash.com/photo-1470004914212-05527e49370b?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('hong-kong', 'Hong Kong', 'Hong Kong, China', 'China', 'Asia', 22.3193, 114.1694, 7482500, 62.94, 'A dazzling vertical city where East meets West, Hong Kong offers a world-class financial center, incredible cuisine, and dramatic harbor views.', 'https://images.unsplash.com/photo-1536599018102-9f803c140fc1?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('melbourne', 'Melbourne', 'Melbourne, Australia', 'Australia', 'Oceania', -37.8136, 144.9631, 5078193, 66.47, 'Australia''s cultural capital, Melbourne is famous for its coffee culture, street art, live music scene, and passion for Australian Rules football.', 'https://images.unsplash.com/photo-1514395462725-fb4566210144?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('sydney', 'Sydney', 'Sydney, Australia', 'Australia', 'Oceania', -33.8688, 151.2093, 5312163, 64.71, 'Home to the iconic Opera House and Harbour Bridge, Sydney offers stunning beaches, a strong economy, and an enviable outdoor lifestyle.', 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('auckland', 'Auckland', 'Auckland, New Zealand', 'New Zealand', 'Oceania', -36.8485, 174.7633, 1657200, 63.53, 'The City of Sails sits between two harbors surrounded by volcanic cones, offering exceptional outdoor recreation and a relaxed Kiwi lifestyle.', 'https://images.unsplash.com/photo-1507699622108-4be3abd695ad?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('buenos-aires', 'Buenos Aires', 'Buenos Aires, Argentina', 'Argentina', 'South America', -34.6037, -58.3816, 3075646, 60.59, 'The Paris of South America enchants with passionate tango, world-class steak, vibrant street art, and an incredibly affordable cosmopolitan lifestyle.', 'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('medellin', 'Medellin', 'Medellin, Colombia', 'Colombia', 'South America', 6.2476, -75.5658, 2569007, 57.65, 'Once notorious, Medellin has reinvented itself as a city of innovation with eternal spring weather, affordable living, and a booming digital nomad community.', 'https://images.unsplash.com/photo-1583997052103-b4a1cb974ce5?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('sao-paulo', 'Sao Paulo', 'Sao Paulo, Brazil', 'Brazil', 'South America', -23.5505, -46.6333, 12325232, 55.88, 'South America''s largest city is an economic powerhouse with incredible culinary diversity, a thriving arts scene, and a pulsating nightlife.', 'https://images.unsplash.com/photo-1543059080-0b36deb42620?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('santiago', 'Santiago', 'Santiago, Chile', 'Chile', 'South America', -33.4489, -70.6693, 6160000, 60.59, 'Framed by the Andes mountains, Santiago offers South America''s most stable economy alongside excellent wine regions and ski resorts within easy reach.', 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('bogota', 'Bogota', 'Bogota, Colombia', 'Colombia', 'South America', 4.711, -74.0721, 7181469, 54.71, 'Colombia''s high-altitude capital is rapidly modernizing, offering affordable living, a growing tech startup scene, and rich cultural heritage.', 'https://images.unsplash.com/photo-1568632234157-ce7aecd03d0d?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('dubai', 'Dubai', 'Dubai, United Arab Emirates', 'United Arab Emirates', 'Asia', 25.2048, 55.2708, 3331420, 62.94, 'A futuristic desert metropolis, Dubai offers tax-free income, ultra-modern infrastructure, and a global business hub connecting East and West.', 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('tel-aviv', 'Tel Aviv', 'Tel Aviv, Israel', 'Israel', 'Asia', 32.0853, 34.7818, 451523, 62.94, 'The startup nation''s beating heart, Tel Aviv combines Mediterranean beach culture with an incredibly dense tech ecosystem and vibrant nightlife.', 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('cape-town', 'Cape Town', 'Cape Town, South Africa', 'South Africa', 'Africa', -33.9249, 18.4241, 4618000, 56.47, 'Nestled between Table Mountain and the Atlantic Ocean, Cape Town offers breathtaking natural beauty, excellent wine regions, and a vibrant creative scene.', 'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('nairobi', 'Nairobi', 'Nairobi, Kenya', 'Kenya', 'Africa', -1.2921, 36.8219, 4397073, 51.76, 'East Africa''s largest city and tech hub, Nairobi is a gateway to incredible wildlife safaris with a rapidly growing innovation ecosystem.', 'https://images.unsplash.com/photo-1611348524140-53c9a25263d6?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('helsinki', 'Helsinki', 'Helsinki, Finland', 'Finland', 'Europe', 60.1699, 24.9384, 656229, 67.06, 'A design-forward Nordic capital, Helsinki offers world-leading education, universal healthcare, excellent saunas, and a strong sense of social equality.', 'https://images.unsplash.com/photo-1538332576228-eb5b4c4de6f5?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('osaka', 'Osaka', 'Osaka, Japan', 'Japan', 'Asia', 34.6937, 135.5023, 2753862, 67.06, 'Japan''s kitchen and comedy capital, Osaka delights with its street food culture, friendly locals, historic castles, and excellent transit connections.', 'https://images.unsplash.com/photo-1590559899731-a382839e5549?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('kuala-lumpur', 'Kuala Lumpur', 'Kuala Lumpur, Malaysia', 'Malaysia', 'Asia', 3.139, 101.6869, 1982112, 60.59, 'A multicultural Southeast Asian metropolis, Kuala Lumpur offers incredibly affordable living, iconic Petronas Towers, and a delicious fusion food scene.', 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('warsaw', 'Warsaw', 'Warsaw, Poland', 'Poland', 'Europe', 52.2297, 21.0122, 1790658, 62.35, 'Rebuilt from wartime devastation, Warsaw is now a dynamic European capital with a booming economy, growing tech scene, and a fascinating blend of old and new.', 'https://images.unsplash.com/photo-1519197924294-4ba991a11128?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('reykjavik', 'Reykjavik', 'Reykjavik, Iceland', 'Iceland', 'Europe', 64.1466, -21.9426, 131136, 62.94, 'The world''s northernmost capital offers otherworldly volcanic landscapes, geothermal hot springs, the Northern Lights, and an extraordinarily safe society.', 'https://images.unsplash.com/photo-1504829857797-ddff29c09e32?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('edinburgh', 'Edinburgh', 'Edinburgh, Scotland, United Kingdom', 'United Kingdom', 'Europe', 55.9533, -3.1883, 524930, 64.12, 'Scotland''s historic capital hosts the world''s largest arts festival and offers stunning medieval architecture, excellent universities, and a thriving cultural scene.', 'https://images.unsplash.com/photo-1551009175-15bdf9dcb580?auto=format&fit=crop&w=800&q=80');

INSERT INTO public.cities (id, name, full_name, country, continent, latitude, longitude, population, teleport_city_score, summary, image_url)
VALUES ('bali', 'Bali', 'Bali (Denpasar), Indonesia', 'Indonesia', 'Asia', -8.3405, 115.092, 4225384, 58.24, 'A tropical paradise for digital nomads, Bali offers stunning rice terraces, Hindu temple culture, world-class surfing, and an incredibly affordable lifestyle.', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80');

-- ============================================================
-- INSERT CITY SCORES
-- ============================================================

INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Cost of Living', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Startups', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Venture Capital', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Commute', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Safety', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Environmental Quality', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Economy', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Tolerance', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('san-francisco', 'Outdoors', 7.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Housing', 1.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Cost of Living', 1.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Startups', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Venture Capital', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Travel Connectivity', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Commute', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Education', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Environmental Quality', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Economy', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Taxation', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Leisure & Culture', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Tolerance', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('new-york', 'Outdoors', 3.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Housing', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Cost of Living', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Startups', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Venture Capital', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Travel Connectivity', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Commute', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Healthcare', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Taxation', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('austin', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Housing', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Cost of Living', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Startups', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Venture Capital', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Commute', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Economy', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Taxation', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seattle', 'Outdoors', 7.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Housing', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Venture Capital', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Travel Connectivity', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Commute', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Safety', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Healthcare', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Environmental Quality', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Tolerance', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('portland', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Housing', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Cost of Living', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Healthcare', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Taxation', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('denver', 'Outdoors', 9.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Housing', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Travel Connectivity', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Commute', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Safety', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Education', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Taxation', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('miami', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Housing', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Cost of Living', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Startups', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Venture Capital', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Travel Connectivity', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Commute', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Safety', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Education', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Taxation', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nashville', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Housing', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Cost of Living', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Startups', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Venture Capital', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Travel Connectivity', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Education', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Economy', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Taxation', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Internet Access', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('charleston', 'Outdoors', 7.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Housing', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Venture Capital', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Travel Connectivity', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Commute', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Safety', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Environmental Quality', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Economy', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Taxation', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Leisure & Culture', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('chicago', 'Outdoors', 3.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Cost of Living', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Startups', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Venture Capital', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Travel Connectivity', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Commute', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Safety', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Healthcare', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Environmental Quality', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Taxation', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('los-angeles', 'Outdoors', 7.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Cost of Living', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Startups', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Venture Capital', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Travel Connectivity', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Commute', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Safety', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Healthcare', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Education', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Environmental Quality', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Economy', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('boston', 'Outdoors', 4.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Housing', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Venture Capital', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Travel Connectivity', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Commute', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Safety', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Taxation', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Tolerance', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('toronto', 'Outdoors', 5.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Housing', 1.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Cost of Living', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Venture Capital', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Travel Connectivity', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Commute', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Safety', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Environmental Quality', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Tolerance', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vancouver', 'Outdoors', 9.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Housing', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Cost of Living', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Venture Capital', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Commute', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Safety', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Environmental Quality', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Taxation', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('montreal', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Housing', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Cost of Living', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Startups', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Venture Capital', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Commute', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Business Freedom', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Safety', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Healthcare', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Education', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Environmental Quality', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Economy', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Taxation', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Internet Access', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Tolerance', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('mexico-city', 'Outdoors', 4.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Housing', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Commute', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Education', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Economy', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Taxation', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('lisbon', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Housing', 1.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Cost of Living', 1.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Startups', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Venture Capital', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Travel Connectivity', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Commute', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Safety', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Education', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Environmental Quality', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Economy', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Leisure & Culture', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Tolerance', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('london', 'Outdoors', 3.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Housing', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Startups', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Venture Capital', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Travel Connectivity', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Commute', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Safety', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Taxation', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Tolerance', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('berlin', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Housing', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Venture Capital', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Travel Connectivity', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Commute', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Business Freedom', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Safety', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Economy', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Taxation', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('barcelona', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Housing', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Venture Capital', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Travel Connectivity', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Commute', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Taxation', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Leisure & Culture', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Tolerance', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('amsterdam', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Cost of Living', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Startups', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Venture Capital', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Travel Connectivity', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Commute', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Business Freedom', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Safety', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Economy', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Taxation', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Leisure & Culture', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('paris', 'Outdoors', 4.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Housing', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Cost of Living', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Venture Capital', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Commute', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Education', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Economy', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Taxation', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Tolerance', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('prague', 'Outdoors', 7.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Housing', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Cost of Living', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Travel Connectivity', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Commute', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Safety', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Healthcare', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Environmental Quality', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Taxation', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Tolerance', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('copenhagen', 'Outdoors', 4.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Housing', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Cost of Living', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Startups', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Venture Capital', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Commute', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Healthcare', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Environmental Quality', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Taxation', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Tolerance', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('stockholm', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Housing', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dublin', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Housing', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Startups', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Travel Connectivity', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Commute', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Business Freedom', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Taxation', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Internet Access', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Leisure & Culture', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Tolerance', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tallinn', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Housing', 1.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Cost of Living', 1.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Venture Capital', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Travel Connectivity', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Commute', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Safety', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Healthcare', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Education', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Environmental Quality', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Economy', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('zurich', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Housing', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Startups', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Venture Capital', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Travel Connectivity', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Commute', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Safety', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Healthcare', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Environmental Quality', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('vienna', 'Outdoors', 6.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Housing', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Cost of Living', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Travel Connectivity', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Commute', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Environmental Quality', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Economy', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('munich', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Housing', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Travel Connectivity', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Commute', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Safety', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Economy', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Internet Access', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tokyo', 'Outdoors', 6.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Cost of Living', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Startups', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Venture Capital', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Travel Connectivity', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Commute', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Business Freedom', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Safety', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Economy', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Taxation', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Internet Access', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Leisure & Culture', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Tolerance', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('singapore', 'Outdoors', 3.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Housing', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Cost of Living', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Startups', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Venture Capital', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Travel Connectivity', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Commute', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Business Freedom', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Safety', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Education', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Environmental Quality', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Economy', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Taxation', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Tolerance', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bangkok', 'Outdoors', 4.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Housing', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Startups', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Venture Capital', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Travel Connectivity', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Commute', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Environmental Quality', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Economy', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Taxation', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Internet Access', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Tolerance', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('seoul', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Housing', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Commute', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Taxation', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Internet Access', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('taipei', 'Outdoors', 6.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Housing', 1.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Cost of Living', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Startups', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Venture Capital', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Travel Connectivity', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Commute', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Environmental Quality', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Economy', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Taxation', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Internet Access', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('hong-kong', 'Outdoors', 5.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Housing', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Commute', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Environmental Quality', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('melbourne', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Cost of Living', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Healthcare', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Environmental Quality', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Economy', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sydney', 'Outdoors', 9.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Housing', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Startups', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Venture Capital', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Travel Connectivity', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Safety', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Environmental Quality', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Leisure & Culture', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('auckland', 'Outdoors', 9.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Housing', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Cost of Living', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Startups', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Venture Capital', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Travel Connectivity', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Business Freedom', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Safety', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Education', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Economy', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Taxation', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Internet Access', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Leisure & Culture', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Tolerance', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('buenos-aires', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Housing', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Cost of Living', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Startups', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Venture Capital', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Travel Connectivity', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Commute', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Business Freedom', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Safety', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Healthcare', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Education', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Economy', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Taxation', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Internet Access', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Leisure & Culture', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Tolerance', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('medellin', 'Outdoors', 8.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Housing', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Commute', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Business Freedom', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Safety', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Healthcare', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Education', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Environmental Quality', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Economy', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Taxation', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Internet Access', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('sao-paulo', 'Outdoors', 4.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Housing', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Startups', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Venture Capital', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Travel Connectivity', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Healthcare', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Education', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Environmental Quality', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Taxation', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Internet Access', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Leisure & Culture', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('santiago', 'Outdoors', 7.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Housing', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Startups', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Venture Capital', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Travel Connectivity', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Commute', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Business Freedom', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Safety', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Healthcare', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Education', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Environmental Quality', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Economy', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Taxation', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Internet Access', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Leisure & Culture', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bogota', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Housing', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Cost of Living', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Venture Capital', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Travel Connectivity', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Commute', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Business Freedom', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Safety', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Healthcare', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Education', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Environmental Quality', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Economy', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Taxation', 10.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Leisure & Culture', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Tolerance', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('dubai', 'Outdoors', 3.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Housing', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Cost of Living', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Startups', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Venture Capital', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Travel Connectivity', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Commute', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Safety', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Environmental Quality', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Economy', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('tel-aviv', 'Outdoors', 7.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Housing', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Startups', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Venture Capital', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Travel Connectivity', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Commute', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Business Freedom', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Safety', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Healthcare', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Education', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Economy', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Internet Access', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Tolerance', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('cape-town', 'Outdoors', 9.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Housing', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Cost of Living', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Startups', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Venture Capital', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Travel Connectivity', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Commute', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Business Freedom', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Safety', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Healthcare', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Education', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Environmental Quality', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Economy', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Taxation', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Internet Access', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Leisure & Culture', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Tolerance', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('nairobi', 'Outdoors', 7.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Housing', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Cost of Living', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Startups', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Venture Capital', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Commute', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Business Freedom', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Safety', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Healthcare', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Education', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Environmental Quality', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Taxation', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Leisure & Culture', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Tolerance', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('helsinki', 'Outdoors', 4.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Housing', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Startups', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Venture Capital', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Travel Connectivity', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Commute', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Business Freedom', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Safety', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Education', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Environmental Quality', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Taxation', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Internet Access', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Tolerance', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('osaka', 'Outdoors', 6.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Housing', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Cost of Living', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Startups', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Venture Capital', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Travel Connectivity', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Commute', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Business Freedom', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Safety', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Healthcare', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Education', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Environmental Quality', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Taxation', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Leisure & Culture', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Tolerance', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('kuala-lumpur', 'Outdoors', 5.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Housing', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Cost of Living', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Startups', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Venture Capital', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Commute', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Business Freedom', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Healthcare', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Education', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Environmental Quality', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Economy', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Taxation', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Leisure & Culture', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Tolerance', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('warsaw', 'Outdoors', 5.0);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Housing', 3.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Cost of Living', 2.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Startups', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Venture Capital', 2.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Travel Connectivity', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Commute', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Safety', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Healthcare', 8.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Education', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Environmental Quality', 9.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Economy', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Internet Access', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Leisure & Culture', 6.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Tolerance', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('reykjavik', 'Outdoors', 9.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Housing', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Cost of Living', 5.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Startups', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Venture Capital', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Travel Connectivity', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Commute', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Business Freedom', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Safety', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Healthcare', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Education', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Economy', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Taxation', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Internet Access', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Leisure & Culture', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Tolerance', 8.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('edinburgh', 'Outdoors', 6.5);

INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Housing', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Cost of Living', 9.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Startups', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Venture Capital', 1.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Travel Connectivity', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Commute', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Business Freedom', 4.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Safety', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Healthcare', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Education', 3.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Environmental Quality', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Economy', 4.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Taxation', 6.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Internet Access', 5.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Leisure & Culture', 7.5);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Tolerance', 7.0);
INSERT INTO public.city_scores (city_id, category, score) VALUES ('bali', 'Outdoors', 9.0);
