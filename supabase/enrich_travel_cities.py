#!/usr/bin/env python3
"""
Enrich travel cities with complete data records for TeleportMe.
Generates scored data for 156 travel-focused cities.
"""

import json
import os

SCORE_KEYS = [
    "Housing", "Cost of Living", "Startups", "Venture Capital",
    "Travel Connectivity", "Commute", "Business Freedom", "Safety",
    "Healthcare", "Education", "Environmental Quality", "Economy",
    "Taxation", "Internet Access", "Leisure & Culture", "Tolerance",
    "Outdoors"
]

def make_city(name, full_name, country, continent, lat, lon, pop, summary, image_url, scores_list):
    slug = name.lower().replace(" ", "-").replace("(", "").replace(")", "").replace(",", "").replace("'", "")
    scores = dict(zip(SCORE_KEYS, scores_list))
    avg = sum(scores_list) / len(scores_list)
    tcs = round(avg * 10, 2)
    return {
        "id": slug,
        "name": name,
        "full_name": full_name,
        "country": country,
        "continent": continent,
        "latitude": lat,
        "longitude": lon,
        "population": pop,
        "teleport_city_score": tcs,
        "summary": summary,
        "image_url": image_url,
        "scores": scores
    }

def get_all_cities():
    cities = []
    cities += get_southeast_asia()
    cities += get_east_asia()
    cities += get_south_asia()
    cities += get_europe_1()
    cities += get_europe_2()
    cities += get_middle_east()
    cities += get_africa()
    cities += get_south_america()
    cities += get_central_north_america()
    cities += get_caribbean_oceania()
    cities += get_extra_cities()
    return cities


def get_southeast_asia():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Chiang Mai","Chiang Mai, Thailand","Thailand","Asia",18.7883,98.9853,131091,"Affordable digital nomad haven with ancient temples and night markets. Over 300 temples dot this walled city surrounded by misty mountains and lush jungle.","",
        [8.5, 8.8, 4.5, 2.0, 6.0, 5.5, 5.5, 7.5, 6.0, 5.0, 7.0, 5.0, 7.5, 7.0, 8.0, 6.5, 7.5]))
    c.append(make_city("Siem Reap","Siem Reap, Cambodia","Cambodia","Asia",13.3671,103.8448,245494,"Gateway to the magnificent Angkor Wat temple complex, one of the most awe-inspiring archaeological sites on Earth. A small city with big temples and warm Khmer hospitality.","",
        [8.0, 9.0, 2.0, 1.0, 5.0, 5.0, 4.5, 6.5, 4.0, 3.5, 6.5, 3.5, 8.0, 5.0, 7.5, 6.0, 6.5]))
    c.append(make_city("Luang Prabang","Luang Prabang, Laos","Laos","Asia",19.8833,102.1333,66781,"UNESCO town where saffron-robed monks collect morning alms along the Mekong. A serene blend of French colonial architecture and gilded Buddhist temples.","",
        [7.5, 8.5, 1.5, 1.0, 3.5, 4.5, 4.0, 7.5, 3.5, 3.0, 8.5, 3.0, 8.0, 4.0, 7.0, 6.5, 7.5]))
    c.append(make_city("Hoi An","Hoi An, Quang Nam, Vietnam","Vietnam","Asia",15.8801,108.338,152160,"Lantern-lit ancient trading port with world-class tailors and pristine beaches nearby. This enchanting UNESCO town glows with thousands of silk lanterns each evening.","",
        [8.0, 8.8, 2.0, 1.0, 4.5, 5.0, 4.5, 8.0, 5.0, 4.0, 7.5, 4.0, 7.5, 6.0, 8.0, 7.0, 7.0]))
    c.append(make_city("Da Nang","Da Nang, Vietnam","Vietnam","Asia",16.0544,108.2022,1134310,"Modern beach city bridging historic Hoi An and imperial Hue. A fast-growing coastal metropolis with golden bridges, marble mountains, and excellent seafood.","",
        [7.5, 8.0, 3.5, 1.5, 6.0, 5.5, 4.5, 7.5, 5.5, 5.0, 7.0, 5.0, 7.5, 6.5, 7.0, 6.5, 7.5]))
    c.append(make_city("Hanoi","Hanoi, Vietnam","Vietnam","Asia",21.0285,105.8542,8053663,"Thousand-year-old capital where French colonial charm meets bustling street food culture. Wander the chaotic Old Quarter, sip egg coffee, and watch life unfold around Hoan Kiem Lake.","",
        [6.5, 7.5, 4.5, 2.5, 7.5, 4.0, 4.5, 7.0, 5.5, 5.5, 5.0, 5.5, 7.0, 6.0, 8.0, 6.0, 5.5]))
    c.append(make_city("Penang","Penang, Malaysia","Malaysia","Asia",5.4164,100.3327,708127,"Street food capital of Asia with colorful George Town heritage and hilltop temples. A melting pot of Malay, Chinese, Indian, and colonial British cultures on one island.","",
        [7.0, 7.5, 4.0, 2.0, 6.5, 5.0, 5.5, 7.0, 6.0, 5.5, 6.5, 5.5, 7.0, 7.0, 8.0, 7.0, 6.5]))
    c.append(make_city("Langkawi","Langkawi, Kedah, Malaysia","Malaysia","Asia",6.3500,99.8000,109000,"Duty-free island paradise with mangrove cruises, cable cars, and eagle-watching. A laid-back archipelago of 99 islands where jungle-clad peaks meet turquoise Andaman waters.","",
        [7.5, 7.5, 1.5, 1.0, 5.0, 4.0, 5.5, 7.5, 4.5, 3.5, 8.5, 4.0, 8.0, 5.5, 7.0, 7.0, 8.0]))
    c.append(make_city("Phuket","Phuket, Thailand","Thailand","Asia",7.8804,98.3923,416582,"Thailand's largest island offering luxury resorts, vibrant nightlife, and stunning Andaman beaches. From serene temple visits to lively Patong, Phuket serves every type of traveler.","",
        [6.5, 6.5, 3.0, 1.5, 7.5, 5.0, 5.5, 6.5, 6.0, 4.5, 6.5, 5.5, 7.5, 6.5, 7.5, 6.0, 8.0]))
    c.append(make_city("Krabi","Krabi, Thailand","Thailand","Asia",8.0863,98.9063,52867,"Limestone karst paradise with world-famous island-hopping and rock climbing. Gateway to Railay Beach, the Phi Phi Islands, and some of Thailand's most dramatic scenery.","",
        [8.0, 8.0, 1.5, 1.0, 5.0, 4.5, 5.0, 7.0, 4.5, 3.5, 8.5, 4.0, 7.5, 5.5, 7.0, 6.0, 9.0]))
    c.append(make_city("Koh Samui","Koh Samui, Surat Thani, Thailand","Thailand","Asia",9.5120,100.0067,63299,"Tropical island blending palm-fringed beaches with wellness retreats and full moon parties nearby. From luxury hillside villas to backpacker bungalows, the island welcomes all.","",
        [7.0, 7.0, 2.0, 1.0, 5.5, 4.5, 5.0, 6.5, 5.0, 3.5, 7.5, 4.5, 7.5, 5.5, 7.0, 6.0, 8.0]))

    c.append(make_city("Ubud","Ubud, Bali, Indonesia","Indonesia","Asia",-8.5069,115.2625,74320,"Spiritual heart of Bali surrounded by rice terraces, yoga studios, and artisan workshops. A lush jungle retreat where ancient Hindu traditions meet modern wellness culture.","",
        [7.5, 7.5, 3.0, 1.5, 5.0, 4.5, 4.5, 7.0, 5.0, 4.0, 8.0, 4.5, 7.0, 6.0, 8.0, 6.5, 8.5]))
    c.append(make_city("Yogyakarta","Yogyakarta, Java, Indonesia","Indonesia","Asia",-7.7956,110.3695,422732,"Cultural soul of Java with ancient Borobudur and Prambanan temples. A vibrant student city blending Javanese royal traditions with contemporary art and batik workshops.","",
        [8.0, 8.5, 3.0, 1.5, 5.5, 5.0, 4.5, 7.0, 5.0, 5.5, 6.5, 4.5, 7.0, 6.0, 8.0, 6.5, 6.5]))
    c.append(make_city("Bandung","Bandung, West Java, Indonesia","Indonesia","Asia",-6.9175,107.6191,2444160,"Cool highland city known for tea plantations, art deco architecture, and vibrant fashion. A creative hub surrounded by volcanic peaks and scenic countryside.","",
        [7.5, 8.0, 3.5, 2.0, 5.0, 4.0, 4.5, 6.5, 5.0, 5.5, 6.0, 5.0, 7.0, 6.0, 6.5, 6.0, 6.5]))
    c.append(make_city("Cebu","Cebu City, Cebu, Philippines","Philippines","Asia",10.3157,123.8854,964169,"Island capital with Spanish colonial heritage and world-class diving nearby. A bustling city that serves as gateway to whale sharks, sardine runs, and pristine island beaches.","",
        [7.5, 7.5, 3.5, 2.0, 6.5, 4.5, 5.0, 5.5, 5.5, 5.0, 6.0, 5.0, 7.0, 6.0, 7.0, 6.5, 7.5]))
    c.append(make_city("Boracay","Boracay, Aklan, Philippines","Philippines","Asia",11.9674,121.9248,37802,"Tiny island famous for its powdery White Beach and spectacular sunsets. After a rehabilitation closure, this Philippine gem returned cleaner and more beautiful than ever.","",
        [7.0, 7.0, 1.5, 1.0, 4.5, 4.0, 4.5, 6.0, 4.0, 3.0, 7.0, 4.0, 7.0, 5.0, 7.5, 6.5, 8.5]))
    c.append(make_city("Palawan","Palawan, Philippines","Philippines","Asia",9.8349,118.7384,849469,"Pristine archipelago with underground rivers, hidden lagoons, and crystal-clear waters. Repeatedly voted the world's best island, Palawan is nature at its most magnificent.","",
        [7.5, 7.5, 1.5, 1.0, 3.5, 3.5, 4.5, 6.0, 3.5, 3.0, 9.0, 3.5, 7.0, 4.0, 7.0, 6.5, 9.5]))
    c.append(make_city("Vientiane","Vientiane, Laos","Laos","Asia",17.9757,102.6331,820000,"Sleepy Mekong capital with golden stupas, French bakeries, and Buddhist serenity. One of Asia's most laid-back capitals where life moves at the pace of the river.","",
        [7.5, 8.0, 2.0, 1.0, 4.5, 5.0, 4.0, 6.5, 4.0, 3.5, 6.5, 3.5, 7.5, 5.0, 5.5, 6.0, 5.5]))
    c.append(make_city("Phnom Penh","Phnom Penh, Cambodia","Cambodia","Asia",11.5564,104.9282,2129371,"Rapidly evolving capital blending Khmer heritage with a buzzing riverside cafe scene. From the sobering Killing Fields to glittering Royal Palace, this city tells Cambodia's full story.","",
        [7.5, 8.5, 3.0, 1.5, 6.0, 4.5, 4.5, 5.5, 4.5, 4.0, 5.0, 4.0, 7.5, 5.5, 6.5, 6.0, 5.0]))
    c.append(make_city("Nha Trang","Nha Trang, Khanh Hoa, Vietnam","Vietnam","Asia",12.2388,109.1967,535064,"Coastal resort city famous for pristine beaches, scuba diving, and mud baths. A Vietnamese Riviera where turquoise waters meet a lively waterfront promenade.","",
        [7.5, 8.0, 2.0, 1.0, 5.0, 5.0, 4.5, 7.0, 5.0, 4.0, 7.0, 4.5, 7.5, 5.5, 6.5, 6.0, 7.5]))
    c.append(make_city("Dalat","Da Lat, Lam Dong, Vietnam","Vietnam","Asia",11.9404,108.4583,461030,"Cool highland retreat with French colonial villas, pine forests, and adventure sports. Vietnam's City of Eternal Spring offers waterfalls, flower gardens, and surprisingly great coffee.","",
        [8.0, 8.5, 2.0, 1.0, 4.0, 5.0, 4.5, 8.0, 5.0, 4.5, 8.0, 4.0, 7.5, 5.5, 6.5, 6.5, 8.0]))
    c.append(make_city("Malacca","Malacca City, Malacca, Malaysia","Malaysia","Asia",2.1896,102.2501,579000,"UNESCO-listed historic trading port with unique Peranakan culture and legendary street food. Centuries of Portuguese, Dutch, and British rule created one of Southeast Asia's most culturally layered cities.","",
        [7.0, 7.5, 2.5, 1.5, 5.0, 5.0, 5.5, 7.0, 5.5, 5.0, 6.0, 5.0, 7.0, 6.5, 7.5, 7.0, 5.5]))
    c.append(make_city("Ipoh","Ipoh, Perak, Malaysia","Malaysia","Asia",4.5975,101.0901,657892,"Charming tin-mining town with stunning cave temples, colonial architecture, and famous white coffee. A delicious hidden gem experiencing a renaissance as Malaysia's next foodie destination.","",
        [8.0, 8.0, 2.0, 1.0, 4.5, 5.0, 5.5, 7.5, 5.5, 5.0, 7.0, 5.0, 7.0, 6.0, 6.5, 7.0, 6.5]))
    c.append(make_city("Cameron Highlands","Cameron Highlands, Pahang, Malaysia","Malaysia","Asia",4.4718,101.3767,38000,"Misty Malaysian hill station with rolling tea plantations and strawberry farms. A cool escape from tropical heat with colonial-era bungalows and mossy forest trails.","",
        [7.5, 7.5, 1.5, 1.0, 3.5, 4.0, 5.5, 7.5, 4.0, 3.5, 8.5, 4.0, 7.0, 5.0, 5.5, 7.0, 8.0]))

    c.append(make_city("Lombok","Lombok, West Nusa Tenggara, Indonesia","Indonesia","Asia",-8.6500,116.3249,3352988,"Bali's quieter neighbor with pristine beaches, Mount Rinjani volcano, and traditional Sasak villages. An unspoiled paradise offering world-class surf and the stunning Gili Islands.","",
        [8.0, 8.0, 1.5, 1.0, 4.5, 4.0, 4.5, 6.5, 4.0, 3.5, 8.5, 3.5, 7.0, 4.5, 6.5, 6.0, 9.0]))
    c.append(make_city("Flores","Flores, East Nusa Tenggara, Indonesia","Indonesia","Asia",-8.6574,121.0794,1831000,"Wild eastern island home to Komodo dragons, volcanic lakes, and traditional villages. An adventurous destination where the tri-colored Kelimutu crater lakes change hues with the seasons.","",
        [8.0, 8.5, 1.0, 1.0, 3.0, 3.5, 4.0, 6.5, 3.0, 3.0, 9.0, 3.0, 7.0, 3.5, 6.0, 6.0, 9.5]))
    c.append(make_city("Siargao","Siargao, Surigao del Norte, Philippines","Philippines","Asia",9.8482,126.0458,50053,"Teardrop-shaped surfing paradise with laid-back island vibes and mangrove forests. Cloud 9's famous barrel wave draws surfers worldwide while lagoons and rock pools enchant everyone else.","",
        [7.5, 8.0, 1.0, 1.0, 3.0, 3.5, 4.5, 6.0, 3.0, 2.5, 8.5, 3.0, 7.0, 4.0, 6.5, 6.5, 9.0]))
    c.append(make_city("Battambang","Battambang, Cambodia","Cambodia","Asia",13.1023,103.1986,196709,"Charming riverside town with French colonial architecture and bamboo train rides. Cambodia's best-kept secret offers Angkor-era temples, bat caves, and an emerging art scene.","",
        [8.5, 9.0, 1.5, 1.0, 3.5, 5.0, 4.5, 6.5, 3.5, 3.5, 7.0, 3.5, 8.0, 4.5, 5.5, 6.0, 6.0]))
    c.append(make_city("Pai","Pai, Mae Hong Son, Thailand","Thailand","Asia",19.3592,98.4422,24152,"Bohemian mountain town with hot springs, waterfalls, and a thriving backpacker scene. A dreamy valley village where the vibe is mellow and the rice paddies are golden.","",
        [8.5, 8.5, 1.0, 1.0, 3.0, 4.0, 5.0, 7.0, 3.5, 2.5, 9.0, 3.0, 7.5, 5.0, 6.5, 7.0, 9.0]))
    c.append(make_city("Koh Lanta","Koh Lanta, Krabi, Thailand","Thailand","Asia",7.5350,99.0628,31343,"Relaxed island with long beaches, mangroves, and Old Town fishing village charm. A family-friendly alternative to Phuket's party scene with spectacular sunsets over the Andaman.","",
        [7.5, 7.5, 1.0, 1.0, 3.5, 4.0, 5.0, 7.5, 3.5, 3.0, 8.5, 3.5, 7.5, 5.0, 6.0, 6.5, 8.5]))
    c.append(make_city("Bagan","Bagan, Mandalay Region, Myanmar","Myanmar","Asia",21.1717,94.8585,46000,"Ancient city of 2000+ Buddhist temples and pagodas stretching across a vast dusty plain. Sunrise balloon rides over this temple-studded landscape create unforgettable memories.","",
        [8.0, 9.0, 1.0, 1.0, 3.0, 4.0, 3.0, 5.0, 3.0, 2.5, 7.5, 2.5, 7.0, 3.0, 7.5, 5.5, 7.0]))
    c.append(make_city("Chiang Rai","Chiang Rai, Thailand","Thailand","Asia",19.9105,99.8406,79400,"Northern Thai city home to the dazzling White Temple and vibrant hill tribe cultures. A cooler, quieter alternative to Chiang Mai with the stunning Golden Triangle nearby.","",
        [8.5, 8.5, 2.0, 1.0, 4.5, 5.0, 5.0, 7.5, 5.0, 4.0, 8.0, 4.0, 7.5, 5.5, 6.5, 6.5, 7.5]))
    return c


def get_east_asia():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Fukuoka","Fukuoka, Kyushu, Japan","Japan","Asia",33.5904,130.4017,1603043,"Gateway to Kyushu with legendary ramen, vibrant yatai street stalls, and beach culture. A modern city that perfectly balances urban energy with laid-back coastal vibes.","",
        [5.0, 5.5, 5.5, 3.5, 7.0, 7.0, 6.0, 9.0, 8.0, 7.5, 7.5, 7.0, 6.0, 8.5, 8.0, 7.0, 7.0]))
    c.append(make_city("Sapporo","Sapporo, Hokkaido, Japan","Japan","Asia",43.0618,141.3545,1973395,"Snow festival city offering world-class skiing, fresh seafood, and craft beer scene. Hokkaido's capital delivers powder snow in winter and lavender fields in summer.","",
        [5.5, 5.0, 4.5, 3.0, 6.5, 7.0, 6.0, 9.0, 8.0, 7.5, 8.0, 6.5, 6.0, 8.0, 7.5, 7.0, 9.0]))
    c.append(make_city("Okinawa","Okinawa, Japan","Japan","Asia",26.3344,127.8056,318000,"Subtropical island chain blending unique Ryukyu culture with pristine beaches. Japan's tropical paradise offers turquoise waters, coral reefs, and a laid-back pace of life.","",
        [6.0, 5.5, 2.0, 1.5, 5.5, 5.0, 5.5, 9.0, 7.0, 6.0, 8.5, 5.5, 6.0, 7.0, 7.0, 7.0, 9.0]))
    c.append(make_city("Hiroshima","Hiroshima, Japan","Japan","Asia",34.3853,132.4553,1194507,"Resilient city of peace with iconic memorial, incredible okonomiyaki, and nearby Miyajima island. A deeply moving destination that emerged from tragedy to become a beacon of hope.","",
        [5.5, 5.5, 4.0, 2.5, 7.0, 7.0, 6.0, 9.0, 8.0, 7.0, 7.0, 7.0, 6.0, 8.0, 7.5, 7.0, 6.5]))
    c.append(make_city("Kanazawa","Kanazawa, Ishikawa, Japan","Japan","Asia",36.5613,136.6562,462361,"Beautifully preserved Edo-era castle town with one of Japan's finest gardens. Kenroku-en Garden, geisha districts, and gold-leaf artisan culture make this a cultural treasure.","",
        [5.5, 5.5, 3.0, 2.0, 5.5, 6.5, 6.0, 9.0, 7.5, 7.0, 7.5, 6.5, 6.0, 7.5, 8.0, 7.0, 7.0]))
    c.append(make_city("Nara","Nara, Japan","Japan","Asia",34.6851,135.8048,354630,"Ancient capital where sacred deer roam freely among stunning 8th-century temples. Home to the world's largest bronze Buddha and some of Japan's oldest wooden structures.","",
        [5.5, 5.5, 3.0, 2.0, 6.5, 6.5, 6.0, 9.0, 7.5, 7.0, 8.0, 6.5, 6.0, 7.5, 8.5, 7.0, 7.5]))
    c.append(make_city("Hakone","Hakone, Kanagawa, Japan","Japan","Asia",35.2326,139.1070,11000,"Hot spring resort town with views of Mount Fuji, volcanic valleys, and open-air museums. A beloved weekend escape from Tokyo with steaming onsen, pirate ships, and mountain cable cars.","",
        [4.5, 4.0, 1.5, 1.0, 5.5, 5.0, 5.5, 9.0, 6.5, 5.0, 9.0, 5.5, 6.0, 6.5, 7.0, 7.0, 9.0]))
    c.append(make_city("Kamakura","Kamakura, Kanagawa, Japan","Japan","Asia",35.3192,139.5466,172302,"Seaside town with Great Buddha statue, ancient temples, and excellent hiking trails. A coastal gem just an hour from Tokyo with surf beaches, zen temples, and forest walks.","",
        [4.5, 4.5, 2.5, 1.5, 6.5, 6.0, 6.0, 9.0, 7.5, 7.0, 8.5, 6.5, 6.0, 7.5, 7.5, 7.0, 8.5]))
    c.append(make_city("Takayama","Takayama, Gifu, Japan","Japan","Asia",36.1460,137.2520,86140,"Beautifully preserved mountain town famous for sake breweries and stunning festivals. Old merchant houses, morning markets, and Hida beef make this Alpine town irresistible.","",
        [5.5, 5.5, 1.5, 1.0, 4.5, 5.0, 5.5, 9.0, 6.5, 5.5, 9.0, 5.0, 6.0, 6.5, 7.5, 7.0, 8.5]))
    c.append(make_city("Naoshima","Naoshima, Kagawa, Japan","Japan","Asia",34.4612,133.9953,3100,"Tiny art island with world-renowned contemporary art museums set in stunning nature. Tadao Ando's architectural masterpieces dot this Inland Sea island where art and nature merge.","",
        [5.0, 5.0, 1.5, 1.0, 3.5, 4.0, 5.5, 9.0, 5.0, 4.0, 9.0, 4.0, 6.0, 5.5, 9.0, 7.0, 8.0]))

    c.append(make_city("Beppu","Beppu, Oita, Japan","Japan","Asia",33.2846,131.4914,115321,"Steaming hot spring capital of Japan with eight distinct geothermal hells to explore. A surreal city where volcanic steam rises from streets, gardens, and mountainsides everywhere you look.","",
        [6.0, 5.5, 1.5, 1.0, 5.0, 5.5, 5.5, 9.0, 7.0, 5.5, 7.5, 5.0, 6.0, 6.5, 7.0, 7.0, 7.5]))
    c.append(make_city("Jeju","Jeju Island, South Korea","South Korea","Asia",33.4996,126.5312,697578,"Volcanic island paradise with lava tubes, tangerine orchards, and female free-divers. South Korea's Hawaii boasts dramatic coastlines, waterfalls, and the volcanic Hallasan peak.","",
        [5.0, 5.5, 3.0, 2.0, 6.0, 5.5, 6.0, 8.5, 7.5, 6.5, 8.5, 6.0, 6.5, 8.0, 7.5, 6.5, 8.5]))
    c.append(make_city("Gyeongju","Gyeongju, North Gyeongsang, South Korea","South Korea","Asia",35.8562,129.2247,258218,"Open-air museum city with royal Silla dynasty tombs and ancient Buddhist temples. Thousand-year-old capital with grassy burial mounds, pagodas, and Korea's finest historical treasures.","",
        [6.5, 6.0, 2.0, 1.5, 5.0, 5.5, 6.0, 8.5, 7.0, 6.0, 7.5, 5.5, 6.5, 7.5, 8.0, 6.5, 7.0]))
    c.append(make_city("Kaohsiung","Kaohsiung, Taiwan","Taiwan","Asia",22.6273,120.3014,2722287,"Harbor city with stunning arts district, night markets, and gateway to Kenting beaches. Taiwan's second city is an urban renewal success story with world-class public art.","",
        [7.0, 6.5, 4.5, 3.0, 6.5, 6.5, 6.5, 8.5, 7.5, 7.0, 6.5, 6.5, 7.0, 8.5, 7.5, 7.5, 7.0]))
    c.append(make_city("Tainan","Tainan, Taiwan","Taiwan","Asia",22.9998,120.2269,1873005,"Taiwan's oldest city packed with ornate temples, incredible street food, and rich history. The food capital of Taiwan where every alley hides another legendary snack or noodle shop.","",
        [7.0, 6.5, 4.0, 2.5, 6.0, 6.0, 6.5, 8.5, 7.5, 7.0, 6.5, 6.5, 7.0, 8.0, 8.0, 7.5, 6.0]))
    c.append(make_city("Hualien","Hualien, Taiwan","Taiwan","Asia",23.9872,121.6016,331472,"Gateway to Taroko Gorge's marble canyons with indigenous culture and Pacific coast beauty. A dramatic meeting of mountains and ocean where marble-walled gorges take your breath away.","",
        [7.0, 6.5, 2.0, 1.5, 5.0, 5.5, 6.5, 8.5, 6.5, 6.0, 9.0, 5.5, 7.0, 7.0, 7.0, 7.5, 9.5]))
    c.append(make_city("Macau","Macau, China","China","Asia",22.1987,113.5439,682800,"Glittering casino city with Portuguese colonial heritage and legendary Cantonese cuisine. A unique East-meets-West enclave where ornate churches stand beside Chinese temples and mega-casinos.","",
        [3.0, 3.5, 3.5, 3.0, 7.0, 7.0, 6.0, 8.0, 7.0, 6.5, 5.0, 7.5, 8.0, 7.5, 8.0, 6.5, 4.0]))
    c.append(make_city("Guilin","Guilin, Guangxi, China","China","Asia",25.2740,110.2900,4931137,"Karst mountain paradise with the iconic Li River cruise and centuries of landscape paintings. The scenery that inspired a thousand Chinese paintings awaits with bamboo rafts and misty peaks.","",
        [7.5, 7.0, 2.5, 1.5, 5.5, 5.0, 4.5, 7.5, 5.5, 5.0, 8.5, 5.0, 6.5, 6.0, 7.0, 5.5, 9.0]))
    c.append(make_city("Lijiang","Lijiang, Yunnan, China","China","Asia",26.8721,100.2299,1245000,"Ancient Naxi town beneath snow-capped Jade Dragon Mountain with UNESCO Old Town. Cobblestone canals wind through a charming old town backed by dramatic Himalayan peaks.","",
        [7.0, 7.0, 1.5, 1.0, 4.5, 5.0, 4.5, 7.5, 5.0, 4.5, 8.0, 4.5, 6.5, 5.5, 7.5, 5.5, 8.5]))
    c.append(make_city("Kunming","Kunming, Yunnan, China","China","Asia",25.0389,102.7183,8460088,"Spring City with year-round pleasant climate and gateway to Yunnan's incredible diversity. A relaxed capital surrounded by ethnic minority cultures, stone forests, and alpine lakes.","",
        [6.5, 7.0, 3.5, 2.0, 6.5, 5.5, 4.5, 7.0, 6.0, 6.0, 7.0, 5.5, 6.5, 6.5, 6.5, 5.5, 7.0]))
    c.append(make_city("Xiamen","Xiamen, Fujian, China","China","Asia",24.4798,118.0894,5163970,"Charming coastal city with car-free Gulangyu Island and vibrant Hokkien culture. A garden city on the sea with colonial architecture, temple incense, and incredible seafood.","",
        [5.5, 6.0, 4.0, 2.5, 6.5, 6.0, 4.5, 8.0, 6.5, 6.5, 7.0, 6.5, 6.5, 7.0, 7.0, 5.5, 7.0]))
    c.append(make_city("Dali","Dali, Yunnan, China","China","Asia",25.6065,100.2679,652000,"Bohemian lakeside town with Bai minority culture, marble mountains, and three pagodas. A backpacker favorite where ancient walls frame stunning Erhai Lake and Cangshan peaks.","",
        [7.5, 7.5, 1.5, 1.0, 4.0, 4.5, 4.5, 7.5, 4.5, 4.0, 8.5, 4.0, 6.5, 5.5, 7.0, 5.5, 8.5]))
    c.append(make_city("Zhangjiajie","Zhangjiajie, Hunan, China","China","Asia",29.1170,110.4792,1523680,"Towering sandstone pillars that inspired Avatar's floating mountains in a stunning national park. Glass skywalks and the world's longest cable car add thrills to this surreal landscape.","",
        [7.5, 7.0, 1.5, 1.0, 4.5, 4.5, 4.5, 7.5, 5.0, 4.5, 9.0, 4.5, 6.5, 5.5, 6.0, 5.5, 9.5]))
    return c


def get_south_asia():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Goa","Goa, India","India","Asia",15.2993,74.1240,1458545,"Beach paradise blending Portuguese colonial charm with psychedelic trance culture and seafood. From sunset yoga on the cliffs to all-night beach parties, Goa has been drawing travelers for decades.","",
        [7.5, 8.0, 2.5, 1.5, 5.5, 4.5, 5.0, 6.5, 5.0, 4.5, 7.0, 4.5, 7.0, 5.5, 7.5, 6.0, 8.0]))
    c.append(make_city("Jaipur","Jaipur, Rajasthan, India","India","Asia",26.9124,75.7873,3073350,"Pink City of magnificent forts, ornate palaces, and vibrant bazaars in Rajasthan. Every corner reveals intricate architecture, from Hawa Mahal's honeycomb facade to Amber Fort's grandeur.","",
        [7.5, 8.0, 3.5, 2.0, 6.5, 4.5, 5.0, 6.0, 5.5, 5.5, 5.0, 5.0, 6.5, 6.0, 8.0, 5.5, 5.5]))
    c.append(make_city("Udaipur","Udaipur, Rajasthan, India","India","Asia",24.5854,73.7125,474531,"City of Lakes with floating palaces, romantic boat rides, and Rajasthani grandeur. Often called the Venice of the East, this royal city shimmers with lakeside palaces and hilltop temples.","",
        [7.5, 8.0, 2.0, 1.5, 5.0, 5.0, 5.0, 6.5, 5.0, 4.5, 6.5, 4.5, 6.5, 5.5, 8.0, 5.5, 6.5]))
    c.append(make_city("Kathmandu","Kathmandu, Nepal","Nepal","Asia",27.7172,85.3240,1442271,"Chaotic Himalayan capital with ancient stupas, prayer flags, and trekking base camps. A sensory whirlwind of incense, temple bells, and narrow alleys leading to hidden courtyards.","",
        [7.5, 8.0, 2.5, 1.5, 5.5, 3.5, 4.5, 5.5, 4.5, 4.5, 4.5, 4.0, 7.0, 5.0, 7.0, 6.0, 7.5]))
    c.append(make_city("Pokhara","Pokhara, Gandaki, Nepal","Nepal","Asia",28.2096,83.9856,518452,"Serene lakeside city with Annapurna views and gateway to world-famous Himalayan treks. Phewa Lake reflects snowcapped peaks while paragliders soar overhead in this adventure hub.","",
        [8.0, 8.5, 1.5, 1.0, 4.5, 4.5, 4.5, 6.5, 4.0, 3.5, 8.0, 3.5, 7.0, 5.0, 6.5, 6.5, 9.5]))
    c.append(make_city("Colombo","Colombo, Sri Lanka","Sri Lanka","Asia",6.9271,79.8612,752993,"Coastal capital mixing colonial heritage with modern dining, temples, and tropical energy. A city reborn with rooftop bars, street food tours, and the iconic Galle Face Green promenade.","",
        [6.5, 7.0, 3.0, 2.0, 6.5, 4.0, 5.0, 6.0, 5.5, 5.5, 5.5, 5.0, 6.5, 6.0, 6.5, 6.0, 5.5]))
    c.append(make_city("Galle","Galle, Southern Province, Sri Lanka","Sri Lanka","Asia",6.0535,80.2210,99478,"Atmospheric fort city with Dutch colonial ramparts, boutique hotels, and Indian Ocean sunsets. UNESCO-listed walls enclose a charming grid of cafes, galleries, and colonial-era churches.","",
        [7.0, 7.5, 1.5, 1.0, 5.0, 5.0, 5.0, 7.0, 4.5, 4.0, 7.5, 4.5, 6.5, 5.5, 7.5, 6.0, 7.5]))
    c.append(make_city("Kandy","Kandy, Central Province, Sri Lanka","Sri Lanka","Asia",7.2906,80.6337,111701,"Hill country gem with the sacred Temple of the Tooth and lush botanical gardens. Sri Lanka's cultural capital sits amid misty mountains, tea estates, and sacred Buddhist heritage.","",
        [7.0, 7.5, 1.5, 1.0, 5.0, 4.5, 5.0, 7.0, 5.0, 5.0, 8.0, 4.5, 6.5, 5.5, 7.5, 6.0, 8.0]))
    c.append(make_city("Ella","Ella, Uva Province, Sri Lanka","Sri Lanka","Asia",6.8667,81.0466,44700,"Misty mountain village with dramatic train rides, tea plantations, and stunning hiking. The scenic railway journey to Ella through green hills and bridges is one of Asia's greatest train rides.","",
        [7.5, 8.0, 1.0, 1.0, 3.0, 4.0, 5.0, 7.5, 3.5, 3.0, 9.0, 3.5, 6.5, 4.5, 6.0, 6.0, 9.5]))
    c.append(make_city("Pondicherry","Pondicherry, Tamil Nadu, India","India","Asia",11.9416,79.8083,244377,"French colonial enclave with colorful streets, Sri Aurobindo ashram, and Tamil culture. Bougainvillea-draped streets in the French Quarter contrast with vibrant Tamil bazaars just blocks away.","",
        [7.5, 8.0, 2.0, 1.0, 4.5, 5.0, 5.0, 7.0, 5.0, 5.0, 6.5, 4.5, 6.5, 5.5, 7.0, 6.0, 6.0]))
    c.append(make_city("Varanasi","Varanasi, Uttar Pradesh, India","India","Asia",25.3176,83.0068,1201815,"World's oldest living city with sacred Ganges ghats, evening fire ceremonies, and spiritual intensity. Life, death, and rebirth unfold along the holy river in humanity's most ancient pilgrimage city.","",
        [7.5, 8.5, 2.0, 1.0, 5.5, 3.5, 4.5, 5.5, 4.5, 5.0, 4.0, 4.0, 6.5, 5.0, 8.5, 5.0, 4.5]))
    c.append(make_city("Hampi","Hampi, Karnataka, India","India","Asia",15.3350,76.4600,2777,"Surreal boulder-strewn landscape scattered with ruins of a once-mighty empire. The crumbling Vijayanagara capital sprawls among giant boulders beside a sacred river in otherworldly beauty.","",
        [8.5, 9.0, 1.0, 1.0, 3.0, 3.5, 4.5, 6.5, 3.0, 2.5, 8.0, 3.0, 6.5, 3.5, 7.5, 5.5, 8.5]))
    c.append(make_city("Kochi","Kochi, Kerala, India","India","Asia",9.9312,76.2673,602046,"Charming port city with Chinese fishing nets, spice markets, and Kerala backwater access. A cosmopolitan trading hub for centuries, now delighting visitors with its Biennale art scene.","",
        [7.0, 7.5, 3.0, 1.5, 5.5, 4.5, 5.0, 7.0, 5.5, 5.5, 6.5, 5.0, 6.5, 6.0, 7.5, 6.5, 7.0]))
    return c


def get_europe_1():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Dubrovnik","Dubrovnik, Croatia","Croatia","Europe",42.6507,18.0944,42615,"Walled Mediterranean jewel and Game of Thrones filming location perched above the Adriatic. Walk the ancient ramparts for breathtaking views of terracotta roofs and azure seas.","",
        [4.0, 4.0, 2.5, 1.5, 6.0, 6.0, 5.5, 8.5, 6.5, 5.5, 8.0, 5.5, 6.0, 7.0, 8.5, 7.0, 8.0]))
    c.append(make_city("Kotor","Kotor, Montenegro","Montenegro","Europe",42.4247,18.7712,13510,"Dramatic fjord-like bay with Venetian old town and serpentine fortress walls. Climb 1,350 steps to the fortress for jaw-dropping views of Europe's southernmost fjord.","",
        [6.0, 6.5, 1.5, 1.0, 4.5, 5.5, 5.0, 8.0, 5.0, 4.5, 9.0, 4.5, 7.0, 6.0, 7.5, 6.5, 9.0]))
    c.append(make_city("Hallstatt","Hallstatt, Upper Austria, Austria","Austria","Europe",47.5622,13.6493,778,"Fairy-tale lakeside village nestled in the Austrian Alps with ancient salt mines. This impossibly picturesque hamlet is so beautiful it was replicated in full in China.","",
        [3.0, 3.5, 1.0, 1.0, 4.0, 4.5, 6.5, 9.0, 7.5, 6.0, 9.5, 6.0, 5.5, 7.0, 7.0, 8.0, 9.5]))
    c.append(make_city("Bruges","Bruges, West Flanders, Belgium","Belgium","Europe",51.2093,3.2247,118284,"Perfectly preserved medieval city of canals, chocolate shops, and Gothic architecture. Cobblestone lanes wind past gabled houses, craft beer pubs, and serene swan-filled canals.","",
        [4.0, 4.0, 3.0, 2.0, 7.0, 7.0, 7.0, 8.5, 8.0, 7.5, 7.5, 7.0, 5.5, 8.0, 8.5, 8.5, 6.0]))
    c.append(make_city("Cinque Terre","Cinque Terre, Liguria, Italy","Italy","Europe",44.1461,9.6560,4000,"Five colorful clifftop fishing villages connected by hiking trails above the Italian Riviera. Car-free hamlets cascade down rugged coastal cliffs with vineyards and azure Mediterranean views.","",
        [3.5, 3.5, 1.0, 1.0, 5.0, 4.0, 5.5, 8.0, 6.5, 5.0, 9.0, 5.0, 5.5, 6.0, 8.0, 7.5, 9.5]))
    c.append(make_city("Amalfi","Amalfi, Campania, Italy","Italy","Europe",40.6340,14.6027,5116,"Dramatic coastal town on Italy's most famous stretch of Mediterranean coastline. A former maritime republic with a stunning cathedral, lemon groves, and winding cliffside roads.","",
        [3.0, 3.0, 1.0, 1.0, 5.0, 4.0, 5.5, 7.5, 6.5, 5.0, 8.5, 5.0, 5.5, 6.0, 8.0, 7.5, 8.5]))
    c.append(make_city("Positano","Positano, Campania, Italy","Italy","Europe",40.6281,14.4842,3850,"Pastel-colored vertical village cascading down cliffs to a pebble beach on the Amalfi Coast. Instagram's favorite Italian town delivers la dolce vita with style, glamour, and limoncello.","",
        [2.5, 2.5, 1.0, 1.0, 4.5, 3.5, 5.5, 7.5, 6.0, 4.5, 8.5, 5.0, 5.5, 6.0, 8.0, 7.5, 8.0]))
    c.append(make_city("Lake Como","Lake Como, Lombardy, Italy","Italy","Europe",45.9876,9.2572,84000,"Glamorous Alpine lake surrounded by palatial villas, gardens, and mountain trails. George Clooney's neighborhood features opulent Belle Epoque villas and stunning mountain-lake scenery.","",
        [2.5, 2.5, 2.0, 1.5, 6.0, 5.0, 6.0, 8.5, 7.5, 6.5, 9.0, 6.5, 5.0, 7.0, 8.0, 8.0, 9.0]))
    c.append(make_city("Santorini","Santorini, South Aegean, Greece","Greece","Europe",36.3932,25.4615,15550,"Iconic white-washed caldera village with stunning sunsets and volcanic beaches. Blue-domed churches perch on dramatic cliffs above a flooded volcanic crater in this Cycladic dream.","",
        [3.0, 3.0, 1.5, 1.0, 5.5, 4.5, 5.0, 8.0, 5.5, 4.5, 8.5, 5.0, 6.0, 6.0, 8.5, 7.0, 8.0]))
    c.append(make_city("Mykonos","Mykonos, South Aegean, Greece","Greece","Europe",37.4467,25.3289,10134,"Glamorous Cycladic island known for windmills, beach clubs, and legendary nightlife. The cosmopolitan party island of the Mediterranean with dazzling white architecture and turquoise coves.","",
        [2.5, 2.5, 1.5, 1.0, 5.5, 4.5, 5.0, 7.5, 5.0, 4.0, 7.5, 5.0, 6.0, 6.0, 8.5, 8.0, 7.0]))
    c.append(make_city("Crete","Crete, Greece","Greece","Europe",35.2401,24.4709,623065,"Largest Greek island with Minoan palaces, dramatic gorges, and incredible cuisine. From the ancient ruins of Knossos to the stunning Samaria Gorge, Crete offers unmatched diversity.","",
        [5.5, 5.5, 2.0, 1.5, 6.0, 5.0, 5.0, 8.0, 6.0, 5.5, 8.5, 5.0, 6.0, 6.5, 8.0, 7.0, 9.0]))
    c.append(make_city("Rhodes","Rhodes, South Aegean, Greece","Greece","Europe",36.4349,28.2176,115490,"Medieval walled city with ancient history, beautiful beaches, and year-round sunshine. Knights of St. John left an incredible medieval town that rivals any Game of Thrones set.","",
        [5.5, 5.5, 1.5, 1.0, 5.5, 5.0, 5.0, 8.0, 5.5, 5.0, 8.0, 5.0, 6.0, 6.0, 7.5, 7.0, 8.0]))
    c.append(make_city("Corfu","Corfu, Ionian Islands, Greece","Greece","Europe",39.6243,19.9217,102071,"Lush Venetian-influenced island with olive groves, crystal waters, and elegant architecture. A greener, more romantic Greek island with Italianate old town and Durrell family history.","",
        [5.5, 5.5, 1.5, 1.0, 5.5, 5.0, 5.0, 8.0, 5.5, 5.0, 8.5, 4.5, 6.0, 6.0, 7.5, 7.0, 8.5]))
    c.append(make_city("Antalya","Antalya, Turkey","Turkey","Europe",36.8969,30.7133,2619832,"Turkish Riviera hub with Roman ruins, pristine beaches, and dramatic Taurus Mountains. Ancient Aspendos theater and the old harbor Kaleici district anchor this sun-drenched coast.","",
        [6.5, 7.0, 3.0, 2.0, 7.0, 5.5, 5.0, 7.0, 6.5, 6.0, 7.0, 5.5, 6.5, 7.0, 7.5, 6.0, 8.0]))
    c.append(make_city("Cappadocia","Goreme, Nevsehir, Turkey","Turkey","Europe",38.6431,34.8289,89000,"Surreal fairy-chimney landscape famous for hot air balloon rides and cave hotels. Hundreds of colorful balloons floating over ancient rock formations create the world's most iconic sunrise.","",
        [7.5, 7.5, 1.5, 1.0, 4.5, 4.5, 5.0, 7.5, 5.0, 4.0, 8.5, 4.5, 6.5, 5.5, 8.0, 6.0, 8.5]))
    c.append(make_city("Bodrum","Bodrum, Mugla, Turkey","Turkey","Europe",37.0343,27.4305,175000,"Aegean resort town with ancient Mausoleum ruins, white houses, and vibrant marina. A stylish Turkish Riviera destination where ancient history meets contemporary beach club culture.","",
        [5.5, 5.5, 2.0, 1.5, 6.0, 5.0, 5.0, 7.0, 6.0, 5.0, 7.5, 5.5, 6.5, 6.5, 7.5, 6.5, 7.5]))
    return c


def get_europe_2():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Faro","Faro, Algarve, Portugal","Portugal","Europe",37.0194,-7.9322,64560,"Algarve gateway with medieval old town and access to stunning cliff-lined beaches. A charming university city where the Ria Formosa lagoon meets golden Algarve coastline.","",
        [5.5, 5.5, 2.5, 1.5, 6.0, 5.5, 6.0, 8.0, 6.5, 6.0, 8.0, 5.5, 6.5, 7.0, 7.0, 7.5, 8.5]))
    c.append(make_city("Sintra","Sintra, Lisbon District, Portugal","Portugal","Europe",38.7981,-9.3880,377835,"Romantic hilltop town with colorful fairy-tale palaces nestled in misty forests. Lord Byron called it a glorious Eden, and the whimsical Pena Palace proves him right.","",
        [4.5, 4.5, 2.0, 1.5, 7.0, 6.0, 6.0, 8.0, 7.0, 6.5, 8.5, 6.0, 6.0, 7.0, 8.0, 7.5, 8.0]))
    c.append(make_city("San Sebastian","San Sebastian, Basque Country, Spain","Spain","Europe",43.3183,-1.9812,187415,"Basque culinary capital with stunning La Concha beach and more Michelin stars per capita than Paris. A perfect pairing of world-class pintxos bars and one of Europe's best urban beaches.","",
        [3.0, 3.0, 3.5, 2.0, 6.5, 7.0, 6.5, 8.5, 8.0, 7.5, 8.0, 7.0, 5.5, 8.0, 9.0, 8.0, 8.0]))
    c.append(make_city("Lucerne","Lucerne, Switzerland","Switzerland","Europe",47.0502,8.3093,82257,"Storybook Swiss city with Chapel Bridge, lake cruises, and Mount Pilatus access. Medieval covered bridge, crystal-clear lake, and snow-capped peaks create a perfect Alpine postcard.","",
        [2.0, 2.0, 4.0, 3.0, 7.5, 7.5, 7.5, 9.5, 9.0, 8.0, 9.0, 8.0, 5.0, 9.0, 8.0, 8.5, 9.5]))
    c.append(make_city("Interlaken","Interlaken, Bern, Switzerland","Switzerland","Europe",46.6863,7.8632,5300,"Adventure capital between two Alpine lakes with paragliding, skiing, and Jungfrau views. The ultimate adrenaline hub where you can skydive, canyon, and bungee with Alpine peaks all around.","",
        [2.0, 2.0, 1.5, 1.0, 6.0, 5.0, 7.5, 9.5, 8.0, 6.0, 9.5, 7.0, 5.0, 8.0, 7.0, 8.5, 10.0]))
    c.append(make_city("Colmar","Colmar, Alsace, France","France","Europe",48.0794,7.3558,71018,"Fairy-tale Alsatian town with half-timbered houses and renowned white wine route. Pastel-colored medieval buildings line canals in a town that inspired Beauty and the Beast.","",
        [4.5, 4.5, 2.0, 1.5, 6.0, 6.0, 6.5, 8.5, 8.0, 7.0, 8.0, 6.5, 5.5, 7.5, 8.0, 8.0, 7.0]))
    c.append(make_city("Lake Bled","Bled, Upper Carniola, Slovenia","Slovenia","Europe",46.3683,14.1146,7868,"Postcard-perfect Alpine lake with island church, hilltop castle, and cream cake. A tiny emerald lake with a fairy-tale island and Julian Alps reflection that seems too perfect to be real.","",
        [5.0, 5.5, 1.5, 1.0, 5.5, 5.0, 6.0, 9.0, 7.0, 6.0, 9.5, 5.5, 6.0, 7.0, 7.0, 8.0, 9.5]))
    c.append(make_city("Mostar","Mostar, Herzegovina-Neretva, Bosnia and Herzegovina","Bosnia and Herzegovina","Europe",43.3438,17.8078,113169,"Ottoman bridge town famous for dramatic cliff diving and East-meets-West heritage. The reconstructed Stari Most bridge spans emerald waters in a city rebuilding with grace and beauty.","",
        [7.5, 7.5, 1.5, 1.0, 4.5, 5.0, 5.0, 7.0, 5.0, 5.0, 7.5, 4.5, 6.5, 6.0, 7.5, 6.0, 7.5]))
    c.append(make_city("Sibenik","Sibenik, Sibenik-Knin, Croatia","Croatia","Europe",43.7350,15.8952,46332,"Medieval Dalmatian city with UNESCO cathedral and gateway to Krka waterfalls. A less-crowded Croatian gem with Game of Thrones connections and stunning national parks nearby.","",
        [5.5, 5.5, 2.0, 1.0, 5.0, 5.5, 5.5, 8.5, 6.0, 5.5, 8.0, 5.0, 6.0, 6.5, 7.0, 7.0, 8.5]))
    c.append(make_city("Hvar","Hvar, Split-Dalmatia, Croatia","Croatia","Europe",43.1729,16.4411,11103,"Sun-soaked Dalmatian island with lavender fields, Renaissance architecture, and yacht scene. Croatia's sunniest island offers ancient walls, secluded coves, and sophisticated nightlife.","",
        [4.0, 4.0, 1.5, 1.0, 4.5, 4.5, 5.5, 8.5, 5.5, 4.5, 8.5, 5.0, 6.0, 6.0, 8.0, 7.0, 8.5]))
    c.append(make_city("Cesky Krumlov","Cesky Krumlov, South Bohemia, Czech Republic","Czech Republic","Europe",48.8127,14.3175,13100,"Enchanting Bohemian town with Renaissance castle and meandering Vltava River. A perfectly preserved medieval town where you can kayak through the old center under castle towers.","",
        [5.5, 5.5, 1.5, 1.0, 5.0, 5.5, 6.0, 8.5, 7.0, 6.0, 8.5, 5.5, 6.0, 7.0, 8.0, 7.5, 7.5]))
    c.append(make_city("Tromso","Tromso, Troms, Norway","Norway","Europe",69.6492,18.9553,77544,"Arctic gateway for Northern Lights, midnight sun, and Arctic Cathedral. The world's northernmost university city offers whale watching, dog sledding, and aurora borealis.","",
        [3.0, 2.5, 2.5, 1.5, 5.0, 6.0, 7.5, 9.0, 8.5, 7.5, 9.0, 7.5, 5.0, 8.5, 7.0, 9.0, 9.0]))
    c.append(make_city("Lofoten","Lofoten Islands, Nordland, Norway","Norway","Europe",68.2000,14.0000,24500,"Dramatic Arctic archipelago with fishing villages, Viking history, and midnight sun surfing. Red fishermen's cabins dot jagged peaks rising from Arctic waters in this otherworldly landscape.","",
        [3.5, 2.5, 1.0, 1.0, 3.5, 4.0, 7.0, 9.0, 6.5, 5.5, 9.5, 6.5, 5.0, 6.5, 7.0, 9.0, 10.0]))
    c.append(make_city("Rovaniemi","Rovaniemi, Lapland, Finland","Finland","Europe",66.5039,25.7294,63479,"Official hometown of Santa Claus on the Arctic Circle with Northern Lights and reindeer safaris. Cross the Arctic Circle, meet Santa, and chase the aurora in Finland's winter wonderland.","",
        [4.5, 3.5, 2.0, 1.5, 5.0, 5.5, 7.5, 9.0, 8.0, 7.0, 9.0, 6.5, 5.0, 8.0, 6.5, 9.0, 9.0]))
    c.append(make_city("Valletta","Valletta, Malta","Malta","Europe",35.8989,14.5146,5827,"Tiny Baroque fortress capital packed with knights' heritage and Mediterranean views. The EU's smallest capital city packs grand palaces, churches, and harbor views into a compact peninsula.","",
        [4.5, 5.0, 3.0, 2.0, 6.5, 6.5, 6.5, 8.5, 7.0, 6.5, 7.0, 6.5, 6.5, 7.5, 8.0, 7.0, 6.5]))
    c.append(make_city("Batumi","Batumi, Adjara, Georgia","Georgia","Europe",41.6168,41.6367,180000,"Black Sea resort city with botanical gardens, modern architecture, and Georgian hospitality. A surprising party city on the Black Sea with stunning architecture and legendary wine culture.","",
        [7.5, 8.0, 2.0, 1.5, 5.0, 5.5, 5.5, 7.0, 5.5, 5.0, 7.5, 4.5, 7.0, 6.5, 7.0, 6.0, 7.0]))
    return c


def get_middle_east():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Petra","Petra, Ma'an, Jordan","Jordan","Asia",30.3285,35.4444,32460,"Ancient Nabataean city carved into rose-red cliffs and one of the New Seven Wonders. Walking through the narrow Siq canyon to glimpse the Treasury facade is a bucket-list moment.","",
        [7.0, 7.0, 1.0, 1.0, 4.0, 4.0, 5.0, 7.5, 4.5, 3.5, 8.0, 4.0, 7.0, 4.5, 9.0, 6.5, 8.5]))
    c.append(make_city("Wadi Rum","Wadi Rum, Aqaba, Jordan","Jordan","Asia",29.5667,35.4167,5000,"Mars-like desert landscape with Bedouin camps, sandstone arches, and Lawrence of Arabia history. Sleep under the stars in a Bedouin tent amid towering red rock formations on Mars on Earth.","",
        [8.0, 7.5, 1.0, 1.0, 3.0, 3.0, 4.5, 7.5, 3.0, 2.0, 9.5, 3.0, 7.5, 2.5, 7.0, 6.0, 9.5]))
    c.append(make_city("Aqaba","Aqaba, Jordan","Jordan","Asia",29.5267,35.0078,188160,"Red Sea diving destination with coral reefs, desert excursions, and year-round warm waters. Jordan's beach town combines world-class scuba with desert canyons and historic port vibes.","",
        [6.5, 6.5, 1.5, 1.0, 5.0, 5.0, 5.0, 7.5, 5.0, 4.5, 7.5, 5.0, 7.5, 5.5, 6.5, 6.0, 8.0]))
    c.append(make_city("Salalah","Salalah, Dhofar, Oman","Oman","Asia",17.0151,54.0924,340815,"Tropical Arabian city with monsoon-fed waterfalls, frankincense heritage, and pristine beaches. The only place on the Arabian Peninsula with a monsoon season that turns the desert green.","",
        [5.5, 5.5, 1.5, 1.0, 4.5, 5.0, 5.0, 8.5, 6.0, 5.0, 8.0, 5.5, 8.5, 5.5, 6.0, 5.5, 7.5]))
    return c

def get_africa():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Marrakech","Marrakech, Morocco","Morocco","Africa",31.6295,-7.9811,928850,"Sensory overload of souks, riads, and the legendary Jemaa el-Fna square. Snake charmers, spice mountains, and the call to prayer create an unforgettable North African experience.","",
        [6.5, 7.0, 2.5, 1.5, 7.0, 4.5, 4.5, 6.0, 5.0, 4.5, 5.5, 5.0, 7.0, 5.5, 8.5, 5.0, 6.0]))
    c.append(make_city("Fez","Fez, Morocco","Morocco","Africa",34.0333,-5.0000,1150131,"World's largest car-free urban area with medieval medina and centuries-old tanneries. Getting lost in the 9,000 alleys of the ancient medina is both inevitable and magical.","",
        [7.0, 7.5, 2.0, 1.0, 5.5, 4.0, 4.5, 6.0, 4.5, 5.0, 5.0, 4.5, 7.0, 5.0, 8.0, 5.0, 5.0]))
    c.append(make_city("Essaouira","Essaouira, Morocco","Morocco","Africa",31.5085,-9.7595,77966,"Windy Atlantic port town beloved by surfers, artists, and Game of Thrones fans. Blue fishing boats, whitewashed ramparts, and Hendrix-era bohemian spirit define this coastal gem.","",
        [7.5, 7.5, 1.5, 1.0, 4.5, 5.0, 4.5, 7.0, 4.0, 3.5, 7.5, 4.0, 7.0, 5.0, 7.0, 5.5, 7.5]))
    c.append(make_city("Chefchaouen","Chefchaouen, Morocco","Morocco","Africa",35.1688,-5.2636,42786,"Mountain town painted entirely in shades of blue tucked into the Rif Mountains. Every alley, doorway, and staircase is drenched in blue, creating a dreamlike Moroccan village.","",
        [8.0, 8.0, 1.0, 1.0, 3.5, 4.5, 4.5, 7.0, 3.5, 3.0, 8.0, 3.5, 7.0, 4.0, 6.5, 5.5, 8.0]))
    c.append(make_city("Tangier","Tangier, Morocco","Morocco","Africa",35.7595,-5.8340,947952,"Gateway between Africa and Europe with a storied literary history and Mediterranean flair. Where the Mediterranean meets the Atlantic, this port city inspired Burroughs, Bowles, and Matisse.","",
        [7.0, 7.0, 2.5, 1.5, 6.5, 4.5, 4.5, 6.0, 5.0, 5.0, 6.0, 5.0, 7.0, 5.5, 7.0, 5.5, 6.0]))
    c.append(make_city("Luxor","Luxor, Egypt","Egypt","Africa",25.6872,32.6396,506588,"Open-air museum city with Valley of the Kings, Karnak Temple, and pharaonic grandeur. The world's greatest open-air museum stretches along the Nile with temples and tombs spanning millennia.","",
        [8.0, 8.5, 1.5, 1.0, 5.0, 4.5, 4.0, 5.5, 4.5, 4.0, 6.0, 4.0, 7.0, 5.0, 8.5, 5.0, 6.0]))
    c.append(make_city("Aswan","Aswan, Egypt","Egypt","Africa",24.0889,32.8998,1568000,"Serene Nile city with Nubian culture, felucca sailing, and gateway to Abu Simbel. The most beautiful stretch of the Nile with colorful Nubian villages and ancient temples.","",
        [8.0, 8.5, 1.0, 1.0, 4.5, 4.5, 4.0, 6.0, 4.0, 3.5, 7.0, 3.5, 7.0, 4.5, 7.5, 5.0, 7.0]))
    c.append(make_city("Zanzibar","Zanzibar City, Zanzibar, Tanzania","Tanzania","Africa",-6.1659,39.2026,593678,"Spice island paradise with Stone Town heritage, turquoise waters, and dhow sailing. Carved wooden doors, spice plantations, and pristine beaches on this Indian Ocean island.","",
        [7.0, 7.5, 1.5, 1.0, 5.0, 4.5, 4.0, 6.0, 4.0, 3.5, 8.0, 3.5, 6.5, 4.5, 7.5, 5.5, 8.5]))
    c.append(make_city("Livingstone","Livingstone, Southern Province, Zambia","Zambia","Africa",-17.8419,25.8542,179348,"Adventure capital at the edge of mighty Victoria Falls with rafting, bungee, and safaris. The smoke that thunders provides the backdrop for Africa's ultimate adventure playground.","",
        [7.5, 7.0, 1.0, 1.0, 4.5, 4.5, 4.0, 5.5, 3.5, 3.0, 7.5, 3.5, 6.5, 4.0, 7.0, 6.0, 9.0]))
    return c


def get_south_america():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Cartagena","Cartagena, Bolivar, Colombia","Colombia","South America",10.3910,-75.5364,1028736,"Colorful walled colonial city with Caribbean vibes, salsa dancing, and incredible ceviche. A UNESCO gem where bougainvillea-draped balconies and street musicians define the Caribbean experience.","",
        [6.0, 6.5, 3.0, 2.0, 6.5, 5.0, 5.0, 5.5, 5.5, 5.0, 6.5, 5.0, 6.5, 6.0, 8.0, 6.5, 7.0]))
    c.append(make_city("Cusco","Cusco, Peru","Peru","South America",-13.5319,-71.9675,428450,"Ancient Inca capital and gateway to Machu Picchu with cobblestone streets and altitude. Spanish colonial churches built atop Inca stone walls in this high-altitude cultural powerhouse.","",
        [7.0, 7.5, 2.0, 1.0, 5.5, 4.5, 4.5, 6.0, 5.0, 4.5, 7.0, 4.5, 6.5, 5.5, 8.5, 6.0, 8.0]))
    c.append(make_city("Sacred Valley","Sacred Valley, Cusco, Peru","Peru","South America",-13.3333,-72.0833,170000,"Stunning Andean valley with Inca ruins, weaving villages, and Machu Picchu rail access. Ancient agricultural terraces and traditional markets dot this breathtaking valley between Cusco and Machu Picchu.","",
        [7.5, 7.5, 1.0, 1.0, 4.0, 4.0, 4.5, 6.0, 3.5, 3.0, 8.5, 3.5, 6.5, 4.0, 7.5, 6.0, 9.0]))
    c.append(make_city("Banos","Banos de Agua Santa, Tungurahua, Ecuador","Ecuador","South America",-1.3928,-78.4269,20018,"Adventure capital with waterfall routes, thermal baths, and swing at the end of the world. A tiny Andean town packed with adrenaline activities beneath the watchful eye of an active volcano.","",
        [8.0, 8.0, 1.0, 1.0, 4.0, 4.5, 4.5, 6.5, 4.0, 3.5, 8.5, 3.5, 7.0, 5.0, 7.0, 6.5, 9.5]))
    c.append(make_city("Bariloche","San Carlos de Bariloche, Rio Negro, Argentina","Argentina","South America",-41.1335,-71.3103,133500,"Patagonian lake district with chocolate shops, alpine scenery, and world-class skiing. Argentina's own Swiss Alps with glacial lakes, dense forests, and artisanal chocolate at every turn.","",
        [5.5, 5.5, 2.0, 1.0, 5.0, 5.0, 5.0, 7.5, 6.0, 5.5, 9.0, 5.0, 5.5, 6.0, 7.5, 7.0, 9.5]))
    c.append(make_city("Mendoza","Mendoza, Argentina","Argentina","South America",-32.8895,-68.8458,115041,"Wine capital of South America with Malbec vineyards set against the Andes. Sip world-class wines with snow-capped Andean peaks as your backdrop in this sun-drenched valley.","",
        [6.5, 6.5, 2.5, 1.5, 5.5, 5.5, 5.0, 7.0, 6.0, 6.0, 7.5, 5.0, 5.5, 6.5, 8.0, 7.0, 8.5]))
    c.append(make_city("La Paz","La Paz, Bolivia","Bolivia","South America",-16.4897,-68.1193,812799,"World's highest capital with dramatic canyon setting, witches' market, and Death Road biking. A vertiginous city tumbling down a canyon at 3,640m with cable car transit and indigenous culture.","",
        [8.0, 8.5, 2.0, 1.0, 5.0, 4.0, 4.0, 5.0, 4.0, 4.0, 5.5, 4.0, 6.5, 5.0, 7.0, 5.5, 7.5]))
    c.append(make_city("Sucre","Sucre, Chuquisaca, Bolivia","Bolivia","South America",-19.0196,-65.2619,300000,"Bolivia's constitutional capital with gleaming white colonial architecture. The White City offers a gentler Bolivian pace with dinosaur footprints, markets, and gorgeous plazas.","",
        [8.5, 8.5, 1.5, 1.0, 4.0, 5.0, 4.0, 6.0, 4.5, 4.5, 7.0, 3.5, 6.5, 5.0, 6.5, 6.0, 6.5]))
    return c


def get_central_north_america():
    c = []
    # MEXICO
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Oaxaca","Oaxaca de Juarez, Oaxaca, Mexico","Mexico","North America",17.0732,-96.7266,300000,"Indigenous cultural capital with extraordinary cuisine, mezcal, and Day of the Dead traditions. A culinary pilgrimage destination where mole, tlayudas, and mezcal reach their highest form.","",
        [7.5, 7.5, 2.5, 1.5, 5.5, 5.0, 5.0, 6.0, 5.5, 5.0, 6.5, 4.5, 6.5, 6.0, 9.0, 7.0, 6.5]))
    c.append(make_city("Playa del Carmen","Playa del Carmen, Quintana Roo, Mexico","Mexico","North America",20.6296,-87.0739,304942,"Caribbean beach town with European flair, cenote swimming, and Mayan ruin access. Fifth Avenue's buzzing promenade meets Caribbean turquoise in the Riviera Maya's cosmopolitan hub.","",
        [6.0, 6.0, 2.5, 1.5, 7.0, 5.0, 5.0, 5.5, 5.5, 4.5, 7.0, 5.0, 6.5, 6.5, 7.5, 7.0, 8.0]))
    c.append(make_city("Tulum","Tulum, Quintana Roo, Mexico","Mexico","North America",20.2114,-87.4654,46800,"Bohemian beach town with clifftop Mayan ruins, cenotes, and stunning Caribbean turquoise. Where ancient Mayan ruins perch above powdery white sand and the jungle meets the sea.","",
        [5.0, 5.0, 2.0, 1.5, 5.5, 4.5, 5.0, 5.5, 4.5, 3.5, 8.0, 4.5, 6.5, 5.5, 8.0, 7.0, 8.5]))
    c.append(make_city("San Miguel de Allende","San Miguel de Allende, Guanajuato, Mexico","Mexico","North America",20.9144,-100.7452,139297,"Baroque colonial jewel repeatedly voted world's best small city. Candy-colored facades, art galleries, and rooftop bars fill this perfectly preserved colonial town.","",
        [5.5, 5.5, 2.0, 1.5, 5.0, 5.5, 5.5, 6.5, 5.5, 5.0, 7.0, 5.0, 6.5, 6.0, 8.5, 7.5, 6.5]))
    # CENTRAL AMERICA
    c.append(make_city("Antigua Guatemala","Antigua Guatemala, Sacatepequez, Guatemala","Guatemala","North America",14.5586,-90.7295,46275,"Colonial gem surrounded by volcanoes with cobblestone streets and Spanish schools. Crumbling baroque churches and colorful ruins frame three majestic volcanic peaks in this UNESCO city.","",
        [7.5, 7.5, 2.0, 1.0, 5.0, 5.0, 4.5, 5.5, 4.5, 4.0, 7.0, 4.0, 6.5, 5.5, 7.5, 6.0, 8.0]))
    c.append(make_city("Lake Atitlan","Lake Atitlan, Solola, Guatemala","Guatemala","North America",14.6872,-91.2000,30000,"Sacred Mayan lake ringed by volcanoes and traditional indigenous villages. Aldous Huxley called it the most beautiful lake in the world, and the ring of volcanoes proves him right.","",
        [8.0, 8.5, 1.0, 1.0, 3.5, 3.5, 4.5, 5.0, 3.5, 3.0, 9.0, 3.0, 6.5, 4.5, 7.0, 6.0, 9.5]))
    c.append(make_city("Bocas del Toro","Bocas del Toro, Panama","Panama","North America",9.3405,-82.2408,13320,"Caribbean archipelago with laid-back surf culture, snorkeling, and jungle adventures. Wooden houses on stilts over turquoise waters on a chain of lush tropical islands.","",
        [7.5, 7.0, 1.0, 1.0, 4.0, 3.5, 5.0, 6.0, 3.5, 3.0, 8.5, 3.5, 8.0, 4.5, 7.0, 7.0, 9.0]))
    c.append(make_city("Caye Caulker","Caye Caulker, Belize","Belize","North America",17.7500,-88.0167,2025,"Tiny car-free island where the motto is go slow with incredible snorkeling on the reef. A barefoot Caribbean island where bikes and golf carts replace cars and the reef beckons just offshore.","",
        [7.0, 6.5, 1.0, 1.0, 3.5, 4.0, 5.0, 6.5, 3.0, 2.5, 8.5, 3.5, 7.5, 4.5, 6.5, 7.0, 9.0]))
    return c


def get_caribbean_oceania():
    c = []
    # CARIBBEAN
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("San Juan","San Juan, Puerto Rico","Puerto Rico","North America",18.4655,-66.1057,342259,"Colorful colonial capital with El Morro fortress, salsa, and bioluminescent bays. Cobblestone streets of Old San Juan lead past pastel buildings to dramatic Atlantic fortifications.","",
        [5.0, 5.0, 3.5, 2.0, 7.0, 5.5, 6.0, 6.0, 6.5, 6.0, 7.0, 5.5, 6.0, 7.0, 8.0, 7.5, 7.5]))
    c.append(make_city("Nassau","Nassau, New Providence, Bahamas","Bahamas","North America",25.0480,-77.3554,274400,"Island capital with pink-sand beaches, pirate history, and crystal-clear Bahamian waters. From the colonial charm of downtown to the swimming pigs of Exuma, the Bahamas dazzles.","",
        [4.0, 3.5, 2.0, 1.5, 7.0, 5.0, 6.0, 5.5, 5.5, 5.0, 7.5, 5.5, 8.5, 6.5, 7.0, 7.0, 8.0]))
    c.append(make_city("Bridgetown","Bridgetown, Barbados","Barbados","North America",13.0975,-59.6167,110000,"UNESCO-listed Caribbean capital with rum heritage, surf breaks, and tropical charm. Bajans welcome you to an island of flying fish, cricket, and the birthplace of rum punch.","",
        [4.5, 4.0, 2.0, 1.5, 6.5, 5.5, 6.0, 6.5, 6.0, 5.5, 7.5, 5.5, 6.5, 6.5, 7.5, 7.5, 8.0]))
    c.append(make_city("Willemstad","Willemstad, Curacao","Curacao","North America",12.1696,-68.9900,150000,"Dutch Caribbean gem with colorful Handelskade waterfront and world-class diving. Pastel-painted merchant houses line the harbor of this UNESCO World Heritage trading port.","",
        [5.0, 5.0, 2.0, 1.5, 6.0, 5.5, 6.0, 6.5, 6.0, 5.5, 7.5, 5.5, 7.5, 6.5, 7.5, 8.0, 8.0]))
    c.append(make_city("Montego Bay","Montego Bay, Jamaica","Jamaica","North America",18.4762,-77.8939,110115,"Vibrant reggae city with white sand beaches, jerk cuisine, and Blue Mountain views. Doctor's Cave Beach and hip-strip nightlife make MoBay Jamaica's tourism capital.","",
        [6.0, 5.5, 2.0, 1.0, 7.0, 4.5, 5.0, 4.5, 5.0, 4.5, 7.0, 4.5, 6.5, 5.5, 7.5, 6.0, 8.0]))
    c.append(make_city("Punta Cana","Punta Cana, La Altagracia, Dominican Republic","Dominican Republic","North America",18.5601,-68.3725,100023,"All-inclusive beach paradise with palm-lined shores and championship golf. Miles of coconut-palm beaches and turquoise waters make this the Caribbean's most popular resort zone.","",
        [5.5, 5.5, 1.5, 1.0, 7.0, 4.5, 5.0, 5.5, 5.0, 4.0, 7.5, 4.5, 6.5, 5.5, 7.0, 6.5, 8.0]))
    # OCEANIA
    c.append(make_city("Queenstown","Queenstown, Otago, New Zealand","New Zealand","Oceania",-45.0312,168.6626,15800,"Adventure capital of the world with bungee jumping, skiing, and stunning lake views. Every adrenaline activity imaginable set against the dramatic Remarkables mountain range.","",
        [3.0, 3.0, 2.5, 1.5, 5.5, 5.5, 7.5, 9.0, 7.5, 6.5, 9.5, 7.0, 5.5, 7.5, 8.0, 8.5, 10.0]))
    c.append(make_city("Rotorua","Rotorua, Bay of Plenty, New Zealand","New Zealand","Oceania",-38.1368,176.2497,77300,"Geothermal wonderland with Maori culture, boiling mud pools, and redwood forests. Steam rises from the streets of this extraordinary city where Maori heritage meets volcanic fury.","",
        [5.5, 5.0, 2.0, 1.5, 5.0, 5.5, 7.0, 8.5, 7.0, 6.0, 8.0, 6.0, 5.5, 7.0, 7.5, 8.0, 9.0]))
    c.append(make_city("Wanaka","Wanaka, Otago, New Zealand","New Zealand","Oceania",-44.7032,169.1321,13700,"Lakeside mountain town with that famous lone tree, hiking, and skiing. A quieter alternative to Queenstown with equally stunning scenery and a charming small-town feel.","",
        [3.5, 3.5, 1.5, 1.0, 4.5, 5.0, 7.0, 9.0, 6.5, 5.5, 9.5, 6.0, 5.5, 7.0, 7.0, 8.5, 10.0]))
    c.append(make_city("Nadi","Nadi, Viti Levu, Fiji","Fiji","Oceania",-17.7765,177.9400,67000,"Gateway to Fiji's islands with sugar cane fields and coral reef adventures. Your first taste of Fijian bula spirit before island-hopping to paradise.","",
        [7.0, 6.5, 1.5, 1.0, 6.0, 4.5, 5.0, 6.5, 4.5, 4.0, 8.0, 4.0, 6.5, 4.5, 6.5, 7.0, 8.0]))
    c.append(make_city("Bora Bora","Bora Bora, French Polynesia","French Polynesia","Oceania",-16.5004,-151.7415,10605,"Ultimate luxury island with overwater bungalows and impossibly turquoise lagoon. The Mount Otemanu backdrop and lagoon colors make this the ultimate honeymoon paradise.","",
        [1.5, 1.5, 1.0, 1.0, 4.0, 3.5, 4.5, 8.5, 5.0, 3.5, 9.5, 4.0, 6.0, 4.0, 8.0, 7.5, 9.5]))
    c.append(make_city("Moorea","Moorea, French Polynesia","French Polynesia","Oceania",-17.5388,-149.8295,17816,"Heart-shaped volcanic island with reef-ringed lagoons and pineapple plantations. Bora Bora's quieter sister offers equally stunning beauty with more accessible local Polynesian culture.","",
        [2.0, 2.0, 1.0, 1.0, 4.0, 3.5, 4.5, 8.5, 5.0, 4.0, 9.5, 4.0, 6.0, 4.5, 7.5, 7.5, 9.5]))
    c.append(make_city("Rarotonga","Rarotonga, Cook Islands","Cook Islands","Oceania",-21.2367,-159.7777,13007,"Tiny Pacific gem with Polynesian culture, lagoon snorkeling, and jungle treks. A volcanic island encircled by a turquoise lagoon where ancient Polynesian culture thrives.","",
        [4.5, 4.0, 1.0, 1.0, 3.5, 4.0, 5.0, 8.5, 4.5, 4.0, 9.0, 4.0, 7.0, 4.5, 7.0, 7.5, 9.0]))
    return c


def get_extra_cities():
    c = []
    #                                                                                                                           Hou  CoL  Sta  VC   Trv  Com  Biz  Saf  Hlt  Edu  Env  Eco  Tax  Int  Lei  Tol  Out
    c.append(make_city("Samarkand","Samarkand, Uzbekistan","Uzbekistan","Asia",39.6542,66.9597,546698,"Silk Road jewel with turquoise-tiled madrasas and the magnificent Registan Square. Tamerlane's ancient capital dazzles with some of the Islamic world's most spectacular architecture.","",
        [8.0, 8.5, 1.5, 1.0, 4.5, 5.0, 4.0, 7.0, 5.0, 5.0, 6.5, 4.0, 7.0, 5.0, 8.5, 5.5, 5.5]))
    c.append(make_city("Bukhara","Bukhara, Uzbekistan","Uzbekistan","Asia",39.7681,64.4556,280000,"Ancient Silk Road trading center with 2,500 years of continuous urban history. Minarets, madrasas, and merchant domes create an open-air museum of Islamic architecture.","",
        [8.5, 8.5, 1.0, 1.0, 4.0, 5.0, 4.0, 7.0, 4.5, 4.5, 6.0, 4.0, 7.0, 4.5, 8.0, 5.5, 5.0]))
    c.append(make_city("Maldives","Male, Maldives","Maldives","Asia",4.1755,73.5093,557426,"Paradise archipelago of 1,200 coral islands with overwater villas and underwater restaurants. The ultimate tropical escape where turquoise lagoons and white sand atolls stretch to the horizon.","",
        [2.0, 2.0, 1.5, 1.0, 5.5, 3.5, 4.5, 8.5, 5.5, 4.0, 9.0, 4.5, 8.0, 5.0, 8.0, 6.0, 9.5]))
    c.append(make_city("Luang Namtha","Luang Namtha, Laos","Laos","Asia",21.0000,101.4000,35000,"Remote northern Lao town surrounded by pristine jungle and ethnic minority villages. A trekking base for encountering traditional hill tribe cultures in untouched mountain forests.","",
        [8.5, 9.0, 1.0, 1.0, 2.5, 3.5, 4.0, 7.0, 3.0, 2.5, 9.0, 2.5, 8.0, 3.0, 5.5, 6.5, 9.0]))
    c.append(make_city("Ninh Binh","Ninh Binh, Vietnam","Vietnam","Asia",20.2506,105.9745,130517,"Stunning karst landscape known as the inland Ha Long Bay with river caves and ancient temples. Emerald rice paddies punctuated by limestone towers create Vietnam's most photogenic landscape.","",
        [8.0, 8.5, 1.5, 1.0, 5.0, 4.5, 4.5, 8.0, 4.5, 4.0, 9.0, 4.0, 7.5, 5.0, 7.0, 6.5, 8.5]))
    c.append(make_city("Sapa","Sapa, Lao Cai, Vietnam","Vietnam","Asia",22.3364,103.8438,61498,"Misty mountain town with cascading rice terraces and colorful Hmong hill tribe markets. Trek through some of Asia's most dramatic rice terraces while staying with local ethnic minority families.","",
        [8.0, 8.5, 1.0, 1.0, 4.0, 4.0, 4.5, 7.0, 3.5, 3.0, 8.5, 3.5, 7.5, 4.5, 7.0, 6.0, 9.0]))
    c.append(make_city("Kota Kinabalu","Kota Kinabalu, Sabah, Malaysia","Malaysia","Asia",5.9804,116.0735,500000,"Gateway to Mount Kinabalu and Borneo's incredible wildlife with stunning island sunsets. Climb Southeast Asia's highest peak, dive world-class reefs, and spot orangutans in the wild.","",
        [7.0, 7.0, 2.0, 1.0, 5.5, 5.0, 5.5, 7.0, 5.5, 5.0, 8.0, 5.0, 7.0, 6.0, 7.0, 7.0, 9.0]))
    c.append(make_city("Pakse","Pakse, Champasak, Laos","Laos","Asia",15.1200,105.7833,88332,"Southern Lao gateway to the Bolaven Plateau's waterfalls and 4,000 Islands region. Coffee plantations, thundering cascades, and the serene Mekong Islands await in laid-back southern Laos.","",
        [8.5, 9.0, 1.0, 1.0, 3.5, 4.5, 4.0, 7.0, 3.5, 3.0, 8.0, 3.0, 8.0, 4.0, 5.5, 6.5, 7.5]))
    c.append(make_city("Savannakhet","Savannakhet, Laos","Laos","Asia",16.5572,104.7525,125760,"Sleepy Mekong town with crumbling French colonial architecture and dinosaur museum. A charming crossroads town where faded colonial grandeur meets authentic Lao daily life.","",
        [8.5, 9.0, 1.0, 1.0, 3.5, 4.5, 4.0, 7.0, 3.5, 3.0, 7.0, 3.0, 8.0, 3.5, 4.5, 6.0, 5.5]))
    c.append(make_city("Seminyak","Seminyak, Bali, Indonesia","Indonesia","Asia",-8.6913,115.1683,23000,"Bali's stylish beach district with upscale boutiques, beach clubs, and world-class dining. Sunset cocktails, designer shops, and some of Bali's best restaurants line this trendy coastal strip.","",
        [5.0, 5.5, 3.0, 1.5, 5.5, 4.5, 4.5, 6.5, 5.0, 4.0, 6.0, 5.0, 7.0, 6.5, 8.0, 6.5, 7.0]))
    c.append(make_city("Nagano","Nagano, Japan","Japan","Asia",36.6513,138.1810,370632,"Mountain city famous for snow monkeys, 1998 Winter Olympics, and stunning Buddhist temples. Watch Japanese macaques soak in hot springs surrounded by snow in this charming alpine city.","",
        [5.5, 5.0, 2.5, 1.5, 6.0, 6.0, 6.0, 9.0, 7.5, 7.0, 8.5, 6.5, 6.0, 7.5, 7.0, 7.0, 9.0]))
    c.append(make_city("Matsumoto","Matsumoto, Nagano, Japan","Japan","Asia",36.2380,137.9720,241145,"Castle town with one of Japan's most beautiful original keeps and gateway to the Japanese Alps. A cultured city where a striking black-and-white castle guards the entrance to Alpine trails.","",
        [5.5, 5.5, 2.0, 1.5, 5.5, 6.0, 6.0, 9.0, 7.5, 6.5, 8.5, 6.0, 6.0, 7.5, 7.5, 7.0, 9.0]))
    c.append(make_city("Jiufen","Jiufen, New Taipei, Taiwan","Taiwan","Asia",25.1089,121.8443,3000,"Atmospheric hillside tea town that inspired Spirited Away's fantastical scenery. Lantern-lit alleyways cascade down a mountainside offering tea houses, ocean views, and gold mining history.","",
        [6.0, 6.0, 1.5, 1.0, 6.0, 5.0, 6.5, 8.5, 7.0, 6.0, 7.5, 5.5, 7.0, 7.5, 7.5, 7.5, 7.0]))
    c.append(make_city("Muang Ngoi","Muang Ngoi, Luang Prabang, Laos","Laos","Asia",20.7333,102.6833,800,"Tiny riverside village accessible only by boat with stunning karst scenery and zero traffic. One of Southeast Asia's last unplugged paradises where electricity arrived just years ago.","",
        [8.5, 9.5, 1.0, 1.0, 2.0, 3.0, 3.5, 7.5, 2.5, 2.0, 9.5, 2.5, 8.0, 2.0, 5.0, 6.5, 9.0]))
    return c


def main():
    cities = get_all_cities()
    
    # Load original list to verify coverage
    input_path = os.path.join(os.path.dirname(__file__), "travel_cities_list.json")
    with open(input_path, "r") as f:
        original = json.load(f)
    original_names = {c["name"] for c in original}
    enriched_names = {c["name"] for c in cities}
    
    # Report coverage
    print(f"Original list: {len(original_names)} cities")
    print(f"Enriched:      {len(enriched_names)} cities")
    
    missing = original_names - enriched_names
    extra = enriched_names - original_names
    if missing:
        print(f"\nMISSING from enrichment ({len(missing)}):")
        for m in sorted(missing):
            print(f"  - {m}")
    if extra:
        print(f"\nEXTRA in enrichment ({len(extra)}):")
        for e in sorted(extra):
            print(f"  - {e}")
    
    # Stats
    scores_all = []
    continents = {}
    countries = {}
    for c in cities:
        scores_all.append(c["teleport_city_score"])
        cont = c["continent"]
        country = c["country"]
        continents[cont] = continents.get(cont, 0) + 1
        countries[country] = countries.get(country, 0) + 1
    
    print(f"\n--- STATS ---")
    print(f"Total cities: {len(cities)}")
    print(f"Teleport City Score range: {min(scores_all):.1f} - {max(scores_all):.1f}")
    print(f"Average score: {sum(scores_all)/len(scores_all):.1f}")
    
    print(f"\nBy continent:")
    for cont, count in sorted(continents.items(), key=lambda x: -x[1]):
        print(f"  {cont}: {count}")
    
    print(f"\nTop 10 countries:")
    for country, count in sorted(countries.items(), key=lambda x: -x[1])[:10]:
        print(f"  {country}: {count}")
    
    print(f"\nTop 10 highest scored:")
    for c in sorted(cities, key=lambda x: -x["teleport_city_score"])[:10]:
        print(f"  {c['name']}: {c['teleport_city_score']:.1f}")
    
    print(f"\nBottom 10 lowest scored:")
    for c in sorted(cities, key=lambda x: x["teleport_city_score"])[:10]:
        print(f"  {c['name']}: {c['teleport_city_score']:.1f}")
    
    # Category averages
    print(f"\nAverage scores by category:")
    for key in SCORE_KEYS:
        vals = [c["scores"][key] for c in cities]
        print(f"  {key}: {sum(vals)/len(vals):.1f}")
    
    # Write output
    output_path = os.path.join(os.path.dirname(__file__), "travel_cities_enriched.json")
    with open(output_path, "w") as f:
        json.dump(cities, f, indent=2, ensure_ascii=False)
    
    print(f"\nOutput written to: {output_path}")
    print(f"File size: {os.path.getsize(output_path) / 1024:.1f} KB")

if __name__ == "__main__":
    main()

