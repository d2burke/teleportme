#!/usr/bin/env python3
"""
Curate and enrich cities data for TeleportMe app.
Reads new_cities_master.json, removes obscure/small cities,
and generates enriched data with scores for each remaining city.
"""

import json
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_FILE = os.path.join(SCRIPT_DIR, "new_cities_master.json")
OUTPUT_FILE = os.path.join(SCRIPT_DIR, "curated_cities_data.json")

# ─── Cities to REMOVE ───────────────────────────────────────────────────────

REMOVE_CITIES = {
    # Australian small/obscure
    ("Sunshine Coast", "Australia"), ("Wollongong", "Australia"), ("Geelong", "Australia"),
    ("Townsville", "Australia"), ("Cairns", "Australia"), ("Darwin", "Australia"),
    ("Toowoomba", "Australia"), ("Ballarat", "Australia"), ("Bendigo", "Australia"),
    ("Albury", "Australia"), ("Launceston", "Australia"), ("Mackay", "Australia"),
    ("Hervey Bay", "Australia"), ("Rockhampton", "Australia"), ("Bundaberg", "Australia"),
    ("Maitland", "Australia"), ("Coffs Harbour", "Australia"), ("Wagga Wagga", "Australia"),
    ("Gladstone", "Australia"), ("Tamworth", "Australia"), ("Orange", "Australia"),

    # US small/obscure
    ("Bakersfield", "United States"), ("Corpus Christi", "United States"),
    ("Riverside", "United States"), ("Lexington", "United States"),
    ("Stockton", "United States"), ("Henderson", "United States"),
    ("Saint Paul", "United States"), ("San Bernardino", "United States"),
    ("Spokane", "United States"), ("Des Moines", "United States"),
    ("Tacoma", "United States"), ("Modesto", "United States"),
    ("Anchorage", "United States"), ("Plano", "United States"),
    ("Lincoln", "United States"), ("Newark", "United States"),
    ("Chula Vista", "United States"), ("Toledo", "United States"),
    ("Fort Wayne", "United States"), ("Lubbock", "United States"),
    ("Jersey City", "United States"), ("Glendale", "United States"),
    ("North Las Vegas", "United States"), ("Norfolk", "United States"),
    ("Laredo", "United States"), ("Gilbert", "United States"),
    ("Winston-Salem", "United States"), ("Hialeah", "United States"),
    ("Garland", "United States"), ("Chesapeake", "United States"),
    ("Irving", "United States"), ("Fremont", "United States"),
    ("Baton Rouge", "United States"), ("Wichita", "United States"),
    ("Arlington", "United States"),
    # Also unaccounted US cities to remove
    ("Aurora", "United States"), ("Greensboro", "United States"), ("Irvine", "United States"),

    # Central American small
    ("San Pedro Sula", "Honduras"), ("Belize City", "Belize"),
    ("San Miguelito", "Panama"), ("León", "Nicaragua"),
    ("Santa Ana", "El Salvador"), ("Chimaltenango", "Guatemala"),
    ("Comayagua", "Honduras"), ("La Ceiba", "Honduras"),

    # Chinese cities hard to get English data
    ("Chongqing", "China"), ("Wuhan", "China"), ("Nanjing", "China"),
    ("Xi'an", "China"), ("Hangzhou", "China"), ("Shenyang", "China"),
    ("Suzhou", "China"), ("Qingdao", "China"), ("Dalian", "China"),
    ("Jinan", "China"), ("Zhengzhou", "China"), ("Dongguan", "China"),
    ("Faisalabad", "Pakistan"),  # was listed with Chinese cities

    # Small/obscure elsewhere
    ("Peshawar", "Pakistan"), ("Port Moresby", "Papua New Guinea"),
    ("Apia", "Samoa"), ("Suva", "Fiji"), ("Thimphu", "Bhutan"),
    ("Ashgabat", "Turkmenistan"), ("Dushanbe", "Tajikistan"),
    ("Bishkek", "Kyrgyzstan"), ("Yangon", "Myanmar"), ("Bamako", "Mali"),
    ("Windhoek", "Namibia"), ("Gaborone", "Botswana"), ("Abidjan", "Côte d'Ivoire"),
    ("Lusaka", "Zambia"), ("Yekaterinburg", "Russia"), ("Novosibirsk", "Russia"),
    ("Krasnoyarsk", "Russia"), ("Omsk", "Russia"), ("Chelyabinsk", "Russia"),
    ("Nizhny Novgorod", "Russia"), ("Samara", "Russia"), ("Kazan", "Russia"),
    ("Kharkiv", "Ukraine"), ("Shymkent", "Kazakhstan"), ("Chisinau", "Moldova"),
    ("Łódź", "Poland"), ("Bradford", "United Kingdom"),
    ("Barquisimeto", "Venezuela"), ("Maracaibo", "Venezuela"),
    ("Nezahualcóyotl", "Mexico"), ("São Luís", "Brazil"), ("Callao", "Peru"),

    # Canadian suburbs/small
    ("Brampton", "Canada"), ("Surrey", "Canada"), ("Mississauga", "Canada"),
    ("Laval", "Canada"), ("Kitchener", "Canada"), ("Regina", "Canada"),
    ("Saskatoon", "Canada"), ("St. John's", "Canada"), ("Hamilton", "Canada"),
    # Note: London, Canada is not in master file

    # Dominican Republic
    ("Santo Domingo", "Dominican Republic"),
    ("Santiago de los Caballeros", "Dominican Republic"),
}


# ─── CITY DATA: coordinates, population, scores, summaries, images ───────────

CITY_DATA = {}

def add_city(name, country, full_name, continent, lat, lon, pop, summary, image_url, scores):
    """Helper to add a city to the data dict."""
    slug = name.lower().replace(" ", "-").replace(".", "").replace("'", "")
    # Handle special slug cases
    slug = slug.replace("ã", "a").replace("é", "e").replace("á", "a").replace("ó", "o").replace("ú", "u").replace("í", "i").replace("ü", "u").replace("ö", "o")
    # Calculate teleport score
    score_values = list(scores.values())
    teleport_score = round((sum(score_values) / len(score_values)) * 10, 1)
    teleport_score = max(40.0, min(75.0, teleport_score))

    key = (name, country)
    CITY_DATA[key] = {
        "id": slug,
        "name": name,
        "full_name": full_name,
        "country": country,
        "continent": continent,
        "latitude": lat,
        "longitude": lon,
        "population": pop,
        "teleport_city_score": teleport_score,
        "summary": summary,
        "image_url": image_url,
        "scores": scores
    }

# ═══════════════════════════════════════════════════════════════════════════════
# AFRICA
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Algiers", "Algeria", "Algiers, Algeria", "Africa",
    36.7538, 3.0588, 3915811,
    "Algeria's vibrant capital blends French colonial architecture with Ottoman-era charm along the Mediterranean coast. A city of contrasts where the ancient Casbah meets modern boulevards and bustling markets.",
    "https://images.unsplash.com/photo-1569974507005-6dc61f97fb5c?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 7.8, "Startups": 2.5, "Venture Capital": 1.5,
     "Travel Connectivity": 4.5, "Commute": 4.0, "Business Freedom": 3.5, "Safety": 5.0,
     "Healthcare": 4.5, "Education": 5.0, "Environmental Quality": 5.0, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 4.5, "Leisure & Culture": 5.5, "Tolerance": 4.0, "Outdoors": 6.0})

add_city("Cairo", "Egypt", "Cairo, Egypt", "Africa",
    30.0444, 31.2357, 21750020,
    "The sprawling megacity on the Nile is home to the last remaining Wonder of the Ancient World and millennia of layered history. Cairo pulses with energy, from its chaotic streets to its world-class museums and vibrant food scene.",
    "https://images.unsplash.com/photo-1572252009286-268acec5ca0a?auto=format&fit=crop&w=800&q=80",
    {"Housing": 8.5, "Cost of Living": 8.5, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 7.0, "Commute": 3.0, "Business Freedom": 4.0, "Safety": 5.0,
     "Healthcare": 4.5, "Education": 5.5, "Environmental Quality": 3.0, "Economy": 4.5,
     "Taxation": 6.0, "Internet Access": 5.0, "Leisure & Culture": 7.5, "Tolerance": 4.0, "Outdoors": 4.0})

add_city("Addis Ababa", "Ethiopia", "Addis Ababa, Ethiopia", "Africa",
    9.0250, 38.7469, 5227794,
    "The diplomatic capital of Africa and seat of the African Union sits at 2,400 meters elevation with a year-round spring-like climate. This rapidly modernizing city offers a unique cultural experience with its ancient coffee traditions and distinctive cuisine.",
    "https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 8.0, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 3.5, "Business Freedom": 4.0, "Safety": 5.0,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 5.5, "Internet Access": 3.5, "Leisure & Culture": 5.0, "Tolerance": 4.5, "Outdoors": 5.5})

add_city("Accra", "Ghana", "Accra, Ghana", "Africa",
    5.6037, -0.1870, 4010054,
    "Ghana's coastal capital is one of West Africa's most dynamic cities, known for its welcoming culture and growing tech scene. From lively beach bars to bustling Makola Market, Accra offers an authentic African urban experience.",
    "https://images.unsplash.com/photo-1597424216809-3ba4e58f4a35?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 5.5, "Safety": 6.0,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 4.5, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 4.5, "Leisure & Culture": 5.5, "Tolerance": 5.5, "Outdoors": 5.5})

add_city("Casablanca", "Morocco", "Casablanca, Morocco", "Africa",
    33.5731, -7.5898, 3752357,
    "Morocco's economic powerhouse blends Art Deco architecture with traditional medina charm along the Atlantic coast. Home to the stunning Hassan II Mosque and a thriving business district, Casablanca bridges Europe and Africa.",
    "https://images.unsplash.com/photo-1569383746724-6f1b882b8f46?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 3.5, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 4.0, "Business Freedom": 5.0, "Safety": 6.0,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 5.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 6.0, "Tolerance": 5.0, "Outdoors": 6.0})

add_city("Lagos", "Nigeria", "Lagos, Nigeria", "Africa",
    6.5244, 3.3792, 15946000,
    "Africa's largest city is a relentless engine of commerce, creativity, and Afrobeats culture that never sleeps. Lagos rewards the bold with incredible food, a booming tech ecosystem, and entrepreneurial energy unlike anywhere else.",
    "https://images.unsplash.com/photo-1618828665011-0abd973f7bb8?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 5.5, "Commute": 2.0, "Business Freedom": 4.5, "Safety": 3.5,
     "Healthcare": 3.5, "Education": 4.5, "Environmental Quality": 3.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 4.0, "Leisure & Culture": 6.5, "Tolerance": 4.5, "Outdoors": 3.5})

add_city("Kigali", "Rwanda", "Kigali, Rwanda", "Africa",
    -1.9403, 29.8739, 1170000,
    "Africa's cleanest city has transformed into a model of urban planning and innovation amid lush green hills. Kigali's remarkable story of renewal, combined with its safety and growing tech hub, makes it one of the continent's most promising cities.",
    "https://images.unsplash.com/photo-1580746738099-f27097560e07?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 4.0, "Commute": 5.0, "Business Freedom": 6.5, "Safety": 7.5,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 7.0, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 4.5, "Leisure & Culture": 4.5, "Tolerance": 5.0, "Outdoors": 6.5})

add_city("Dakar", "Senegal", "Dakar, Senegal", "Africa",
    14.7167, -17.4677, 3938000,
    "Perched on the westernmost tip of Africa, Dakar is a culturally rich city with world-class music, art, and surf. The city's French-West African fusion cuisine, colorful neighborhoods, and Atlantic beaches create a uniquely appealing lifestyle.",
    "https://images.unsplash.com/photo-1560969184-10fe8719e047?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 5.5,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 5.5, "Internet Access": 4.5, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 7.0})

add_city("Johannesburg", "South Africa", "Johannesburg, South Africa", "Africa",
    -26.2041, 28.0473, 5926668,
    "South Africa's financial hub is a city of contrasts where world-class shopping malls sit alongside vibrant townships and a thriving arts scene. Joburg's energy, diversity, and entrepreneurial spirit make it the economic heartbeat of the African continent.",
    "https://images.unsplash.com/photo-1577948000111-9c970dfe3743?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 7.0, "Commute": 4.0, "Business Freedom": 6.0, "Safety": 3.5,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 5.5, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 6.0})

add_city("Dar es Salaam", "Tanzania", "Dar es Salaam, Tanzania", "Africa",
    -6.7924, 39.2083, 6698000,
    "Tanzania's largest city is a bustling Indian Ocean port that serves as a gateway to Zanzibar and the Serengeti. Its blend of Swahili, Arab, and Indian influences creates a fascinating cultural tapestry with incredible seafood and tropical energy.",
    "https://images.unsplash.com/photo-1504735217152-b768bcab5ebc?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 4.5, "Commute": 3.0, "Business Freedom": 4.5, "Safety": 5.0,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 4.5, "Economy": 4.0,
     "Taxation": 5.5, "Internet Access": 4.0, "Leisure & Culture": 5.0, "Tolerance": 5.0, "Outdoors": 6.5})

add_city("Tunis", "Tunisia", "Tunis, Tunisia", "Africa",
    36.8065, 10.1815, 2700000,
    "Tunisia's Mediterranean capital offers a compelling mix of ancient ruins, French-colonial elegance, and Arabic tradition. With Carthage ruins nearby and a walkable medina, Tunis provides an affordable Mediterranean lifestyle.",
    "https://images.unsplash.com/photo-1558551649-e44c8f992010?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 5.0, "Commute": 4.0, "Business Freedom": 4.5, "Safety": 5.5,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 5.5, "Economy": 4.0,
     "Taxation": 5.5, "Internet Access": 5.0, "Leisure & Culture": 6.0, "Tolerance": 5.0, "Outdoors": 6.5})

add_city("Kampala", "Uganda", "Kampala, Uganda", "Africa",
    0.3476, 32.5825, 3652000,
    "Uganda's hilly capital sits on the shores of Lake Victoria with a warm tropical climate and friendly culture. Kampala's vibrant nightlife, growing startup scene, and proximity to world-class wildlife make it an adventurous African base.",
    "",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 4.0, "Commute": 3.0, "Business Freedom": 4.5, "Safety": 4.5,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 5.5, "Internet Access": 4.0, "Leisure & Culture": 5.0, "Tolerance": 3.5, "Outdoors": 6.5})

add_city("Harare", "Zimbabwe", "Harare, Zimbabwe", "Africa",
    -17.8252, 31.0335, 2123000,
    "Zimbabwe's jacaranda-lined capital enjoys one of Africa's most pleasant climates at 1,500 meters elevation. Despite economic challenges, Harare retains a charm with its parks, arts scene, and proximity to Victoria Falls.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.0, "Startups": 2.0, "Venture Capital": 1.0,
     "Travel Connectivity": 3.5, "Commute": 4.0, "Business Freedom": 3.0, "Safety": 4.5,
     "Healthcare": 3.0, "Education": 4.5, "Environmental Quality": 5.5, "Economy": 3.0,
     "Taxation": 5.0, "Internet Access": 3.5, "Leisure & Culture": 4.0, "Tolerance": 4.0, "Outdoors": 6.0})


# ═══════════════════════════════════════════════════════════════════════════════
# ASIA
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Dhaka", "Bangladesh", "Dhaka, Bangladesh", "Asia",
    23.8103, 90.4125, 22478116,
    "One of the world's most densely populated cities, Dhaka is a sensory overload of rickshaws, river life, and resilient spirit. The capital of Bangladesh offers incredibly low costs and a front-row seat to one of Asia's fastest-growing economies.",
    "https://images.unsplash.com/photo-1617256742221-79e7236f5b00?auto=format&fit=crop&w=800&q=80",
    {"Housing": 8.0, "Cost of Living": 9.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 2.0, "Business Freedom": 4.0, "Safety": 4.0,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 2.0, "Economy": 4.5,
     "Taxation": 6.0, "Internet Access": 4.0, "Leisure & Culture": 4.5, "Tolerance": 4.5, "Outdoors": 2.5})

add_city("Beijing", "China", "Beijing, China", "Asia",
    39.9042, 116.4074, 21542000,
    "China's ancient capital seamlessly blends imperial grandeur with cutting-edge modernity across sprawling ring roads and hutong alleyways. From the Forbidden City to the tech corridors of Zhongguancun, Beijing is where tradition meets innovation.",
    "https://images.unsplash.com/photo-1508804185872-d7badad00f7d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.0, "Cost of Living": 4.5, "Startups": 8.0, "Venture Capital": 8.0,
     "Travel Connectivity": 9.0, "Commute": 6.0, "Business Freedom": 4.0, "Safety": 7.5,
     "Healthcare": 6.5, "Education": 7.5, "Environmental Quality": 3.5, "Economy": 8.0,
     "Taxation": 5.0, "Internet Access": 6.0, "Leisure & Culture": 8.0, "Tolerance": 4.0, "Outdoors": 4.5})

add_city("Chengdu", "China", "Chengdu, Sichuan, China", "Asia",
    30.5728, 104.0668, 21000000,
    "The laid-back capital of Sichuan province is famous for giant pandas, face-melting spicy cuisine, and a tea-house culture that prizes leisure. Chengdu's booming tech sector and lower costs make it China's most livable megacity.",
    "https://images.unsplash.com/photo-1567506648753-67d532823cbc?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 6.0, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 7.0, "Commute": 5.5, "Business Freedom": 4.0, "Safety": 7.5,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 4.5, "Economy": 6.5,
     "Taxation": 5.0, "Internet Access": 6.0, "Leisure & Culture": 7.0, "Tolerance": 5.0, "Outdoors": 5.5})

add_city("Guangzhou", "China", "Guangzhou, Guangdong, China", "Asia",
    23.1291, 113.2644, 18676605,
    "The historic trading port of Canton is southern China's megacity, renowned for dim sum culture and relentless commercial energy. Guangzhou's Canton Fair tradition and Pearl River Delta location make it a global trade powerhouse.",
    "https://images.unsplash.com/photo-1583264277361-d0b05a85969e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 5.0, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 8.0, "Commute": 6.0, "Business Freedom": 4.0, "Safety": 7.0,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 4.0, "Economy": 7.5,
     "Taxation": 5.0, "Internet Access": 6.5, "Leisure & Culture": 6.5, "Tolerance": 5.0, "Outdoors": 4.5})

add_city("Shanghai", "China", "Shanghai, China", "Asia",
    31.2304, 121.4737, 28516904,
    "China's glittering financial capital is a futuristic skyline rising from a historic treaty port on the Huangpu River. Shanghai offers world-class dining, a thriving arts scene, and the energy of the world's most populous city proper.",
    "https://images.unsplash.com/photo-1537531383496-f4749b802820?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.5, "Cost of Living": 4.0, "Startups": 8.0, "Venture Capital": 7.5,
     "Travel Connectivity": 9.5, "Commute": 6.5, "Business Freedom": 4.5, "Safety": 8.0,
     "Healthcare": 7.0, "Education": 7.5, "Environmental Quality": 4.0, "Economy": 8.5,
     "Taxation": 5.0, "Internet Access": 6.5, "Leisure & Culture": 8.5, "Tolerance": 5.0, "Outdoors": 4.0})

add_city("Shenzhen", "China", "Shenzhen, Guangdong, China", "Asia",
    22.5431, 114.0579, 17560000,
    "The world's fastest-growing city went from fishing village to tech megacity in just 40 years, earning its reputation as China's Silicon Valley. Shenzhen's hardware ecosystem, youthful energy, and subtropical climate draw entrepreneurs from around the world.",
    "https://images.unsplash.com/photo-1530538095376-a4936b35b5f0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.5, "Cost of Living": 4.0, "Startups": 8.5, "Venture Capital": 7.0,
     "Travel Connectivity": 8.0, "Commute": 6.0, "Business Freedom": 4.5, "Safety": 8.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 8.5,
     "Taxation": 5.0, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 5.0, "Outdoors": 5.0})

add_city("Ahmedabad", "India", "Ahmedabad, Gujarat, India", "Asia",
    23.0225, 72.5714, 8650000,
    "India's first UNESCO World Heritage City blends centuries-old Gujarati architecture with a booming textile and diamond industry. Ahmedabad's legendary street food, Sabarmati Ashram history, and entrepreneurial culture make it a fascinating Indian city.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 5.5,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 3.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 5.0, "Tolerance": 5.0, "Outdoors": 3.5})

add_city("Bengaluru", "India", "Bengaluru, Karnataka, India", "Asia",
    12.9716, 77.5946, 13193000,
    "India's Silicon Valley enjoys a pleasant year-round climate at 900 meters elevation and leads the country's tech revolution. Bengaluru's cosmopolitan vibe, craft beer scene, and concentration of startups make it India's most globally connected city.",
    "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.5, "Startups": 7.5, "Venture Capital": 6.0,
     "Travel Connectivity": 6.5, "Commute": 3.0, "Business Freedom": 5.5, "Safety": 6.0,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 4.5, "Economy": 6.5,
     "Taxation": 5.5, "Internet Access": 6.0, "Leisure & Culture": 6.0, "Tolerance": 6.5, "Outdoors": 5.0})

add_city("Chennai", "India", "Chennai, Tamil Nadu, India", "Asia",
    13.0827, 80.2707, 11503000,
    "The cultural capital of South India sits on the Bay of Bengal with ancient temples, colonial heritage, and a thriving film industry. Chennai's strong IT sector, classical arts traditions, and Marina Beach create a distinctive blend of old and new.",
    "https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 8.0, "Startups": 5.5, "Venture Capital": 3.5,
     "Travel Connectivity": 6.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 6.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 4.0, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 6.0, "Tolerance": 5.5, "Outdoors": 5.0})

add_city("Delhi", "India", "Delhi, India", "Asia",
    28.7041, 77.1025, 32941000,
    "India's capital territory is a living museum spanning Mughal grandeur to modern skyscrapers, with street food that rivals any city on Earth. Delhi's scale, historical depth, and role as India's political heart make it an endlessly fascinating place.",
    "https://images.unsplash.com/photo-1587474260584-136574528ed5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 7.5, "Startups": 6.5, "Venture Capital": 5.5,
     "Travel Connectivity": 8.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 4.5,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 2.0, "Economy": 6.5,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 7.5, "Tolerance": 5.0, "Outdoors": 3.5})

add_city("Hyderabad", "India", "Hyderabad, Telangana, India", "Asia",
    17.3850, 78.4867, 10534000,
    "The City of Pearls blends Nizami heritage with a booming IT corridor, offering biryani that's worth relocating for alone. Hyderabad's lower cost of living and growing tech ecosystem make it one of India's most attractive cities for professionals.",
    "https://images.unsplash.com/photo-1572437153820-9ea47aec5e01?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 8.0, "Startups": 6.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 6.0,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 4.0, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 6.0, "Tolerance": 5.5, "Outdoors": 4.5})

add_city("Kolkata", "India", "Kolkata, West Bengal, India", "Asia",
    22.5726, 88.3639, 15134000,
    "The intellectual and cultural capital of India retains a colonial grandeur and literary tradition unlike any other Indian city. Kolkata's warmth, affordability, and rich artistic heritage from Tagore to Satyajit Ray make it deeply rewarding.",
    "https://images.unsplash.com/photo-1558431382-27e303142255?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 8.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.5, "Commute": 4.0, "Business Freedom": 4.5, "Safety": 5.5,
     "Healthcare": 5.5, "Education": 6.0, "Environmental Quality": 3.0, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 5.0, "Leisure & Culture": 7.0, "Tolerance": 6.0, "Outdoors": 3.5})

add_city("Mumbai", "India", "Mumbai, Maharashtra, India", "Asia",
    19.0760, 72.8777, 21297000,
    "India's maximum city is the financial capital and home of Bollywood, where dreams are forged amid skyscrapers and sea breezes. Mumbai's relentless energy, iconic street food, and cosmopolitan culture make it the city that never sleeps.",
    "https://images.unsplash.com/photo-1567157577867-05ccb1388e13?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.0, "Cost of Living": 5.5, "Startups": 7.0, "Venture Capital": 6.5,
     "Travel Connectivity": 8.0, "Commute": 3.0, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 3.0, "Economy": 7.0,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 7.5, "Tolerance": 6.0, "Outdoors": 4.0})

add_city("Surat", "India", "Surat, Gujarat, India", "Asia",
    21.1702, 72.8311, 7784000,
    "The diamond capital of the world processes 90% of the world's rough diamonds and is one of India's fastest-growing cities. Surat's entrepreneurial energy and famous street food scene make it a rising star in India's urban landscape.",
    "",
    {"Housing": 7.5, "Cost of Living": 8.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 4.5, "Commute": 4.0, "Business Freedom": 5.0, "Safety": 6.0,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 4.0, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 4.5, "Tolerance": 5.0, "Outdoors": 3.5})

add_city("Jakarta", "Indonesia", "Jakarta, Indonesia", "Asia",
    -6.2088, 106.8456, 10562088,
    "Indonesia's massive capital is a melting pot of cultures across a sprawling tropical metropolis with rapidly improving infrastructure. Jakarta's malls, street food, and vibrant nightlife sit alongside historic Kota Tua and countless local markets.",
    "https://images.unsplash.com/photo-1555899434-94d1368aa7af?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 7.0, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 7.0, "Commute": 2.5, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 3.0, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 6.0, "Tolerance": 5.0, "Outdoors": 4.0})

add_city("Medan", "Indonesia", "Medan, North Sumatra, Indonesia", "Asia",
    3.5952, 98.6722, 2435252,
    "Sumatra's largest city is a gateway to Lake Toba and offers some of Indonesia's most diverse and flavorful cuisine. Medan's multicultural fabric of Malay, Batak, Chinese, and Indian communities creates a unique cultural experience.",
    "",
    {"Housing": 7.5, "Cost of Living": 8.0, "Startups": 2.5, "Venture Capital": 1.5,
     "Travel Connectivity": 4.5, "Commute": 3.5, "Business Freedom": 4.5, "Safety": 5.0,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 4.0, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 4.5, "Leisure & Culture": 4.5, "Tolerance": 5.0, "Outdoors": 6.0})

add_city("Baghdad", "Iraq", "Baghdad, Iraq", "Asia",
    33.3152, 44.3661, 8126755,
    "One of the oldest continuously inhabited cities in the world, Baghdad was once the center of the Islamic Golden Age and seat of the Abbasid Caliphate. The city is slowly rebuilding and retains a rich cultural identity along the banks of the Tigris.",
    "",
    {"Housing": 7.0, "Cost of Living": 7.0, "Startups": 2.0, "Venture Capital": 1.0,
     "Travel Connectivity": 4.0, "Commute": 3.0, "Business Freedom": 3.0, "Safety": 2.5,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 3.0, "Economy": 3.5,
     "Taxation": 6.0, "Internet Access": 3.5, "Leisure & Culture": 4.5, "Tolerance": 3.0, "Outdoors": 2.5})

add_city("Almaty", "Kazakhstan", "Almaty, Kazakhstan", "Asia",
    43.2220, 76.8512, 2000900,
    "Kazakhstan's largest city sits dramatically beneath the snow-capped Tian Shan mountains with excellent skiing just minutes away. Almaty's tree-lined boulevards, growing cafe culture, and affordable living make it Central Asia's most cosmopolitan city.",
    "https://images.unsplash.com/photo-1562008825-45fbc60b0609?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 4.5, "Business Freedom": 5.0, "Safety": 6.0,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 5.0, "Economy": 5.0,
     "Taxation": 6.5, "Internet Access": 6.0, "Leisure & Culture": 5.5, "Tolerance": 5.0, "Outdoors": 8.0})

add_city("Wellington", "New Zealand", "Wellington, New Zealand", "Oceania",
    -41.2866, 174.7756, 215400,
    "New Zealand's compact capital is a creative hub nestled between harbor and hills, known for its craft coffee, film industry, and fierce winds. Wellington's walkability, vibrant arts scene, and stunning natural setting make it one of the world's most livable small capitals.",
    "https://images.unsplash.com/photo-1589871973318-9ca1258faa5d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 4.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 5.0, "Commute": 6.5, "Business Freedom": 8.5, "Safety": 8.5,
     "Healthcare": 8.0, "Education": 7.5, "Environmental Quality": 8.5, "Economy": 6.5,
     "Taxation": 5.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 8.5, "Outdoors": 9.0})

add_city("Karachi", "Pakistan", "Karachi, Pakistan", "Asia",
    24.8607, 67.0011, 16839950,
    "Pakistan's largest city and economic engine is a sprawling port metropolis on the Arabian Sea with incredible street food and resilient spirit. Karachi's diversity, beaches, and role as the country's commercial hub give it an energy all its own.",
    "https://images.unsplash.com/photo-1572710691839-5eccbb5765cb?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 8.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 2.5, "Business Freedom": 4.0, "Safety": 3.0,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 3.0, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 4.0, "Leisure & Culture": 5.0, "Tolerance": 3.5, "Outdoors": 3.5})

add_city("Lahore", "Pakistan", "Lahore, Punjab, Pakistan", "Asia",
    31.5204, 74.3587, 13979000,
    "Pakistan's cultural heart is a Mughal masterpiece with the Badshahi Mosque, Lahore Fort, and the best food in South Asia. The city's literary festivals, vibrant arts scene, and warm hospitality make it one of the subcontinent's most characterful cities.",
    "https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 8.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.5, "Commute": 3.0, "Business Freedom": 4.0, "Safety": 4.0,
     "Healthcare": 4.5, "Education": 5.0, "Environmental Quality": 2.5, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 4.5, "Leisure & Culture": 6.5, "Tolerance": 3.5, "Outdoors": 3.5})

add_city("Manila", "Philippines", "Manila, Philippines", "Asia",
    14.5995, 120.9842, 13923452,
    "The Philippines' chaotic, lovable capital overflows with energy across its mix of Spanish colonial churches, mega-malls, and vibrant street life. Manila's warmth extends from its tropical climate to its famously hospitable people and non-stop nightlife.",
    "https://images.unsplash.com/photo-1526137844794-45f1041f397a?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.5, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 2.0, "Business Freedom": 5.0, "Safety": 4.5,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 3.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 5.0, "Leisure & Culture": 6.0, "Tolerance": 6.0, "Outdoors": 5.0})

add_city("Riyadh", "Saudi Arabia", "Riyadh, Saudi Arabia", "Asia",
    24.7136, 46.6753, 7676654,
    "Saudi Arabia's rapidly transforming capital is investing billions in entertainment, culture, and futuristic projects under Vision 2030. Riyadh's tax-free salaries, modern infrastructure, and ambitious development make it one of the Middle East's most dynamic cities.",
    "https://images.unsplash.com/photo-1586724237569-9c5e0b60326b?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 5.0, "Venture Capital": 5.0,
     "Travel Connectivity": 7.0, "Commute": 4.0, "Business Freedom": 5.5, "Safety": 7.0,
     "Healthcare": 6.5, "Education": 5.5, "Environmental Quality": 4.0, "Economy": 7.0,
     "Taxation": 9.5, "Internet Access": 6.5, "Leisure & Culture": 4.5, "Tolerance": 2.5, "Outdoors": 3.0})

add_city("Busan", "South Korea", "Busan, South Korea", "Asia",
    35.1796, 129.0756, 3359527,
    "South Korea's stunning coastal second city offers beaches, mountains, hot springs, and some of the best seafood in Asia. Busan's film festival fame, temple stays, and more relaxed pace than Seoul make it an increasingly popular alternative.",
    "https://images.unsplash.com/photo-1538485399081-7a534a653954?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 6.0, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 7.0, "Commute": 6.5, "Business Freedom": 7.0, "Safety": 8.0,
     "Healthcare": 8.0, "Education": 7.0, "Environmental Quality": 6.5, "Economy": 6.5,
     "Taxation": 5.5, "Internet Access": 9.5, "Leisure & Culture": 7.0, "Tolerance": 5.5, "Outdoors": 8.0})

add_city("Taichung", "Taiwan", "Taichung, Taiwan", "Asia",
    24.1477, 120.6736, 2820787,
    "Taiwan's third-largest city is known for its pleasant climate, bubble tea origins, and thriving arts district in repurposed warehouses. Taichung offers a more relaxed alternative to Taipei with excellent food, green spaces, and nearby mountain scenery.",
    "",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 5.5, "Business Freedom": 7.0, "Safety": 8.5,
     "Healthcare": 8.0, "Education": 6.5, "Environmental Quality": 6.0, "Economy": 6.0,
     "Taxation": 6.0, "Internet Access": 8.0, "Leisure & Culture": 6.0, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Tashkent", "Uzbekistan", "Tashkent, Uzbekistan", "Asia",
    41.2995, 69.2401, 2909000,
    "Central Asia's largest city blends Soviet-era grandeur with ancient Silk Road heritage and is experiencing a tourism renaissance. Tashkent's incredible bazaars, hearty cuisine, and metro adorned with palatial stations make it a hidden gem.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 2.5, "Venture Capital": 1.5,
     "Travel Connectivity": 4.5, "Commute": 5.0, "Business Freedom": 4.0, "Safety": 6.0,
     "Healthcare": 4.5, "Education": 5.0, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 6.0, "Internet Access": 4.5, "Leisure & Culture": 5.5, "Tolerance": 4.5, "Outdoors": 5.0})

add_city("Ho Chi Minh City", "Vietnam", "Ho Chi Minh City, Vietnam", "Asia",
    10.8231, 106.6297, 9077158,
    "Vietnam's electric southern hub is a motorbike-fueled metropolis where French colonial villas share streets with gleaming towers and incredible pho stalls. HCMC's low cost of living, booming economy, and vibrant expat scene make it a top destination for digital nomads.",
    "https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 8.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 6.5, "Commute": 3.5, "Business Freedom": 4.5, "Safety": 6.5,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 4.0, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 6.0, "Leisure & Culture": 7.0, "Tolerance": 6.0, "Outdoors": 5.0})


# ═══════════════════════════════════════════════════════════════════════════════
# CENTRAL AMERICA & CARIBBEAN
# ═══════════════════════════════════════════════════════════════════════════════

add_city("San José", "Costa Rica", "San José, Costa Rica", "Central America",
    9.9281, -84.0907, 1453500,
    "Costa Rica's highland capital sits in a fertile valley surrounded by volcanoes and offers a springlike climate year-round. San José's stable democracy, universal healthcare, and 'pura vida' lifestyle make Costa Rica a top relocation destination.",
    "https://images.unsplash.com/photo-1605423221555-6a0e6e4ef2e0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 5.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.5, "Commute": 3.5, "Business Freedom": 6.0, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 6.0, "Environmental Quality": 7.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 6.0, "Leisure & Culture": 5.0, "Tolerance": 7.0, "Outdoors": 8.5})

add_city("San Salvador", "El Salvador", "San Salvador, El Salvador", "Central America",
    13.6929, -89.2182, 1767000,
    "El Salvador's compact capital sits in a valley ringed by volcanoes and is experiencing a renaissance as a Bitcoin-friendly destination. The city's pupusa culture, improving safety, and low costs are attracting a new wave of digital nomads.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.5, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 4.0,
     "Healthcare": 4.5, "Education": 4.5, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 6.0, "Internet Access": 5.0, "Leisure & Culture": 4.5, "Tolerance": 4.5, "Outdoors": 6.5})

add_city("Guatemala City", "Guatemala", "Guatemala City, Guatemala", "Central America",
    14.6349, -90.5069, 3015081,
    "Central America's largest city sits at 1,500 meters with a pleasant climate and serves as a gateway to Mayan ruins and volcanic landscapes. Guatemala City's affordable living and rich indigenous culture make it a base for exploring one of Latin America's most fascinating countries.",
    "",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 2.5, "Venture Capital": 1.5,
     "Travel Connectivity": 5.0, "Commute": 3.0, "Business Freedom": 5.0, "Safety": 3.5,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 6.0, "Internet Access": 5.0, "Leisure & Culture": 5.0, "Tolerance": 4.5, "Outdoors": 7.0})

add_city("Tegucigalpa", "Honduras", "Tegucigalpa, Honduras", "Central America",
    14.0723, -87.1921, 1200000,
    "Honduras's mountain capital offers affordable living and a gateway to Caribbean islands, Mayan ruins, and cloud forests. Despite challenges, Tegucigalpa's colonial center and surrounding pine-clad hills have a rugged appeal.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.0, "Startups": 2.0, "Venture Capital": 1.0,
     "Travel Connectivity": 3.5, "Commute": 3.0, "Business Freedom": 4.5, "Safety": 3.0,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 5.0, "Economy": 3.5,
     "Taxation": 6.0, "Internet Access": 4.0, "Leisure & Culture": 3.5, "Tolerance": 4.0, "Outdoors": 6.0})

add_city("Managua", "Nicaragua", "Managua, Nicaragua", "Central America",
    12.1150, -86.2362, 1055000,
    "Nicaragua's lakeside capital offers some of Central America's lowest costs of living with a warm tropical climate. Managua serves as a base to explore the country's volcanoes, colonial cities, and Pacific surf breaks.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 2.0, "Venture Capital": 1.0,
     "Travel Connectivity": 3.5, "Commute": 3.5, "Business Freedom": 3.5, "Safety": 4.5,
     "Healthcare": 3.5, "Education": 4.0, "Environmental Quality": 5.5, "Economy": 3.5,
     "Taxation": 6.0, "Internet Access": 4.0, "Leisure & Culture": 4.0, "Tolerance": 4.0, "Outdoors": 6.5})

add_city("Panama City", "Panama", "Panama City, Panama", "Central America",
    8.9824, -79.5199, 1900000,
    "Panama's glittering skyline rivals Miami's, built on a foundation of canal commerce, banking, and one of the Americas' best-connected airports. The city's dollarized economy, territorial tax system, and tropical setting attract retirees and entrepreneurs alike.",
    "https://images.unsplash.com/photo-1565110571338-b97a3f3c88a5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 3.5, "Venture Capital": 3.0,
     "Travel Connectivity": 7.5, "Commute": 3.5, "Business Freedom": 7.5, "Safety": 5.5,
     "Healthcare": 6.0, "Education": 5.0, "Environmental Quality": 6.0, "Economy": 6.0,
     "Taxation": 8.0, "Internet Access": 6.0, "Leisure & Culture": 5.5, "Tolerance": 5.5, "Outdoors": 7.0})

# ═══════════════════════════════════════════════════════════════════════════════
# EUROPE
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Tirana", "Albania", "Tirana, Albania", "Europe",
    41.3275, 19.8187, 862361,
    "Albania's colorful capital is Europe's best-kept secret with incredibly low costs, vibrant nightlife, and Mediterranean warmth. Tirana's rapid transformation, cafe culture, and proximity to stunning Albanian beaches make it a rising digital nomad hub.",
    "https://images.unsplash.com/photo-1580224529907-bde5cad258d8?auto=format&fit=crop&w=800&q=80",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.0, "Commute": 4.5, "Business Freedom": 5.0, "Safety": 6.0,
     "Healthcare": 4.5, "Education": 5.0, "Environmental Quality": 5.5, "Economy": 4.5,
     "Taxation": 7.0, "Internet Access": 5.5, "Leisure & Culture": 5.5, "Tolerance": 6.0, "Outdoors": 7.0})

add_city("Graz", "Austria", "Graz, Austria", "Europe",
    47.0707, 15.4395, 291134,
    "Austria's second city is a UNESCO-listed gem with red-roofed old town charm and a cutting-edge arts and design scene. Graz's university culture, excellent food scene, and proximity to Alpine skiing offer a high quality of life at lower costs than Vienna.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 8.5,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 8.0, "Economy": 7.0,
     "Taxation": 3.5, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 7.5, "Outdoors": 8.0})

add_city("Baku", "Azerbaijan", "Baku, Azerbaijan", "Europe",
    40.4093, 49.8671, 2303000,
    "Azerbaijan's Caspian Sea capital is a striking blend of medieval walled city and futuristic flame-shaped towers. Oil wealth has transformed Baku into a glamorous crossroads between Europe and Asia with world-class architecture.",
    "https://images.unsplash.com/photo-1570168196758-2b34e452d7f5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 5.0, "Business Freedom": 4.5, "Safety": 6.5,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 5.0, "Economy": 5.5,
     "Taxation": 6.5, "Internet Access": 5.5, "Leisure & Culture": 6.0, "Tolerance": 4.5, "Outdoors": 5.5})

add_city("Minsk", "Belarus", "Minsk, Belarus", "Europe",
    53.9006, 27.5590, 2009786,
    "Belarus's Soviet-grand capital features wide boulevards, monumental architecture, and a growing IT sector that earned it the nickname 'Silicon Forest.' Minsk offers very affordable European living with a surprisingly vibrant cafe and nightlife scene.",
    "",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 5.0, "Venture Capital": 2.5,
     "Travel Connectivity": 4.5, "Commute": 6.5, "Business Freedom": 3.5, "Safety": 7.0,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 4.5,
     "Taxation": 6.0, "Internet Access": 6.5, "Leisure & Culture": 5.0, "Tolerance": 4.0, "Outdoors": 4.5})

add_city("Antwerp", "Belgium", "Antwerp, Belgium", "Europe",
    51.2194, 4.4025, 529247,
    "Belgium's diamond capital and fashion hub sits on the Scheldt River with a stunning medieval center and cutting-edge design district. Antwerp's world-class museums, chocolate and beer traditions, and compact walkability make it a sophisticated European base.",
    "https://images.unsplash.com/photo-1555578325-4f0e93a49b09?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 4.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 7.0, "Commute": 7.0, "Business Freedom": 7.5, "Safety": 7.0,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 6.5, "Economy": 7.0,
     "Taxation": 3.0, "Internet Access": 8.0, "Leisure & Culture": 8.0, "Tolerance": 8.0, "Outdoors": 5.0})

add_city("Brussels", "Belgium", "Brussels, Belgium", "Europe",
    50.8503, 4.3517, 1208542,
    "The de facto capital of Europe hosts NATO and EU headquarters while serving up the world's finest chocolate, waffles, and beer. Brussels' multicultural neighborhoods, Art Nouveau architecture, and international community make it a truly cosmopolitan city.",
    "https://images.unsplash.com/photo-1559113202-c916b8e44373?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 4.5, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 8.5, "Commute": 6.5, "Business Freedom": 7.5, "Safety": 6.5,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 6.0, "Economy": 7.0,
     "Taxation": 2.5, "Internet Access": 8.0, "Leisure & Culture": 8.0, "Tolerance": 8.5, "Outdoors": 4.5})

add_city("Plovdiv", "Bulgaria", "Plovdiv, Bulgaria", "Europe",
    42.1354, 24.7453, 346893,
    "One of the oldest continuously inhabited cities in the world, Plovdiv enchants with Roman ruins, Ottoman mosques, and a bohemian creative quarter. As a European Capital of Culture, this affordable Bulgarian gem offers outstanding wine country living.",
    "",
    {"Housing": 8.5, "Cost of Living": 8.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.0, "Commute": 5.5, "Business Freedom": 6.0, "Safety": 7.0,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 6.0, "Economy": 4.5,
     "Taxation": 7.0, "Internet Access": 6.5, "Leisure & Culture": 6.5, "Tolerance": 5.5, "Outdoors": 6.5})

add_city("Sofia", "Bulgaria", "Sofia, Bulgaria", "Europe",
    42.6977, 23.3219, 1307439,
    "Bulgaria's mountain-backed capital offers European living at a fraction of Western prices with a growing tech and startup scene. Sofia's ancient Thracian and Roman heritage, vibrant nightlife, and proximity to ski slopes make it an increasingly popular base.",
    "https://images.unsplash.com/photo-1601284271321-16c390255dc5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 8.0, "Startups": 5.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 5.5, "Business Freedom": 6.0, "Safety": 7.0,
     "Healthcare": 5.5, "Education": 6.0, "Environmental Quality": 5.5, "Economy": 5.0,
     "Taxation": 7.5, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 5.0, "Outdoors": 7.5})

add_city("Varna", "Bulgaria", "Varna, Bulgaria", "Europe",
    43.2141, 27.9147, 335854,
    "Bulgaria's seaside gem on the Black Sea combines beautiful beaches with ancient Roman baths and a lively summer festival scene. Varna offers an incredibly affordable coastal European lifestyle with a growing expat community.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 2.5, "Venture Capital": 1.5,
     "Travel Connectivity": 4.0, "Commute": 5.5, "Business Freedom": 6.0, "Safety": 7.5,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 7.0, "Economy": 4.5,
     "Taxation": 7.0, "Internet Access": 6.5, "Leisure & Culture": 6.0, "Tolerance": 5.5, "Outdoors": 7.5})

add_city("Zagreb", "Croatia", "Zagreb, Croatia", "Europe",
    45.8150, 15.9819, 806341,
    "Croatia's underrated capital charms with Austro-Hungarian architecture, a lively cafe scene, and outdoor markets brimming with local produce. Zagreb offers a high quality of life at a fraction of Western European prices with the Adriatic coast just hours away.",
    "https://images.unsplash.com/photo-1557144059-c5f2e9160d64?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 6.0, "Business Freedom": 6.0, "Safety": 8.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 7.0, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 7.0})

add_city("Lyon", "France", "Lyon, France", "Europe",
    45.7640, 4.8357, 1748710,
    "France's gastronomic capital sits at the confluence of the Rhone and Saone rivers with a UNESCO-listed old town and legendary food scene. Lyon offers Parisian sophistication at lower prices with better quality of life and proximity to the Alps.",
    "https://images.unsplash.com/photo-1524396309943-e03f5249f002?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 7.5, "Commute": 7.0, "Business Freedom": 7.0, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 8.0, "Environmental Quality": 6.5, "Economy": 7.0,
     "Taxation": 3.0, "Internet Access": 8.0, "Leisure & Culture": 8.5, "Tolerance": 7.5, "Outdoors": 7.0})

add_city("Marseille", "France", "Marseille, France", "Europe",
    43.2965, 5.3698, 1620000,
    "France's oldest city and Mediterranean port pulses with multicultural energy, world-class bouillabaisse, and dramatic calanques coastline. Marseille's gritty charm, sunny climate, and creative renaissance make it France's most exciting city.",
    "https://images.unsplash.com/photo-1589394760104-290d0df3d2c9?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 7.0, "Commute": 6.0, "Business Freedom": 7.0, "Safety": 5.5,
     "Healthcare": 9.0, "Education": 7.0, "Environmental Quality": 7.0, "Economy": 5.5,
     "Taxation": 3.0, "Internet Access": 7.5, "Leisure & Culture": 7.5, "Tolerance": 7.0, "Outdoors": 8.5})

add_city("Montpellier", "France", "Montpellier, France", "Europe",
    43.6108, 3.8767, 459000,
    "This sun-drenched southern French city boasts a medieval center, thriving university scene, and Mediterranean beaches minutes away. Montpellier's youth energy, outstanding food, and lower costs than Paris make it one of France's fastest-growing cities.",
    "",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 6.5, "Business Freedom": 7.0, "Safety": 6.5,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 7.5, "Economy": 5.5,
     "Taxation": 3.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 7.5})

add_city("Nantes", "France", "Nantes, France", "Europe",
    47.2184, -1.5536, 660000,
    "This creative Loire Valley city was voted France's best city to live in, with an innovative arts scene including the famous mechanical elephant. Nantes blends maritime heritage with a green, bikeable urban fabric and proximity to Atlantic beaches.",
    "",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.0, "Commute": 7.0, "Business Freedom": 7.0, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 7.5, "Economy": 6.0,
     "Taxation": 3.0, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 6.5})

add_city("Tbilisi", "Georgia", "Tbilisi, Georgia", "Europe",
    41.7151, 44.8271, 1171100,
    "Georgia's enchanting capital cascades down hillsides with sulfur baths, ornate balconies, and some of the world's oldest wine traditions. Tbilisi's incredible food, low costs, and welcoming visa policies have made it a top destination for remote workers.",
    "https://images.unsplash.com/photo-1565008576549-57569a49371d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 4.5, "Commute": 5.0, "Business Freedom": 7.0, "Safety": 6.5,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 6.0, "Economy": 4.5,
     "Taxation": 7.5, "Internet Access": 6.0, "Leisure & Culture": 7.0, "Tolerance": 5.0, "Outdoors": 7.5})


# Germany
add_city("Bremen", "Germany", "Bremen, Germany", "Europe",
    53.0793, 8.8017, 569352,
    "This Hanseatic city on the Weser River charms with its fairytale Town Musicians statue, medieval market square, and thriving craft beer scene. Bremen's compact size, strong economy, and maritime heritage offer quintessential northern German living.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 7.5,
     "Healthcare": 9.0, "Education": 7.0, "Environmental Quality": 7.0, "Economy": 6.5,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 6.0, "Tolerance": 7.5, "Outdoors": 5.0})

add_city("Dortmund", "Germany", "Dortmund, Germany", "Europe",
    51.5136, 7.4653, 588250,
    "Once a steel and coal powerhouse, Dortmund has reinvented itself with a vibrant tech scene, Germany's largest football stadium, and excellent beer culture. The city's affordable rents and central Ruhr Valley location make it an accessible German base.",
    "",
    {"Housing": 6.5, "Cost of Living": 6.0, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 7.0, "Environmental Quality": 6.0, "Economy": 6.0,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 6.0, "Tolerance": 7.0, "Outdoors": 5.0})

add_city("Dresden", "Germany", "Dresden, Germany", "Europe",
    51.0504, 13.7373, 556780,
    "The 'Florence on the Elbe' has been magnificently rebuilt after WWII, with baroque palaces and a world-class arts scene amid Saxony's rolling hills. Dresden offers affordable east German living with stunning architecture and proximity to Saxon Switzerland national park.",
    "https://images.unsplash.com/photo-1528729280617-e498e1e0d3f0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.0, "Startups": 4.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 7.5,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 7.5, "Economy": 6.0,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.5, "Tolerance": 6.5, "Outdoors": 7.0})

add_city("Düsseldorf", "Germany", "Düsseldorf, Germany", "Europe",
    51.2277, 6.7735, 619294,
    "Germany's fashion and advertising capital on the Rhine features a glamorous shopping boulevard and one of Europe's best Japanese communities. Düsseldorf's Altstadt brewery pubs, riverside promenade, and strong economy make it a polished place to live.",
    "",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 7.5, "Commute": 7.5, "Business Freedom": 8.0, "Safety": 7.5,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 6.5, "Economy": 7.5,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 5.5})

add_city("Frankfurt am Main", "Germany", "Frankfurt am Main, Germany", "Europe",
    50.1109, 8.6821, 764104,
    "Germany's financial capital boasts a dramatic skyline (rare in Europe), the continent's busiest airport, and a surprisingly multicultural dining scene. Frankfurt's high salaries, central location, and world-class connectivity make it ideal for international professionals.",
    "https://images.unsplash.com/photo-1467269204594-9661b134dd2b?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.5, "Cost of Living": 4.0, "Startups": 6.0, "Venture Capital": 7.0,
     "Travel Connectivity": 9.5, "Commute": 7.5, "Business Freedom": 8.5, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 6.5, "Economy": 8.5,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 8.0, "Outdoors": 5.5})

add_city("Hamburg", "Germany", "Hamburg, Germany", "Europe",
    53.5511, 9.9937, 1899160,
    "Germany's gateway to the world is a maritime metropolis with more bridges than Venice, a legendary port, and the Beatles' old stomping grounds. Hamburg's Speicherstadt warehouse district, Elbphilharmonie concert hall, and vibrant Reeperbahn nightlife make it irresistible.",
    "https://images.unsplash.com/photo-1535570015900-7be4a15b89b4?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 4.5, "Startups": 6.0, "Venture Capital": 4.5,
     "Travel Connectivity": 8.0, "Commute": 7.5, "Business Freedom": 8.0, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 7.0, "Economy": 7.5,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 8.0, "Tolerance": 8.5, "Outdoors": 6.0})

add_city("Leipzig", "Germany", "Leipzig, Germany", "Europe",
    51.3397, 12.3731, 601866,
    "Leipzig is Germany's coolest up-and-coming city, attracting artists and entrepreneurs with dirt-cheap rents and a thriving creative scene. Bach's city has reinvented itself as an alternative culture hub with excellent dining and a booming startup ecosystem.",
    "",
    {"Housing": 7.0, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 6.5, "Economy": 5.5,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.5, "Tolerance": 7.0, "Outdoors": 5.0})

add_city("Nuremberg", "Germany", "Nuremberg, Germany", "Europe",
    49.4521, 11.0767, 518370,
    "Bavaria's second city offers a perfectly preserved medieval old town, legendary Christmas market, and excellent bratwurst at a fraction of Munich's prices. Nuremberg's central location, strong job market, and family-friendly atmosphere make it an underrated German choice.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 8.0,
     "Healthcare": 9.0, "Education": 7.0, "Environmental Quality": 7.0, "Economy": 7.0,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 6.0})

add_city("Stuttgart", "Germany", "Stuttgart, Germany", "Europe",
    48.7758, 9.1829, 634830,
    "The home of Mercedes-Benz and Porsche sits in a vine-covered valley with a strong automotive economy and excellent quality of life. Stuttgart's surrounding wine country, mineral baths, and innovative engineering culture make it quietly one of Germany's best cities.",
    "",
    {"Housing": 4.0, "Cost of Living": 4.5, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 6.5, "Commute": 7.0, "Business Freedom": 8.0, "Safety": 8.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 7.0, "Economy": 8.0,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Athens", "Greece", "Athens, Greece", "Europe",
    37.9838, 23.7275, 3153355,
    "The cradle of Western civilization still inspires with the Acropolis overlooking a city that blends ancient ruins with gritty urban cool and incredible food. Athens' low costs, year-round sunshine, and proximity to island-hopping make it a magnetic Mediterranean base.",
    "https://images.unsplash.com/photo-1555993539-1732b0258235?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 6.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 7.0, "Commute": 6.0, "Business Freedom": 5.5, "Safety": 6.5,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 5.5, "Economy": 4.5,
     "Taxation": 4.0, "Internet Access": 7.0, "Leisure & Culture": 8.5, "Tolerance": 6.5, "Outdoors": 7.0})

add_city("Budapest", "Hungary", "Budapest, Hungary", "Europe",
    47.4979, 19.0402, 1752286,
    "Straddling the Danube with thermal baths, ruin bars, and stunning Art Nouveau architecture, Budapest is Central Europe's most beautiful capital. The city offers Western European culture at Eastern European prices with a vibrant nightlife that rivals Berlin.",
    "https://images.unsplash.com/photo-1541849546-216549ae216d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 7.0, "Commute": 7.0, "Business Freedom": 6.0, "Safety": 7.5,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 8.5, "Tolerance": 5.5, "Outdoors": 6.5})

# Italy
add_city("Bologna", "Italy", "Bologna, Italy", "Europe",
    44.4949, 11.3426, 394463,
    "Italy's foodie capital is home to the oldest university in the world, portico-covered streets, and the richest cuisine in the country. Bologna's progressive culture, excellent healthcare, and central location make it many Italians' favorite city.",
    "https://images.unsplash.com/photo-1598950527412-bb1e9a218100?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 6.5, "Business Freedom": 6.5, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 8.0, "Environmental Quality": 6.0, "Economy": 6.5,
     "Taxation": 3.5, "Internet Access": 7.0, "Leisure & Culture": 8.5, "Tolerance": 7.5, "Outdoors": 6.0})

add_city("Genoa", "Italy", "Genoa, Italy", "Europe",
    44.4056, 8.9463, 565752,
    "Italy's largest port city cascades down to the Ligurian Sea with a labyrinthine medieval center and seafood-centric cuisine. Genoa's dramatic coastline, pesto tradition, and proximity to the Italian Riviera offer Mediterranean living at prices well below Rome or Milan.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 5.5, "Business Freedom": 6.5, "Safety": 6.5,
     "Healthcare": 8.0, "Education": 7.0, "Environmental Quality": 6.5, "Economy": 5.5,
     "Taxation": 3.5, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 7.5})

add_city("Milan", "Italy", "Milan, Italy", "Europe",
    45.4642, 9.1900, 1396059,
    "Italy's fashion and financial capital is a powerhouse of design, innovation, and La Dolce Vita at high speed. Milan's world-class dining, opera at La Scala, and proximity to Lake Como and the Alps make it northern Italy's crown jewel.",
    "https://images.unsplash.com/photo-1520440229-6469639b1dfa?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.0, "Cost of Living": 3.5, "Startups": 6.0, "Venture Capital": 5.5,
     "Travel Connectivity": 9.0, "Commute": 6.5, "Business Freedom": 6.5, "Safety": 7.0,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 5.0, "Economy": 7.5,
     "Taxation": 3.0, "Internet Access": 7.5, "Leisure & Culture": 9.0, "Tolerance": 7.0, "Outdoors": 6.5})

add_city("Naples", "Italy", "Naples, Italy", "Europe",
    40.8518, 14.2681, 2175000,
    "The birthplace of pizza is a raw, passionate city where Vesuvius looms over chaotic streets filled with the best street food in Italy. Naples' unfiltered authenticity, archaeological treasures, and proximity to the Amalfi Coast make it thrillingly real.",
    "https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 5.5, "Safety": 5.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 4.5,
     "Taxation": 3.5, "Internet Access": 6.5, "Leisure & Culture": 8.0, "Tolerance": 6.0, "Outdoors": 8.0})

add_city("Palermo", "Italy", "Palermo, Sicily, Italy", "Europe",
    38.1157, 13.3615, 663401,
    "Sicily's chaotic, gorgeous capital is a layered palimpsest of Arab, Norman, and Baroque architecture with Italy's best street food. Palermo's markets, Mediterranean climate, and incredibly low costs for Western Europe make it a hidden gem.",
    "https://images.unsplash.com/photo-1523365280197-f1783db9fe62?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 7.0, "Startups": 2.5, "Venture Capital": 1.5,
     "Travel Connectivity": 5.0, "Commute": 4.5, "Business Freedom": 5.5, "Safety": 5.5,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 6.0, "Economy": 4.0,
     "Taxation": 3.5, "Internet Access": 6.0, "Leisure & Culture": 7.5, "Tolerance": 6.0, "Outdoors": 8.0})

add_city("Rome", "Italy", "Rome, Italy", "Europe",
    41.9028, 12.4964, 2873000,
    "The Eternal City is an open-air museum where 2,500 years of history unfold around every corner, from the Colosseum to St. Peter's Basilica. Rome's unmatched cultural heritage, world-class cuisine, and dolce vita lifestyle make it endlessly captivating.",
    "https://images.unsplash.com/photo-1552832230-c0197dd311b5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.5, "Cost of Living": 4.0, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 8.5, "Commute": 5.0, "Business Freedom": 5.5, "Safety": 6.5,
     "Healthcare": 8.0, "Education": 7.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 3.0, "Internet Access": 7.0, "Leisure & Culture": 10.0, "Tolerance": 7.0, "Outdoors": 6.0})

add_city("Turin", "Italy", "Turin, Piedmont, Italy", "Europe",
    45.0703, 7.6869, 870952,
    "The elegant capital of Piedmont is Italy's underrated gem, offering baroque architecture, chocolate traditions, and the country's finest wine region at the doorstep. Turin's affordability compared to Milan, Alpine backdrop, and strong automotive heritage make it a savvy Italian choice.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 6.5, "Business Freedom": 6.5, "Safety": 7.0,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 3.5, "Internet Access": 7.0, "Leisure & Culture": 7.5, "Tolerance": 7.0, "Outdoors": 7.5})


# Rest of Europe
add_city("Astana", "Kazakhstan", "Astana, Kazakhstan", "Europe",
    51.1694, 71.4491, 1350228,
    "Kazakhstan's futuristic capital rose from the steppe with bold architecture by Foster and Hadid, symbolizing the country's ambitions. Astana's extreme continental climate and surreal cityscape make it one of the world's most unique capitals.",
    "https://images.unsplash.com/photo-1558431041-eec9e8b3d1c0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 5.5, "Business Freedom": 5.5, "Safety": 7.0,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 6.0, "Economy": 5.5,
     "Taxation": 7.0, "Internet Access": 6.0, "Leisure & Culture": 5.0, "Tolerance": 5.0, "Outdoors": 4.5})

add_city("Riga", "Latvia", "Riga, Latvia", "Europe",
    56.9496, 24.1052, 614618,
    "Latvia's Art Nouveau gem on the Baltic features the finest collection of Jugendstil architecture in Europe and a vibrant Old Town. Riga's craft cocktail scene, affordable living, and digital-forward culture make it a top European destination for remote workers.",
    "https://images.unsplash.com/photo-1524224313114-523dfd9f3cce?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 4.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 6.0, "Business Freedom": 7.0, "Safety": 7.0,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 7.0, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 5.5})

add_city("Kaunas", "Lithuania", "Kaunas, Lithuania", "Europe",
    54.8985, 23.9036, 310284,
    "Lithuania's second city is a compact Art Deco treasure with a growing creative scene and strong university culture. Kaunas's walkable center, affordable living, and 2022 European Capital of Culture status signal its rising appeal.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 4.5, "Commute": 6.0, "Business Freedom": 7.0, "Safety": 7.5,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 7.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 5.5, "Tolerance": 5.5, "Outdoors": 5.5})

add_city("Vilnius", "Lithuania", "Vilnius, Lithuania", "Europe",
    54.6872, 25.2797, 580020,
    "Lithuania's baroque capital is one of Europe's best-kept secrets with a stunning UNESCO Old Town and one of the fastest-growing tech scenes in the Baltics. Vilnius's creative energy, excellent internet, and low costs attract a growing international community.",
    "https://images.unsplash.com/photo-1549891472-991e6bc75d1e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 5.5, "Venture Capital": 3.0,
     "Travel Connectivity": 5.0, "Commute": 6.0, "Business Freedom": 7.5, "Safety": 7.5,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 7.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 8.0, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 6.0})

add_city("Luxembourg City", "Luxembourg", "Luxembourg City, Luxembourg", "Europe",
    49.6117, 6.1319, 132778,
    "This tiny grand duchy capital sits dramatically atop gorges with a fairy-tale old town and the highest GDP per capita in the world. Luxembourg's multilingual culture, excellent connectivity, and role as an EU financial center make it uniquely cosmopolitan.",
    "https://images.unsplash.com/photo-1558362477-9a5baa6daf0e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.0, "Cost of Living": 2.5, "Startups": 5.0, "Venture Capital": 5.5,
     "Travel Connectivity": 7.0, "Commute": 7.0, "Business Freedom": 9.0, "Safety": 9.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 8.0, "Economy": 9.0,
     "Taxation": 4.5, "Internet Access": 8.5, "Leisure & Culture": 6.0, "Tolerance": 8.5, "Outdoors": 6.0})

add_city("Monaco", "Monaco", "Monaco, Monaco", "Europe",
    43.7384, 7.4246, 39244,
    "The world's most glamorous microstate packs F1 races, superyachts, and billionaire lifestyles into less than two square kilometers on the French Riviera. Monaco's zero income tax, Mediterranean climate, and unmatched luxury make it the ultimate prestige address.",
    "https://images.unsplash.com/photo-1526129318478-62ed807ebdf9?auto=format&fit=crop&w=800&q=80",
    {"Housing": 1.0, "Cost of Living": 1.0, "Startups": 3.5, "Venture Capital": 4.0,
     "Travel Connectivity": 7.0, "Commute": 7.5, "Business Freedom": 8.0, "Safety": 9.5,
     "Healthcare": 9.5, "Education": 7.0, "Environmental Quality": 7.0, "Economy": 8.0,
     "Taxation": 10.0, "Internet Access": 8.5, "Leisure & Culture": 7.5, "Tolerance": 6.5, "Outdoors": 6.5})

add_city("Rotterdam", "Netherlands", "Rotterdam, Netherlands", "Europe",
    51.9244, 4.4777, 651631,
    "Europe's largest port city was rebuilt after WWII with bold modern architecture that makes it the anti-Amsterdam. Rotterdam's innovative food halls, thriving music scene, and diverse neighborhoods offer a grittier, more affordable Dutch experience.",
    "https://images.unsplash.com/photo-1543872084-c7bd3822856f?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 4.5, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 8.0, "Commute": 8.0, "Business Freedom": 8.5, "Safety": 7.0,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 7.0, "Economy": 7.5,
     "Taxation": 3.5, "Internet Access": 9.0, "Leisure & Culture": 7.5, "Tolerance": 9.0, "Outdoors": 5.5})

add_city("The Hague", "Netherlands", "The Hague, Netherlands", "Europe",
    52.0705, 4.3007, 545838,
    "The seat of the Dutch government and International Court of Justice has a regal charm with tree-lined boulevards and North Sea beaches. The Hague's international community, excellent infrastructure, and seaside location make it a refined alternative to Amsterdam.",
    "",
    {"Housing": 4.0, "Cost of Living": 4.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 8.0, "Commute": 8.0, "Business Freedom": 8.5, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 7.5, "Economy": 7.0,
     "Taxation": 3.5, "Internet Access": 9.0, "Leisure & Culture": 7.0, "Tolerance": 9.0, "Outdoors": 6.5})

add_city("Skopje", "North Macedonia", "Skopje, North Macedonia", "Europe",
    41.9973, 21.4280, 544086,
    "North Macedonia's quirky capital underwent a controversial neoclassical makeover but retains authentic Ottoman bazaars and incredible Balkan food. Skopje's rock-bottom costs, warm hospitality, and growing digital nomad scene make it one of Europe's cheapest bases.",
    "",
    {"Housing": 8.5, "Cost of Living": 9.0, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.0, "Commute": 5.0, "Business Freedom": 5.5, "Safety": 6.5,
     "Healthcare": 5.0, "Education": 5.5, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 7.5, "Internet Access": 6.0, "Leisure & Culture": 5.0, "Tolerance": 5.0, "Outdoors": 6.0})

add_city("Oslo", "Norway", "Oslo, Norway", "Europe",
    59.9139, 10.7522, 1064235,
    "Norway's fjord-side capital combines Scandinavian design, world-class museums, and direct access to forests and ski slopes within city limits. Oslo's exceptional quality of life, progressive values, and stunning natural setting justify its famously high prices.",
    "https://images.unsplash.com/photo-1503504493248-17e60fc49a5b?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.0, "Cost of Living": 1.5, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 7.0, "Commute": 7.5, "Business Freedom": 9.0, "Safety": 9.0,
     "Healthcare": 9.5, "Education": 8.5, "Environmental Quality": 9.0, "Economy": 8.0,
     "Taxation": 2.0, "Internet Access": 9.0, "Leisure & Culture": 7.5, "Tolerance": 9.5, "Outdoors": 9.0})

# Poland
add_city("Kraków", "Poland", "Kraków, Poland", "Europe",
    50.0647, 19.9450, 779115,
    "Poland's cultural capital enchants with its perfectly preserved medieval center, legendary jazz clubs, and one of Europe's liveliest food scenes. Kraków's world-class universities, affordable living, and proximity to the Tatra Mountains make it irresistible.",
    "https://images.unsplash.com/photo-1519197924294-4ba991a11128?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 6.0, "Business Freedom": 6.5, "Safety": 7.5,
     "Healthcare": 6.0, "Education": 7.5, "Environmental Quality": 4.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 8.0, "Tolerance": 5.5, "Outdoors": 7.0})

add_city("Poznań", "Poland", "Poznań, Poland", "Europe",
    52.4064, 16.9252, 534813,
    "The birthplace of Poland is a vibrant university city known for its colorful Old Market Square and legendary croissants. Poznań's strong economy, international trade fairs, and central location between Berlin and Warsaw make it a practical Polish base.",
    "",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 4.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 6.0, "Business Freedom": 6.5, "Safety": 7.5,
     "Healthcare": 6.0, "Education": 7.0, "Environmental Quality": 6.0, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 5.5, "Outdoors": 5.0})

add_city("Wrocław", "Poland", "Wrocław, Poland", "Europe",
    51.1079, 17.0385, 642869,
    "Poland's 'Venice' spreads across 12 islands connected by 130 bridges with a stunning Market Square and playful dwarf statues hidden citywide. Wrocław's tech hub status, student energy, and affordable elegance make it one of Central Europe's most appealing cities.",
    "https://images.unsplash.com/photo-1573502344312-1a1b1a1a1a1a?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 5.5, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 6.0, "Business Freedom": 6.5, "Safety": 7.5,
     "Healthcare": 6.0, "Education": 7.5, "Environmental Quality": 6.0, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 6.0, "Outdoors": 5.5})

add_city("Porto", "Portugal", "Porto, Portugal", "Europe",
    41.1579, -8.6291, 1312947,
    "Portugal's second city cascades down to the Douro River with colorful tiled facades, world-famous port wine cellars, and a rugged Atlantic coastline. Porto's growing tech scene, outstanding food, and significantly lower costs than Lisbon make it one of Europe's hottest destinations.",
    "https://images.unsplash.com/photo-1555881400-74d7acaacd8b?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.5, "Startups": 5.0, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 6.0, "Business Freedom": 7.5, "Safety": 8.0,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 7.5, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 7.5, "Leisure & Culture": 8.0, "Tolerance": 8.0, "Outdoors": 7.5})

add_city("Bucharest", "Romania", "Bucharest, Romania", "Europe",
    44.4268, 26.1025, 1883425,
    "Romania's capital surprises with its 'Little Paris' Belle Époque architecture, booming tech sector, and some of Europe's best nightlife. Bucharest's ultra-fast internet, low costs, and thriving startup ecosystem make it a magnet for digital professionals.",
    "https://images.unsplash.com/photo-1558442074-3c19857bc1dc?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 5.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 6.5, "Safety": 6.5,
     "Healthcare": 5.5, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 5.5,
     "Taxation": 7.0, "Internet Access": 8.5, "Leisure & Culture": 7.0, "Tolerance": 5.5, "Outdoors": 5.0})

add_city("Moscow", "Russia", "Moscow, Russia", "Europe",
    55.7558, 37.6173, 12632409,
    "Russia's grand capital is a city of superlatives with the Kremlin, world-class metro, and a cultural scene spanning the Bolshoi to cutting-edge galleries. Moscow's sheer scale, imperial architecture, and intense urban energy make it one of the world's great metropolises.",
    "https://images.unsplash.com/photo-1513326738677-b964603b136d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.5, "Cost of Living": 4.5, "Startups": 5.5, "Venture Capital": 4.5,
     "Travel Connectivity": 8.0, "Commute": 5.5, "Business Freedom": 4.0, "Safety": 6.0,
     "Healthcare": 6.5, "Education": 7.5, "Environmental Quality": 4.5, "Economy": 6.5,
     "Taxation": 7.0, "Internet Access": 7.0, "Leisure & Culture": 9.0, "Tolerance": 4.0, "Outdoors": 4.5})

add_city("Saint Petersburg", "Russia", "Saint Petersburg, Russia", "Europe",
    59.9343, 30.3351, 5384342,
    "Russia's cultural capital is an open-air museum of imperial palaces, canals, and White Nights summer magic along the Neva River. St. Petersburg's Hermitage Museum, literary heritage, and northern grandeur make it one of Europe's most breathtaking cities.",
    "https://images.unsplash.com/photo-1556610961-2fecc5927173?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 5.5, "Business Freedom": 4.0, "Safety": 6.0,
     "Healthcare": 6.0, "Education": 7.5, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 7.0, "Internet Access": 7.0, "Leisure & Culture": 9.5, "Tolerance": 4.0, "Outdoors": 5.0})

add_city("Belgrade", "Serbia", "Belgrade, Serbia", "Europe",
    44.7866, 20.4489, 1378682,
    "Serbia's dynamic capital sits at the confluence of the Danube and Sava rivers with a legendary nightlife scene and turbulent history turned creative energy. Belgrade's riverside clubs, hearty cuisine, and rock-bottom prices make it one of Europe's most exciting cities.",
    "https://images.unsplash.com/photo-1592502712628-41320785b8a0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 7.5, "Startups": 4.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 5.5, "Business Freedom": 5.5, "Safety": 6.5,
     "Healthcare": 5.5, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 4.5,
     "Taxation": 6.5, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 5.0, "Outdoors": 5.5})


# Spain
add_city("Madrid", "Spain", "Madrid, Spain", "Europe",
    40.4168, -3.7038, 3305408,
    "Spain's passionate capital pulses with world-class art museums, legendary nightlife that starts at midnight, and tapas bars on every corner. Madrid's central location, sunny climate, and vibrant cultural scene make it one of Europe's most livable capitals.",
    "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 5.0, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 9.0, "Commute": 7.5, "Business Freedom": 7.0, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 6.0, "Economy": 6.5,
     "Taxation": 4.0, "Internet Access": 8.0, "Leisure & Culture": 9.5, "Tolerance": 8.5, "Outdoors": 5.5})

add_city("Málaga", "Spain", "Málaga, Spain", "Europe",
    36.7213, -4.4214, 578460,
    "Picasso's birthplace on the Costa del Sol has transformed from beach resort to tech hub with a thriving startup ecosystem and year-round sunshine. Málaga's combination of Mediterranean beaches, cultural renaissance, and growing international community makes it Spain's hottest city.",
    "https://images.unsplash.com/photo-1564395917367-a3e2b2f50a60?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 5.0, "Venture Capital": 3.0,
     "Travel Connectivity": 7.0, "Commute": 5.5, "Business Freedom": 7.0, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 6.5, "Environmental Quality": 7.5, "Economy": 5.5,
     "Taxation": 4.0, "Internet Access": 7.5, "Leisure & Culture": 7.5, "Tolerance": 8.0, "Outdoors": 9.0})

add_city("Seville", "Spain", "Seville, Spain", "Europe",
    37.3891, -5.9845, 684234,
    "Andalusia's passionate capital enchants with flamenco, stunning Moorish architecture, and tapas culture that's practically a religion. Seville's orange tree-lined streets, the Alcázar palace, and fiesta-loving spirit make it Spain's most romantic city.",
    "https://images.unsplash.com/photo-1515443961218-a51367888e4b?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 6.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 6.0, "Business Freedom": 7.0, "Safety": 7.0,
     "Healthcare": 8.5, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 5.0,
     "Taxation": 4.0, "Internet Access": 7.5, "Leisure & Culture": 8.5, "Tolerance": 8.0, "Outdoors": 7.0})

add_city("Valencia", "Spain", "Valencia, Spain", "Europe",
    39.4699, -0.3763, 800215,
    "Spain's third city offers the perfect blend of Mediterranean beach life, futuristic architecture, and the birthplace of paella. Valencia's City of Arts and Sciences, incredible climate, and growing tech scene make it one of Europe's most desirable places to live.",
    "https://images.unsplash.com/photo-1580502304784-8985b7eb7260?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 6.0, "Startups": 5.0, "Venture Capital": 3.0,
     "Travel Connectivity": 7.0, "Commute": 6.5, "Business Freedom": 7.0, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 7.0, "Environmental Quality": 7.5, "Economy": 5.5,
     "Taxation": 4.0, "Internet Access": 8.0, "Leisure & Culture": 8.0, "Tolerance": 8.5, "Outdoors": 8.5})

add_city("Zaragoza", "Spain", "Zaragoza, Spain", "Europe",
    41.6488, -0.8891, 674997,
    "Strategically located between Madrid and Barcelona, Zaragoza offers excellent value with a beautiful baroque cathedral and vibrant tapas scene. This often-overlooked Spanish city provides authentic Spanish living at prices well below the coastal cities.",
    "",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 6.0, "Business Freedom": 7.0, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 5.0,
     "Taxation": 4.0, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 7.5, "Outdoors": 6.0})

# Sweden
add_city("Gothenburg", "Sweden", "Gothenburg, Sweden", "Europe",
    57.7089, 11.9746, 583056,
    "Sweden's friendly second city is a seafood lover's paradise with a world-class archipelago, cozy fika culture, and Volvo heritage. Gothenburg's relaxed vibe, excellent public transit, and thriving music and design scenes make it a more approachable alternative to Stockholm.",
    "https://images.unsplash.com/photo-1563879553592-f3ad2c7fb3b0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.5, "Cost of Living": 3.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 6.5, "Commute": 7.5, "Business Freedom": 8.5, "Safety": 8.0,
     "Healthcare": 9.0, "Education": 8.0, "Environmental Quality": 8.5, "Economy": 7.5,
     "Taxation": 2.5, "Internet Access": 9.0, "Leisure & Culture": 7.0, "Tolerance": 9.0, "Outdoors": 8.0})

add_city("Malmö", "Sweden", "Malmö, Sweden", "Europe",
    55.6050, 13.0038, 347949,
    "Sweden's multicultural gateway to continental Europe sits across the Øresund Bridge from Copenhagen with a youthful, diverse vibe. Malmö's waterfront living, bike-friendly streets, and access to both Swedish and Danish lifestyles make it uniquely positioned.",
    "",
    {"Housing": 4.0, "Cost of Living": 3.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 7.0, "Commute": 7.5, "Business Freedom": 8.5, "Safety": 7.0,
     "Healthcare": 9.0, "Education": 7.5, "Environmental Quality": 8.0, "Economy": 7.0,
     "Taxation": 2.5, "Internet Access": 9.0, "Leisure & Culture": 6.5, "Tolerance": 8.5, "Outdoors": 7.0})

# Ukraine
add_city("Kyiv", "Ukraine", "Kyiv, Ukraine", "Europe",
    50.4501, 30.5234, 2962180,
    "Ukraine's golden-domed capital on the Dnipro River blends Byzantine churches with a vibrant modern art and nightlife scene. Kyiv's resilient spirit, incredibly affordable living, and rich history make it one of Europe's most compelling underdog cities.",
    "https://images.unsplash.com/photo-1561542320-9a18cd340e98?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 8.0, "Startups": 5.5, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 5.5, "Business Freedom": 5.0, "Safety": 4.0,
     "Healthcare": 5.0, "Education": 6.5, "Environmental Quality": 5.5, "Economy": 4.0,
     "Taxation": 6.5, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 5.5, "Outdoors": 5.0})

add_city("Lviv", "Ukraine", "Lviv, Ukraine", "Europe",
    49.8397, 24.0297, 717803,
    "Ukraine's cultural gem in the west features a stunning UNESCO old town with Austro-Hungarian elegance, legendary coffee culture, and chocolate traditions. Lviv's incredibly low costs, thriving IT sector, and European charm make it a hidden gem for remote workers.",
    "https://images.unsplash.com/photo-1561154464-82e9aab32f14?auto=format&fit=crop&w=800&q=80",
    {"Housing": 8.5, "Cost of Living": 9.0, "Startups": 5.0, "Venture Capital": 2.5,
     "Travel Connectivity": 4.5, "Commute": 6.0, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 5.0, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 4.0,
     "Taxation": 6.5, "Internet Access": 7.0, "Leisure & Culture": 7.5, "Tolerance": 5.5, "Outdoors": 5.5})

# UK
add_city("Birmingham", "United Kingdom", "Birmingham, England, United Kingdom", "Europe",
    52.4862, -1.8904, 1144900,
    "Britain's second city has undergone a remarkable renaissance with world-class dining, a thriving arts scene, and excellent transport links. Birmingham's central location, diverse population, and significantly lower costs than London make it the UK's most up-and-coming city.",
    "https://images.unsplash.com/photo-1579083375958-92a36d415d5d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 7.5, "Commute": 6.5, "Business Freedom": 8.0, "Safety": 6.5,
     "Healthcare": 8.0, "Education": 7.0, "Environmental Quality": 6.0, "Economy": 6.5,
     "Taxation": 4.5, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 5.5})

add_city("Glasgow", "United Kingdom", "Glasgow, Scotland, United Kingdom", "Europe",
    55.8642, -4.2518, 635640,
    "Scotland's largest city pulses with creative energy, from its world-class music scene to the Mackintosh architecture and legendary friendly locals. Glasgow's affordability, vibrant nightlife, and proximity to the Highlands make it the UK's most underrated city.",
    "https://images.unsplash.com/photo-1583300837-a8e4e5e4d8d1?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 5.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 6.5, "Commute": 6.5, "Business Freedom": 8.0, "Safety": 6.5,
     "Healthcare": 8.0, "Education": 7.5, "Environmental Quality": 6.5, "Economy": 6.0,
     "Taxation": 4.0, "Internet Access": 8.0, "Leisure & Culture": 8.0, "Tolerance": 8.0, "Outdoors": 7.5})

add_city("Manchester", "United Kingdom", "Manchester, England, United Kingdom", "Europe",
    53.4808, -2.2426, 553230,
    "The birthplace of the Industrial Revolution has reinvented itself as a creative and tech powerhouse with legendary music, football, and nightlife. Manchester's Northern Quarter cool, MediaCityUK innovation, and lower costs than London make it the UK's most dynamic city outside the capital.",
    "https://images.unsplash.com/photo-1515586838455-8f8f940d6853?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 6.5, "Venture Capital": 5.0,
     "Travel Connectivity": 8.0, "Commute": 6.5, "Business Freedom": 8.0, "Safety": 6.5,
     "Healthcare": 8.0, "Education": 7.5, "Environmental Quality": 6.0, "Economy": 7.0,
     "Taxation": 4.5, "Internet Access": 8.5, "Leisure & Culture": 8.5, "Tolerance": 8.5, "Outdoors": 6.5})


# ═══════════════════════════════════════════════════════════════════════════════
# MIDDLE EAST
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Tehran", "Iran", "Tehran, Iran", "Middle East",
    35.6892, 51.3890, 9039000,
    "Iran's sprawling capital sits beneath the snow-capped Alborz Mountains with a rich cultural scene, incredible cuisine, and legendary hospitality. Tehran's bazaars, museums, and mountain access offer a fascinating experience for those willing to navigate its complexities.",
    "https://images.unsplash.com/photo-1573225935840-82ad5a407693?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 7.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.5, "Commute": 3.0, "Business Freedom": 3.0, "Safety": 6.0,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 3.5, "Economy": 4.0,
     "Taxation": 6.5, "Internet Access": 3.5, "Leisure & Culture": 6.5, "Tolerance": 3.0, "Outdoors": 6.0})

add_city("Amman", "Jordan", "Amman, Jordan", "Middle East",
    31.9454, 35.9284, 4007526,
    "Jordan's hilly capital is a modern Arab city built on ancient Roman ruins with a thriving food scene and warm hospitality. Amman's stability, growing tech sector, and proximity to Petra and the Dead Sea make it an accessible Middle Eastern base.",
    "https://images.unsplash.com/photo-1551122089-4e3e72477432?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 6.0, "Commute": 4.0, "Business Freedom": 5.5, "Safety": 7.0,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 5.5, "Economy": 4.5,
     "Taxation": 6.5, "Internet Access": 5.5, "Leisure & Culture": 5.5, "Tolerance": 5.0, "Outdoors": 6.0})

add_city("Beirut", "Lebanon", "Beirut, Lebanon", "Middle East",
    33.8938, 35.5018, 2400000,
    "The 'Paris of the Middle East' is a resilient city of contradictions where Mediterranean glamour meets chaotic charm and world-class nightlife. Beirut's legendary food scene, multilingual culture, and defiant spirit make it one of the world's most fascinating cities.",
    "https://images.unsplash.com/photo-1558378933-b8a182ee0d74?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 3.0, "Business Freedom": 5.0, "Safety": 4.0,
     "Healthcare": 6.0, "Education": 6.5, "Environmental Quality": 4.5, "Economy": 3.5,
     "Taxation": 6.5, "Internet Access": 5.0, "Leisure & Culture": 8.0, "Tolerance": 6.0, "Outdoors": 7.0})

add_city("Muscat", "Oman", "Muscat, Oman", "Middle East",
    23.5880, 58.3829, 1421409,
    "Oman's elegant capital hugs dramatic rocky coastline with traditional souqs, stunning mosques, and a welcoming atmosphere rare in the Gulf. Muscat's blend of old-world Arab charm and modern comfort makes it the Gulf's most livable and authentic city.",
    "https://images.unsplash.com/photo-1557160854-d90b646ed7d3?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 3.0, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 6.0, "Safety": 8.5,
     "Healthcare": 6.5, "Education": 5.5, "Environmental Quality": 6.0, "Economy": 6.0,
     "Taxation": 9.0, "Internet Access": 6.0, "Leisure & Culture": 5.0, "Tolerance": 5.5, "Outdoors": 7.0})

add_city("Doha", "Qatar", "Doha, Qatar", "Middle East",
    25.2854, 51.5310, 2382000,
    "Qatar's ambitious capital has transformed from a pearl-diving village into a futuristic skyline hosting world-class museums and the 2022 FIFA World Cup. Doha's tax-free income, luxury living, and growing cultural scene attract ambitious professionals worldwide.",
    "https://images.unsplash.com/photo-1573164574511-73c773193279?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 3.5, "Startups": 4.5, "Venture Capital": 4.5,
     "Travel Connectivity": 8.5, "Commute": 5.0, "Business Freedom": 6.5, "Safety": 8.5,
     "Healthcare": 7.5, "Education": 6.0, "Environmental Quality": 4.5, "Economy": 8.0,
     "Taxation": 10.0, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 4.0, "Outdoors": 3.5})

add_city("Jeddah", "Saudi Arabia", "Jeddah, Saudi Arabia", "Middle East",
    21.4858, 39.1925, 4697000,
    "Saudi Arabia's most cosmopolitan city is the gateway to Mecca and a Red Sea port with a historic coral-built old town and vibrant arts scene. Jeddah's seafood cuisine, diving opportunities, and more relaxed social atmosphere make it the Kingdom's most livable city.",
    "https://images.unsplash.com/photo-1586724237569-9c5e0b60326b?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 4.0,
     "Travel Connectivity": 7.0, "Commute": 4.0, "Business Freedom": 5.5, "Safety": 7.0,
     "Healthcare": 6.5, "Education": 5.5, "Environmental Quality": 4.5, "Economy": 7.0,
     "Taxation": 9.5, "Internet Access": 6.5, "Leisure & Culture": 5.0, "Tolerance": 3.0, "Outdoors": 5.0})

add_city("Istanbul", "Turkey", "Istanbul, Turkey", "Middle East",
    41.0082, 28.9784, 15840900,
    "The only city spanning two continents straddles Europe and Asia with 2,500 years of imperial history from Byzantine to Ottoman grandeur. Istanbul's Bosphorus views, Grand Bazaar, world-class food scene, and creative energy make it one of Earth's most captivating cities.",
    "https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 6.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 9.0, "Commute": 4.0, "Business Freedom": 5.5, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 6.5, "Leisure & Culture": 9.5, "Tolerance": 5.5, "Outdoors": 6.5})

add_city("Abu Dhabi", "UAE", "Abu Dhabi, UAE", "Middle East",
    24.4539, 54.3773, 1483000,
    "The UAE's oil-rich capital is a gleaming modern city with the Louvre Abu Dhabi, world-class F1 racing, and an increasingly diversified economy. Abu Dhabi's safety, tax-free income, and ambitious cultural investments make it a polished Gulf destination.",
    "https://images.unsplash.com/photo-1512632578888-169bbbc64f33?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 4.0, "Startups": 5.0, "Venture Capital": 5.5,
     "Travel Connectivity": 8.5, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 9.0,
     "Healthcare": 7.5, "Education": 6.5, "Environmental Quality": 5.5, "Economy": 8.0,
     "Taxation": 10.0, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 5.5, "Outdoors": 5.0})

# ═══════════════════════════════════════════════════════════════════════════════
# NORTH AMERICA - Canada
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Calgary", "Canada", "Calgary, Alberta, Canada", "North America",
    51.0447, -114.0719, 1336000,
    "Canada's energy capital sits where the prairies meet the Rocky Mountains with world-class skiing just an hour away. Calgary's entrepreneurial spirit, low taxes, Stampede culture, and stunning mountain backdrop make it an outdoor lover's dream city.",
    "https://images.unsplash.com/photo-1517154421773-0529f29ea451?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 5.5, "Venture Capital": 4.5,
     "Travel Connectivity": 6.5, "Commute": 5.5, "Business Freedom": 8.5, "Safety": 8.0,
     "Healthcare": 8.0, "Education": 7.0, "Environmental Quality": 7.5, "Economy": 6.5,
     "Taxation": 6.5, "Internet Access": 8.0, "Leisure & Culture": 6.0, "Tolerance": 8.0, "Outdoors": 9.5})

add_city("Edmonton", "Canada", "Edmonton, Alberta, Canada", "North America",
    53.5461, -113.4938, 1010899,
    "Alberta's capital is a festival city with North America's largest urban park system and a thriving arts and food scene. Edmonton's affordable housing, no provincial sales tax, and access to the Canadian Rockies make it a practical northern base.",
    "",
    {"Housing": 6.5, "Cost of Living": 5.5, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 5.5, "Commute": 5.0, "Business Freedom": 8.5, "Safety": 7.0,
     "Healthcare": 8.0, "Education": 7.0, "Environmental Quality": 7.0, "Economy": 6.0,
     "Taxation": 7.0, "Internet Access": 8.0, "Leisure & Culture": 5.5, "Tolerance": 8.0, "Outdoors": 7.5})

add_city("Halifax", "Canada", "Halifax, Nova Scotia, Canada", "North America",
    44.6488, -63.5752, 439819,
    "Nova Scotia's historic port city offers maritime charm, world-class seafood, and a tight-knit creative community on the Atlantic coast. Halifax's growing tech scene, affordable waterfront living, and proximity to rugged coastline make it Atlantic Canada's gem.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 5.5, "Business Freedom": 8.0, "Safety": 8.0,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 8.0, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 8.0, "Outdoors": 8.0})

add_city("Ottawa", "Canada", "Ottawa, Ontario, Canada", "North America",
    45.4215, -75.6972, 1017449,
    "Canada's bilingual capital offers a high quality of life with world-class museums, beautiful Rideau Canal skating, and a growing tech sector. Ottawa's stability, green spaces, and cultural institutions make it an ideal city for families and professionals.",
    "https://images.unsplash.com/photo-1557456170-0cf4f4d0d362?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 6.0, "Commute": 6.0, "Business Freedom": 8.5, "Safety": 8.0,
     "Healthcare": 8.0, "Education": 8.0, "Environmental Quality": 8.0, "Economy": 7.0,
     "Taxation": 4.0, "Internet Access": 8.0, "Leisure & Culture": 6.5, "Tolerance": 9.0, "Outdoors": 8.0})

add_city("Quebec City", "Canada", "Quebec City, Quebec, Canada", "North America",
    46.8139, -71.2080, 549459,
    "North America's most European city enchants with its UNESCO-listed old town, French language, and winter carnival magic. Quebec City's cobblestone streets, incredible food scene, and distinctive Francophone culture make it uniquely charming on the continent.",
    "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 5.5, "Business Freedom": 8.0, "Safety": 8.5,
     "Healthcare": 8.0, "Education": 7.5, "Environmental Quality": 8.0, "Economy": 6.0,
     "Taxation": 3.5, "Internet Access": 7.5, "Leisure & Culture": 7.5, "Tolerance": 8.0, "Outdoors": 8.0})

add_city("Victoria", "Canada", "Victoria, British Columbia, Canada", "North America",
    48.4284, -123.3656, 394000,
    "British Columbia's garden capital enjoys Canada's mildest climate on Vancouver Island with English-garden charm and Pacific coastal beauty. Victoria's walkable downtown, whale-watching waters, and relaxed pace make it a dream for those seeking a slower Canadian lifestyle.",
    "https://images.unsplash.com/photo-1559321048-d82d3e99c07c?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.5, "Cost of Living": 4.0, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 4.5, "Commute": 6.0, "Business Freedom": 8.5, "Safety": 8.5,
     "Healthcare": 8.0, "Education": 7.5, "Environmental Quality": 9.0, "Economy": 6.0,
     "Taxation": 4.5, "Internet Access": 8.0, "Leisure & Culture": 6.5, "Tolerance": 9.0, "Outdoors": 9.5})

add_city("Winnipeg", "Canada", "Winnipeg, Manitoba, Canada", "North America",
    49.8951, -97.1384, 749607,
    "Manitoba's capital at the geographic center of North America surprises with a vibrant arts scene, diverse food culture, and genuine prairie warmth. Winnipeg's incredibly affordable housing, cultural festivals, and wide-open spaces make it Canada's best-value major city.",
    "",
    {"Housing": 7.0, "Cost of Living": 6.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 5.5, "Business Freedom": 8.0, "Safety": 6.5,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 7.0, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 8.0, "Outdoors": 6.0})

# Mexico
add_city("Guadalajara", "Mexico", "Guadalajara, Jalisco, Mexico", "North America",
    20.6597, -103.3496, 5268000,
    "Mexico's Silicon Valley and birthplace of mariachi and tequila offers a perfect blend of tradition and tech innovation. Guadalajara's pleasant climate, colonial architecture, and growing expat community make it one of Latin America's most livable cities.",
    "https://images.unsplash.com/photo-1568736333610-eae6e0e8a56c?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 6.5, "Commute": 3.5, "Business Freedom": 5.5, "Safety": 4.5,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 6.0, "Leisure & Culture": 7.5, "Tolerance": 6.0, "Outdoors": 6.0})

add_city("Monterrey", "Mexico", "Monterrey, Nuevo León, Mexico", "North America",
    25.6866, -100.3161, 5341000,
    "Mexico's industrial powerhouse sits dramatically beneath the Sierra Madre with a strong business culture and the country's highest incomes. Monterrey's entrepreneurial spirit, craft beer scene, and outdoor adventures in nearby canyons make it Mexico's most dynamic city.",
    "https://images.unsplash.com/photo-1623942393107-ad3fc2e1dc66?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.0, "Commute": 3.5, "Business Freedom": 5.5, "Safety": 4.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 4.5, "Economy": 6.5,
     "Taxation": 5.5, "Internet Access": 6.5, "Leisure & Culture": 6.0, "Tolerance": 5.5, "Outdoors": 7.0})

add_city("Puebla", "Mexico", "Puebla, Mexico", "North America",
    19.0414, -98.2063, 3199530,
    "Mexico's culinary capital is a stunning colonial city known for mole, Talavera pottery, and churches with volcanic views. Puebla's affordability, UNESCO-listed center, and proximity to Mexico City make it an excellent Mexican base.",
    "",
    {"Housing": 7.5, "Cost of Living": 8.0, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 5.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 7.0, "Tolerance": 5.5, "Outdoors": 6.5})


# ═══════════════════════════════════════════════════════════════════════════════
# NORTH AMERICA - United States
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Houston", "United States", "Houston, Texas, United States", "North America",
    29.7604, -95.3698, 2304580,
    "America's energy capital is a sprawling, diverse metropolis with NASA's Mission Control, world-class museums, and the best international food scene in the South. Houston's no-zoning attitude, low cost of living, and booming job market make it a magnet for opportunity seekers.",
    "https://images.unsplash.com/photo-1548519853-d4923d723be3?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.0, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 8.5, "Commute": 3.0, "Business Freedom": 8.0, "Safety": 5.0,
     "Healthcare": 7.5, "Education": 6.5, "Environmental Quality": 4.0, "Economy": 7.5,
     "Taxation": 8.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 4.0})

add_city("Phoenix", "United States", "Phoenix, Arizona, United States", "North America",
    33.4484, -112.0740, 1608139,
    "America's fifth-largest city basks in 300+ days of sunshine with a booming tech scene and desert mountain scenery. Phoenix's affordable housing, outdoor lifestyle, and explosive growth make it one of the fastest-growing metros in the nation.",
    "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 5.5, "Venture Capital": 4.5,
     "Travel Connectivity": 7.0, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 5.0, "Economy": 7.0,
     "Taxation": 7.0, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 6.5, "Outdoors": 7.5})

add_city("Philadelphia", "United States", "Philadelphia, Pennsylvania, United States", "North America",
    39.9526, -75.1652, 1603797,
    "America's birthplace blends revolutionary history with a gritty arts scene, world-class healthcare, and a food culture that goes far beyond cheesesteaks. Philly's walkable neighborhoods, affordable prices for a major East Coast city, and passionate sports culture make it compelling.",
    "https://images.unsplash.com/photo-1569761316261-9a8696fa2ca3?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 6.0, "Venture Capital": 5.5,
     "Travel Connectivity": 8.0, "Commute": 6.0, "Business Freedom": 7.5, "Safety": 4.5,
     "Healthcare": 8.5, "Education": 8.0, "Environmental Quality": 5.5, "Economy": 6.5,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 8.0, "Tolerance": 7.5, "Outdoors": 5.0})

add_city("San Antonio", "United States", "San Antonio, Texas, United States", "North America",
    29.4241, -98.4936, 1434625,
    "Texas's most historic city wraps around the famous River Walk with a rich Tex-Mex culture, the Alamo, and booming military and healthcare sectors. San Antonio's affordable living, warm hospitality, and family-friendly atmosphere make it one of America's most livable large cities.",
    "https://images.unsplash.com/photo-1531218150217-54595bc2b934?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 6.0, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 6.0, "Environmental Quality": 5.0, "Economy": 6.0,
     "Taxation": 8.0, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 6.5, "Outdoors": 5.0})

add_city("San Diego", "United States", "San Diego, California, United States", "North America",
    32.7157, -117.1611, 1386932,
    "America's Finest City lives up to its name with perfect weather, stunning Pacific beaches, and a booming biotech and defense industry. San Diego's laid-back lifestyle, craft beer scene, and proximity to the Mexican border create a uniquely Californian paradise.",
    "https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.5, "Cost of Living": 3.0, "Startups": 6.5, "Venture Capital": 5.5,
     "Travel Connectivity": 7.0, "Commute": 4.0, "Business Freedom": 7.5, "Safety": 6.5,
     "Healthcare": 7.5, "Education": 7.5, "Environmental Quality": 8.0, "Economy": 7.0,
     "Taxation": 4.0, "Internet Access": 8.0, "Leisure & Culture": 7.5, "Tolerance": 8.0, "Outdoors": 9.5})

add_city("Dallas", "United States", "Dallas, Texas, United States", "North America",
    32.7767, -96.7970, 1304379,
    "Big D is a powerhouse of business, culture, and style with a thriving arts district, legendary BBQ, and corporate headquarters galore. Dallas's pro-business climate, no state income tax, and cosmopolitan dining scene draw ambitious professionals from across the country.",
    "https://images.unsplash.com/photo-1545194445-dddb8f4487c6?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 6.5, "Venture Capital": 5.5,
     "Travel Connectivity": 9.0, "Commute": 3.5, "Business Freedom": 8.5, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 8.0,
     "Taxation": 8.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 6.5, "Outdoors": 4.0})

add_city("San Jose", "United States", "San Jose, California, United States", "North America",
    37.3382, -121.8863, 1013240,
    "The self-proclaimed Capital of Silicon Valley sits at the heart of the world's greatest tech ecosystem with near-perfect weather. San Jose's proximity to Apple, Google, and countless startups makes it the center of innovation, despite sky-high costs.",
    "https://images.unsplash.com/photo-1564869733273-a3f3c8ad6329?auto=format&fit=crop&w=800&q=80",
    {"Housing": 1.5, "Cost of Living": 2.0, "Startups": 9.5, "Venture Capital": 10.0,
     "Travel Connectivity": 8.0, "Commute": 4.0, "Business Freedom": 8.0, "Safety": 6.5,
     "Healthcare": 8.0, "Education": 8.0, "Environmental Quality": 7.0, "Economy": 9.0,
     "Taxation": 3.5, "Internet Access": 9.0, "Leisure & Culture": 6.0, "Tolerance": 8.5, "Outdoors": 7.5})

add_city("Jacksonville", "United States", "Jacksonville, Florida, United States", "North America",
    30.3322, -81.6557, 949611,
    "America's largest city by area offers miles of Atlantic beaches, a growing financial sector, and affordable Florida living without state income tax. Jacksonville's expanding food scene, Navy heritage, and outdoor lifestyle make it an increasingly popular Southern destination.",
    "",
    {"Housing": 6.0, "Cost of Living": 6.0, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 5.0,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 6.0, "Economy": 6.0,
     "Taxation": 8.0, "Internet Access": 7.0, "Leisure & Culture": 5.0, "Tolerance": 6.0, "Outdoors": 7.0})

add_city("Fort Worth", "United States", "Fort Worth, Texas, United States", "North America",
    32.7555, -97.3308, 918915,
    "Dallas's western neighbor embraces its cowtown heritage with the famous Stockyards, world-class museums, and a growing craft brewery scene. Fort Worth's genuine Texan charm, lower costs than Dallas, and booming population make it one of America's fastest-growing cities.",
    "",
    {"Housing": 6.0, "Cost of Living": 6.0, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 7.5, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 5.0, "Economy": 7.0,
     "Taxation": 8.0, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 4.5})

add_city("Columbus", "United States", "Columbus, Ohio, United States", "North America",
    39.9612, -82.9988, 905748,
    "Ohio's capital is a surprisingly hip college town grown into a diverse metro with a thriving food scene and strong tech sector. Columbus's affordability, Ohio State University energy, and progressive urban core make it the Midwest's most underrated city.",
    "",
    {"Housing": 6.5, "Cost of Living": 6.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 5.5,
     "Healthcare": 7.5, "Education": 7.5, "Environmental Quality": 5.5, "Economy": 6.5,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 7.0, "Outdoors": 5.0})

add_city("Charlotte", "United States", "Charlotte, North Carolina, United States", "North America",
    35.2271, -80.8431, 874579,
    "America's second-largest banking center has evolved into a dynamic Southern city with a booming food scene and strong job growth. Charlotte's tree-lined neighborhoods, proximity to both mountains and beaches, and affordable living attract young professionals.",
    "https://images.unsplash.com/photo-1577086782213-d36fb2e5eea5?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 5.5, "Venture Capital": 5.0,
     "Travel Connectivity": 7.5, "Commute": 4.0, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 6.0, "Economy": 7.5,
     "Taxation": 6.0, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 6.5, "Outdoors": 6.5})

add_city("Indianapolis", "United States", "Indianapolis, Indiana, United States", "North America",
    39.7684, -86.1581, 887642,
    "The Crossroads of America is famous for the Indy 500 but offers much more with affordable living, a revitalized downtown, and thriving sports culture. Indianapolis's central location, growing food scene, and cultural amenities punch above its weight class.",
    "",
    {"Housing": 7.0, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 5.0,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 6.0, "Outdoors": 4.5})

add_city("Washington", "United States", "Washington, District of Columbia, United States", "North America",
    38.9072, -77.0369, 689545,
    "The nation's capital is a global power center with free world-class Smithsonian museums, cherry blossom springs, and a diverse dining scene rivaling any US city. DC's educated population, strong job market, and historic neighborhoods make it one of America's most cosmopolitan cities.",
    "https://images.unsplash.com/photo-1617581629397-a72507c3de9e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.5, "Cost of Living": 3.0, "Startups": 7.0, "Venture Capital": 6.5,
     "Travel Connectivity": 8.5, "Commute": 6.5, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 8.0, "Education": 9.0, "Environmental Quality": 6.5, "Economy": 8.0,
     "Taxation": 4.5, "Internet Access": 8.5, "Leisure & Culture": 9.0, "Tolerance": 9.0, "Outdoors": 6.0})

add_city("Oklahoma City", "United States", "Oklahoma City, Oklahoma, United States", "North America",
    35.4676, -97.5164, 681054,
    "OKC has transformed from cowtown to cool with a revitalized Bricktown district, Thunder basketball, and genuine Western hospitality. The city's incredibly affordable housing, growing food scene, and friendly culture make it one of America's best-value cities.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.0, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 4.0, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 6.0, "Education": 5.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 6.5, "Internet Access": 7.0, "Leisure & Culture": 5.0, "Tolerance": 5.5, "Outdoors": 5.0})

add_city("El Paso", "United States", "El Paso, Texas, United States", "North America",
    31.7619, -106.4850, 678815,
    "This sun-drenched border city blends Mexican and American cultures with stunning desert landscapes and one of America's lowest crime rates for its size. El Paso's extreme affordability, year-round sunshine, and genuine bicultural identity make it uniquely appealing.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.5, "Commute": 4.0, "Business Freedom": 7.5, "Safety": 7.0,
     "Healthcare": 5.5, "Education": 5.0, "Environmental Quality": 6.0, "Economy": 5.0,
     "Taxation": 8.0, "Internet Access": 6.5, "Leisure & Culture": 5.0, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Las Vegas", "United States", "Las Vegas, Nevada, United States", "North America",
    36.1699, -115.1398, 641903,
    "Beyond the famous Strip, Las Vegas offers affordable desert living, no state income tax, and world-class entertainment at your doorstep. The city's explosive growth, diverse food scene, and proximity to Red Rock Canyon and national parks make it more than just a party town.",
    "https://images.unsplash.com/photo-1605833556294-ea5c7a74f57d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 8.0, "Commute": 4.0, "Business Freedom": 8.0, "Safety": 5.0,
     "Healthcare": 6.0, "Education": 5.0, "Environmental Quality": 5.5, "Economy": 6.5,
     "Taxation": 8.5, "Internet Access": 7.5, "Leisure & Culture": 8.5, "Tolerance": 7.0, "Outdoors": 7.5})


add_city("Detroit", "United States", "Detroit, Michigan, United States", "North America",
    42.3314, -83.0458, 639111,
    "America's comeback city is experiencing a remarkable renaissance with a revitalized downtown, thriving arts scene, and automotive innovation hub. Detroit's incredibly affordable housing, creative energy, and resilient spirit make it one of the most exciting turnaround stories in America.",
    "https://images.unsplash.com/photo-1577738694892-b22d49ec7e2e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 8.5, "Cost of Living": 7.0, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.5, "Commute": 4.0, "Business Freedom": 7.0, "Safety": 4.0,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 5.0, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 5.0})

add_city("Memphis", "United States", "Memphis, Tennessee, United States", "North America",
    35.1495, -90.0490, 633104,
    "The birthplace of rock 'n' roll, blues, and soul music pulses with musical heritage from Beale Street to Sun Studio and Graceland. Memphis's legendary BBQ, civil rights history, and incredibly affordable living make it a culturally rich Southern city.",
    "https://images.unsplash.com/photo-1558522195-e1201b090344?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.5, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 4.0, "Business Freedom": 7.5, "Safety": 4.0,
     "Healthcare": 6.5, "Education": 5.5, "Environmental Quality": 5.0, "Economy": 5.0,
     "Taxation": 7.5, "Internet Access": 7.0, "Leisure & Culture": 7.5, "Tolerance": 6.0, "Outdoors": 5.0})

add_city("Louisville", "United States", "Louisville, Kentucky, United States", "North America",
    38.2527, -85.7585, 633045,
    "Home of the Kentucky Derby and bourbon country, Louisville charms with a thriving food scene and the world's most famous horse race. The city's affordable living, growing Highland neighborhood hipness, and river city charm make it an appealing Midwest-South hybrid.",
    "",
    {"Housing": 7.0, "Cost of Living": 6.5, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 5.0,
     "Healthcare": 7.0, "Education": 6.0, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 5.5})

add_city("Baltimore", "United States", "Baltimore, Maryland, United States", "North America",
    39.2904, -76.6122, 585708,
    "Charm City earns its nickname with charming row houses, a revitalized Inner Harbor, and world-class institutions like Johns Hopkins. Baltimore's arts scene, seafood traditions, and proximity to DC offer an affordable alternative to the nation's capital.",
    "https://images.unsplash.com/photo-1575897927280-3e5f2febc256?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 5.5, "Venture Capital": 5.0,
     "Travel Connectivity": 7.5, "Commute": 5.5, "Business Freedom": 7.5, "Safety": 3.5,
     "Healthcare": 9.0, "Education": 8.0, "Environmental Quality": 5.0, "Economy": 6.0,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 5.5})

add_city("Milwaukee", "United States", "Milwaukee, Wisconsin, United States", "North America",
    43.0389, -87.9065, 577222,
    "Brew City on Lake Michigan offers a genuine Midwestern warmth with world-class brewing traditions, festivals, and lakefront living. Milwaukee's affordable housing, vibrant Third Ward neighborhood, and cultural institutions make it a livable Great Lakes gem.",
    "",
    {"Housing": 6.5, "Cost of Living": 6.0, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 4.5,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 6.0, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 6.5, "Outdoors": 6.5})

add_city("Albuquerque", "United States", "Albuquerque, New Mexico, United States", "North America",
    35.0844, -106.6504, 564559,
    "Set against the dramatic Sandia Mountains, Albuquerque offers stunning desert beauty, rich Native American and Hispanic heritage, and legendary chile cuisine. The city's affordable living, 310 days of sunshine, and unique cultural blend make it a distinctive American destination.",
    "https://images.unsplash.com/photo-1569025591785-6f60dc6e7d26?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 4.5,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 7.0, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 7.5, "Outdoors": 8.5})

add_city("Tucson", "United States", "Tucson, Arizona, United States", "North America",
    32.2226, -110.9747, 542629,
    "Arizona's second city is a UNESCO City of Gastronomy surrounded by saguaro-studded desert mountains with a vibrant university culture. Tucson's affordability, 350 days of sunshine, and authentic Southwestern character make it a laid-back desert gem.",
    "",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 3.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 4.0, "Business Freedom": 7.5, "Safety": 5.0,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 7.0, "Economy": 5.0,
     "Taxation": 7.0, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 7.0, "Outdoors": 8.5})

add_city("Fresno", "United States", "Fresno, California, United States", "North America",
    36.7378, -119.7871, 542107,
    "California's agricultural heartland capital sits in the fertile San Joaquin Valley with access to Yosemite, Kings Canyon, and Sequoia national parks. Fresno offers California living at a fraction of coastal prices with incredible proximity to the Sierra Nevada.",
    "",
    {"Housing": 6.0, "Cost of Living": 6.0, "Startups": 3.0, "Venture Capital": 2.0,
     "Travel Connectivity": 4.5, "Commute": 4.0, "Business Freedom": 7.0, "Safety": 5.0,
     "Healthcare": 6.0, "Education": 5.5, "Environmental Quality": 4.0, "Economy": 5.0,
     "Taxation": 4.0, "Internet Access": 7.0, "Leisure & Culture": 4.5, "Tolerance": 6.5, "Outdoors": 8.0})

add_city("Sacramento", "United States", "Sacramento, California, United States", "North America",
    38.5816, -121.4944, 524943,
    "California's capital has emerged from the shadow of San Francisco with a thriving farm-to-fork food scene, craft breweries, and affordable living. Sacramento's tree-lined streets, river culture, and proximity to both wine country and Tahoe make it increasingly popular.",
    "",
    {"Housing": 4.5, "Cost of Living": 4.5, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 5.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 4.0, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 7.5, "Outdoors": 7.5})

add_city("Kansas City", "United States", "Kansas City, Missouri, United States", "North America",
    39.0997, -94.5786, 508090,
    "KC is a barbecue and jazz mecca with a thriving arts district, passionate sports fans, and Midwestern friendliness that's impossible to resist. Kansas City's incredibly affordable living, growing tech scene, and world-class BBQ make it one of America's most underrated cities.",
    "https://images.unsplash.com/photo-1554435493-93422e8220c8?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.0, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 5.0,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 6.5, "Outdoors": 5.0})

add_city("Mesa", "United States", "Mesa, Arizona, United States", "North America",
    33.4152, -111.8315, 504258,
    "Phoenix's eastern neighbor offers desert mountain scenery, spring training baseball, and a growing downtown arts district at affordable prices. Mesa's proximity to outdoor adventures, year-round sunshine, and lower costs than Scottsdale make it an attractive Arizona option.",
    "",
    {"Housing": 5.5, "Cost of Living": 6.0, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 6.0, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 6.0,
     "Healthcare": 6.5, "Education": 5.5, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 7.0, "Internet Access": 7.5, "Leisure & Culture": 5.0, "Tolerance": 6.0, "Outdoors": 8.0})

add_city("Atlanta", "United States", "Atlanta, Georgia, United States", "North America",
    33.7490, -84.3880, 498715,
    "The capital of the New South is a diverse, culturally rich metropolis that's home to CNN, Coca-Cola, and America's busiest airport. Atlanta's thriving music scene, world-class food, and role as a civil rights landmark make it the Southeast's most dynamic city.",
    "https://images.unsplash.com/photo-1555695233-a706ff1d2678?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 7.0, "Venture Capital": 6.0,
     "Travel Connectivity": 9.5, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 4.5,
     "Healthcare": 7.5, "Education": 7.5, "Environmental Quality": 5.5, "Economy": 7.5,
     "Taxation": 6.0, "Internet Access": 8.0, "Leisure & Culture": 7.5, "Tolerance": 7.5, "Outdoors": 6.0})

add_city("Omaha", "United States", "Omaha, Nebraska, United States", "North America",
    41.2565, -95.9345, 486051,
    "Warren Buffett's hometown is a surprisingly sophisticated city with excellent steakhouses, a revitalized Old Market district, and strong economy. Omaha's affordable living, friendly community, and growing food scene make it one of the Midwest's best-kept secrets.",
    "",
    {"Housing": 7.0, "Cost of Living": 6.5, "Startups": 4.5, "Venture Capital": 4.0,
     "Travel Connectivity": 5.0, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 6.0,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 6.0, "Economy": 6.5,
     "Taxation": 5.0, "Internet Access": 7.5, "Leisure & Culture": 5.5, "Tolerance": 6.5, "Outdoors": 5.0})

add_city("Colorado Springs", "United States", "Colorado Springs, Colorado, United States", "North America",
    38.8339, -104.8214, 478961,
    "Nestled at the base of Pikes Peak, Colorado Springs offers an outdoor paradise with 300 days of sunshine and the Garden of the Gods. The city's military presence, growing tech sector, and stunning mountain setting make it Colorado's rising star.",
    "https://images.unsplash.com/photo-1530154182551-084828d29eed?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 5.5, "Commute": 4.5, "Business Freedom": 8.0, "Safety": 6.5,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 8.0, "Economy": 6.5,
     "Taxation": 6.0, "Internet Access": 7.5, "Leisure & Culture": 5.5, "Tolerance": 6.0, "Outdoors": 9.5})

add_city("Raleigh", "United States", "Raleigh, North Carolina, United States", "North America",
    35.7796, -78.6382, 467665,
    "The anchor of Research Triangle Park is a booming tech and biotech hub with excellent universities and Southern charm. Raleigh's highly educated population, affordable living, and access to both mountains and beaches make it one of America's most desirable metros.",
    "",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 6.5, "Venture Capital": 5.5,
     "Travel Connectivity": 6.5, "Commute": 4.5, "Business Freedom": 8.0, "Safety": 6.0,
     "Healthcare": 7.5, "Education": 8.5, "Environmental Quality": 6.5, "Economy": 7.5,
     "Taxation": 6.0, "Internet Access": 8.0, "Leisure & Culture": 6.0, "Tolerance": 7.0, "Outdoors": 6.5})


add_city("Long Beach", "United States", "Long Beach, California, United States", "North America",
    33.7701, -118.1937, 466742,
    "LA's coastal neighbor offers a distinct beach-city identity with a vibrant waterfront, diverse neighborhoods, and a thriving arts scene. Long Beach's port city energy, craft beer culture, and more affordable prices than nearby LA make it a compelling SoCal choice.",
    "",
    {"Housing": 3.5, "Cost of Living": 3.5, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 7.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 5.0,
     "Healthcare": 7.0, "Education": 6.0, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 4.0, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 8.0, "Outdoors": 7.5})

add_city("Virginia Beach", "United States", "Virginia Beach, Virginia, United States", "North America",
    36.8529, -75.9780, 459470,
    "America's largest resort city offers miles of Atlantic beaches, a strong military economy, and family-friendly coastal living. Virginia Beach's outdoor recreation, relatively affordable waterfront lifestyle, and proximity to Norfolk's urban amenities make it appealing.",
    "",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 7.0,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 7.0, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 5.5, "Tolerance": 6.0, "Outdoors": 8.5})

add_city("Oakland", "United States", "Oakland, California, United States", "North America",
    37.8044, -122.2712, 433031,
    "San Francisco's grittier, more diverse East Bay neighbor has become a creative and culinary powerhouse in its own right. Oakland's food scene, arts community, and slightly more affordable rents draw those priced out of SF to a city with its own fierce identity.",
    "https://images.unsplash.com/photo-1558975388-f5e4e8e1e5dd?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.5, "Cost of Living": 3.0, "Startups": 7.0, "Venture Capital": 7.0,
     "Travel Connectivity": 8.0, "Commute": 5.5, "Business Freedom": 7.5, "Safety": 4.0,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 6.5, "Economy": 7.0,
     "Taxation": 3.5, "Internet Access": 8.0, "Leisure & Culture": 7.5, "Tolerance": 9.0, "Outdoors": 7.5})

add_city("Minneapolis", "United States", "Minneapolis, Minnesota, United States", "North America",
    44.9778, -93.2650, 429954,
    "The City of Lakes blends Scandinavian heritage with a progressive urban culture, thriving theater scene, and outstanding parks system. Minneapolis's high quality of life, strong job market, and vibrant arts community make it one of America's most livable cities despite harsh winters.",
    "https://images.unsplash.com/photo-1558618666-fcd25c85f82e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 6.0, "Venture Capital": 5.0,
     "Travel Connectivity": 7.0, "Commute": 6.0, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 8.0, "Education": 8.0, "Environmental Quality": 7.0, "Economy": 7.5,
     "Taxation": 4.0, "Internet Access": 8.0, "Leisure & Culture": 8.0, "Tolerance": 8.5, "Outdoors": 7.0})

add_city("Tulsa", "United States", "Tulsa, Oklahoma, United States", "North America",
    36.1540, -95.9928, 413066,
    "Oklahoma's Art Deco gem along the Arkansas River offers a growing remote-worker incentive program and thriving arts district. Tulsa's incredibly affordable living, revitalized Gathering Place park, and genuine Oklahoma friendliness make it a surprising contender.",
    "",
    {"Housing": 8.0, "Cost of Living": 7.5, "Startups": 4.0, "Venture Capital": 3.0,
     "Travel Connectivity": 5.0, "Commute": 4.5, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 6.0, "Education": 5.5, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 6.5, "Internet Access": 7.0, "Leisure & Culture": 5.5, "Tolerance": 5.5, "Outdoors": 5.5})

add_city("New Orleans", "United States", "New Orleans, Louisiana, United States", "North America",
    29.9511, -90.0715, 383997,
    "The Big Easy is America's most culturally unique city, where jazz spills from every corner, Creole cuisine tantalizes, and celebrations are a way of life. New Orleans' architectural beauty, musical heritage, and joie de vivre make it utterly unlike anywhere else in America.",
    "https://images.unsplash.com/photo-1568402102990-bc541580b59f?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.5, "Commute": 4.5, "Business Freedom": 7.0, "Safety": 4.0,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 4.5, "Economy": 5.0,
     "Taxation": 6.0, "Internet Access": 7.0, "Leisure & Culture": 9.5, "Tolerance": 7.5, "Outdoors": 5.5})

add_city("Cleveland", "United States", "Cleveland, Ohio, United States", "North America",
    41.4993, -81.6944, 372624,
    "The Rock and Roll Capital on Lake Erie has reinvented itself with a world-class medical center, revitalized downtown, and passionate sports culture. Cleveland's remarkable affordability, excellent healthcare, and improving food scene make it the Rust Belt's comeback story.",
    "",
    {"Housing": 8.0, "Cost of Living": 7.0, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 4.5,
     "Healthcare": 8.5, "Education": 7.0, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 6.5, "Outdoors": 6.0})

add_city("Honolulu", "United States", "Honolulu, Hawaii, United States", "North America",
    21.3069, -157.8583, 350964,
    "America's tropical paradise capital offers year-round perfect weather, world-famous beaches, and a unique Polynesian-Asian-American cultural blend. Honolulu's stunning natural beauty, outdoor lifestyle, and aloha spirit make it unlike any other American city.",
    "https://images.unsplash.com/photo-1507876466758-bc54f384809c?auto=format&fit=crop&w=800&q=80",
    {"Housing": 1.5, "Cost of Living": 2.0, "Startups": 3.5, "Venture Capital": 2.5,
     "Travel Connectivity": 7.0, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 7.0,
     "Healthcare": 7.5, "Education": 6.5, "Environmental Quality": 9.0, "Economy": 5.5,
     "Taxation": 3.5, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 8.5, "Outdoors": 10.0})

add_city("Anaheim", "United States", "Anaheim, California, United States", "North America",
    33.8366, -117.9143, 350365,
    "Home to Disneyland and the Angels, Anaheim has evolved beyond its theme park identity with a vibrant food scene and growing downtown. The city's year-round sunshine, Orange County beaches nearby, and family-friendly atmosphere keep it popular.",
    "",
    {"Housing": 3.0, "Cost of Living": 3.0, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 7.5, "Commute": 3.5, "Business Freedom": 7.5, "Safety": 6.0,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 6.0, "Economy": 6.5,
     "Taxation": 4.0, "Internet Access": 7.5, "Leisure & Culture": 7.5, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Pittsburgh", "United States", "Pittsburgh, Pennsylvania, United States", "North America",
    40.4406, -79.9959, 302971,
    "The Steel City has transformed into a tech and healthcare hub where three rivers meet beneath dramatic bridges and stunning hillside neighborhoods. Pittsburgh's world-class universities, affordable living, and booming robotics and AI sectors make it a renaissance city.",
    "https://images.unsplash.com/photo-1544767833-cbb63942020e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.0, "Startups": 6.5, "Venture Capital": 5.0,
     "Travel Connectivity": 6.0, "Commute": 5.5, "Business Freedom": 7.5, "Safety": 6.0,
     "Healthcare": 8.5, "Education": 8.0, "Environmental Quality": 5.5, "Economy": 6.5,
     "Taxation": 5.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 6.5})

add_city("Cincinnati", "United States", "Cincinnati, Ohio, United States", "North America",
    39.1031, -84.5120, 309317,
    "Queen City straddles the Ohio River with stunning hillside neighborhoods, a revitalized Over-the-Rhine district, and America's best chili debate. Cincinnati's affordable elegance, excellent food scene, and strong cultural institutions make it the Midwest's most underrated city.",
    "",
    {"Housing": 7.0, "Cost of Living": 6.5, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 5.5,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 5.5, "Economy": 6.0,
     "Taxation": 5.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 6.5, "Outdoors": 6.0})

add_city("Orlando", "United States", "Orlando, Florida, United States", "North America",
    28.5383, -81.3792, 307573,
    "Beyond the theme parks, Orlando is a booming tech and simulation hub with a diverse population and year-round tropical warmth. The city's no state income tax, growing food scene, and outdoor recreation across countless lakes make it more than just Disney.",
    "https://images.unsplash.com/photo-1575089976121-8ed7b2a54265?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 7.5, "Commute": 3.5, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 6.0, "Economy": 6.5,
     "Taxation": 8.0, "Internet Access": 7.5, "Leisure & Culture": 8.0, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Tampa", "United States", "Tampa, Florida, United States", "North America",
    27.9506, -82.4572, 384959,
    "Florida's Gulf Coast gem offers waterfront living, a revitalized downtown, and a booming food scene anchored by the historic Cuban community of Ybor City. Tampa's no state income tax, year-round warmth, and growing tech sector make it one of Florida's most attractive cities.",
    "https://images.unsplash.com/photo-1605649487212-47bdab064df7?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 7.0, "Commute": 4.0, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 7.0,
     "Taxation": 8.0, "Internet Access": 7.5, "Leisure & Culture": 6.5, "Tolerance": 7.0, "Outdoors": 7.5})

add_city("St. Louis", "United States", "St. Louis, Missouri, United States", "North America",
    38.6270, -90.1994, 301578,
    "The Gateway to the West is a proudly blue-collar city with world-class free attractions like the zoo, art museum, and iconic Arch. St. Louis's incredibly low cost of living, thriving craft beer scene, and strong cultural institutions make it a remarkable value.",
    "https://images.unsplash.com/photo-1569012871812-f38ee64cd54c?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.5, "Cost of Living": 7.0, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 6.5, "Commute": 4.5, "Business Freedom": 7.5, "Safety": 4.0,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 6.5, "Outdoors": 5.5})

add_city("St. Petersburg", "United States", "St. Petersburg, Florida, United States", "North America",
    27.7676, -82.6403, 258308,
    "Tampa Bay's artsy waterfront city has transformed into a cultural hotspot with the Dalí Museum, vibrant murals, and a thriving craft beer scene. St. Pete's stunning beaches, walkable downtown, and creative energy make it Florida's coolest small city.",
    "",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 4.5, "Venture Capital": 3.5,
     "Travel Connectivity": 6.5, "Commute": 4.0, "Business Freedom": 8.0, "Safety": 6.0,
     "Healthcare": 7.0, "Education": 6.0, "Environmental Quality": 7.0, "Economy": 6.0,
     "Taxation": 8.0, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 8.5})

add_city("Boise", "United States", "Boise, Idaho, United States", "North America",
    43.6150, -116.2023, 235684,
    "Idaho's capital has become one of America's hottest destinations with mountain biking, skiing, and a booming tech scene against a stunning mountain backdrop. Boise's outdoor lifestyle, growing food culture, and quality of life draw transplants from pricier West Coast cities.",
    "https://images.unsplash.com/photo-1539622230297-a79f43a815b0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 4.5, "Commute": 5.0, "Business Freedom": 8.0, "Safety": 7.5,
     "Healthcare": 6.5, "Education": 6.0, "Environmental Quality": 8.0, "Economy": 6.5,
     "Taxation": 6.5, "Internet Access": 7.5, "Leisure & Culture": 5.5, "Tolerance": 6.0, "Outdoors": 9.5})

add_city("Richmond", "United States", "Richmond, Virginia, United States", "North America",
    37.5407, -77.4360, 226610,
    "Virginia's capital blends Civil War history with a thriving arts scene, craft brewery culture, and James River outdoor recreation. Richmond's walkable neighborhoods, affordable living, and growing food scene make it one of the East Coast's most appealing mid-size cities.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 5.0, "Venture Capital": 4.0,
     "Travel Connectivity": 5.5, "Commute": 5.0, "Business Freedom": 7.5, "Safety": 5.5,
     "Healthcare": 7.0, "Education": 7.0, "Environmental Quality": 6.5, "Economy": 6.0,
     "Taxation": 5.5, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Madison", "United States", "Madison, Wisconsin, United States", "North America",
    43.0731, -89.4012, 269840,
    "Wisconsin's capital sits on a stunning isthmus between two lakes with a world-class university, thriving food scene, and progressive culture. Madison consistently ranks among America's most livable cities for its education, outdoor access, and community spirit.",
    "",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 5.5, "Venture Capital": 4.0,
     "Travel Connectivity": 5.0, "Commute": 6.0, "Business Freedom": 7.5, "Safety": 7.0,
     "Healthcare": 8.0, "Education": 9.0, "Environmental Quality": 7.5, "Economy": 7.0,
     "Taxation": 4.5, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 8.5, "Outdoors": 7.5})

add_city("Reno", "United States", "Reno, Nevada, United States", "North America",
    39.5296, -119.8138, 264165,
    "The Biggest Little City in the World has reinvented itself as an outdoor recreation mecca and growing tech hub near Lake Tahoe. Reno's no state income tax, world-class skiing, desert beauty, and Tesla Gigafactory have transformed it from casino town to boomtown.",
    "",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 5.0, "Commute": 5.0, "Business Freedom": 8.0, "Safety": 6.0,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 7.5, "Economy": 6.5,
     "Taxation": 8.5, "Internet Access": 7.5, "Leisure & Culture": 5.5, "Tolerance": 7.0, "Outdoors": 9.5})

add_city("Durham", "United States", "Durham, North Carolina, United States", "North America",
    35.9940, -78.8986, 283506,
    "Duke University's hometown has transformed from tobacco town to tech and biotech powerhouse with an incredible food and arts scene. Durham's Research Triangle location, diverse community, and progressive Southern culture make it one of America's most exciting small cities.",
    "",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 7.0, "Venture Capital": 5.5,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 8.0, "Safety": 5.5,
     "Healthcare": 8.0, "Education": 9.0, "Environmental Quality": 6.5, "Economy": 7.5,
     "Taxation": 6.0, "Internet Access": 8.0, "Leisure & Culture": 7.0, "Tolerance": 7.5, "Outdoors": 6.5})


# ═══════════════════════════════════════════════════════════════════════════════
# OCEANIA (Australia)
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Melbourne", "Australia", "Melbourne, Victoria, Australia", "Oceania",
    -37.8136, 144.9631, 5078193,
    "Australia's cultural capital is a coffee-obsessed, street art-covered city with the country's best food, live music, and sporting events. Melbourne's laneways, world-class universities, and multicultural neighborhoods make it perennially one of the world's most livable cities.",
    "https://images.unsplash.com/photo-1514395462725-fb4566210144?auto=format&fit=crop&w=800&q=80",
    {"Housing": 3.5, "Cost of Living": 4.0, "Startups": 6.5, "Venture Capital": 5.0,
     "Travel Connectivity": 8.0, "Commute": 6.5, "Business Freedom": 8.5, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 8.5, "Environmental Quality": 7.5, "Economy": 7.5,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 9.0, "Tolerance": 9.0, "Outdoors": 7.5})

add_city("Sydney", "Australia", "Sydney, New South Wales, Australia", "Oceania",
    -33.8688, 151.2093, 5312163,
    "Australia's harbor city is an iconic global destination where the Opera House and Harbour Bridge frame one of the world's most stunning waterfronts. Sydney's beaches, dining scene, and cosmopolitan energy make it the country's gateway to the world.",
    "https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=800&q=80",
    {"Housing": 2.0, "Cost of Living": 3.0, "Startups": 7.0, "Venture Capital": 6.0,
     "Travel Connectivity": 9.0, "Commute": 5.5, "Business Freedom": 8.5, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 8.5, "Environmental Quality": 8.0, "Economy": 8.0,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 9.0, "Tolerance": 8.5, "Outdoors": 9.5})

add_city("Brisbane", "Australia", "Brisbane, Queensland, Australia", "Oceania",
    -27.4698, 153.0251, 2560720,
    "Queensland's subtropical capital is a laid-back river city with year-round sunshine, an emerging cultural scene, and the 2032 Olympics on the horizon. Brisbane's outdoor lifestyle, relative affordability, and proximity to Gold Coast beaches make it Australia's fastest-growing city.",
    "https://images.unsplash.com/photo-1524586420096-b1dacccc6f6f?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.0, "Cost of Living": 4.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 7.0, "Commute": 5.5, "Business Freedom": 8.5, "Safety": 7.5,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 7.5, "Economy": 7.0,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 7.0, "Tolerance": 8.5, "Outdoors": 9.0})

add_city("Perth", "Australia", "Perth, Western Australia, Australia", "Oceania",
    -31.9505, 115.8605, 2085973,
    "Australia's most isolated major city rewards with pristine Indian Ocean beaches, constant sunshine, and a booming mining-fueled economy. Perth's outdoor lifestyle, relaxed pace, and stunning natural beauty make it a paradise for those who don't mind being far from everything.",
    "https://images.unsplash.com/photo-1586085735920-3fbb0ff9d42d?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 4.5, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 6.0, "Commute": 5.0, "Business Freedom": 8.5, "Safety": 8.0,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 8.5, "Economy": 7.0,
     "Taxation": 4.5, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 8.0, "Outdoors": 9.5})

add_city("Adelaide", "Australia", "Adelaide, South Australia, Australia", "Oceania",
    -34.9285, 138.6007, 1376601,
    "South Australia's elegant capital is Australia's food and wine capital with the Barossa Valley on its doorstep and a renowned festival scene. Adelaide's affordability, Mediterranean climate, and compact livability make it Australia's best-kept secret.",
    "https://images.unsplash.com/photo-1585406901851-5e07a3290c7f?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 5.5, "Business Freedom": 8.5, "Safety": 8.0,
     "Healthcare": 8.5, "Education": 7.5, "Environmental Quality": 8.0, "Economy": 6.0,
     "Taxation": 4.5, "Internet Access": 7.0, "Leisure & Culture": 7.0, "Tolerance": 8.0, "Outdoors": 8.0})

add_city("Gold Coast", "Australia", "Gold Coast, Queensland, Australia", "Oceania",
    -28.0167, 153.4000, 679127,
    "Australia's playground offers 57 kilometers of golden beaches, world-class surf breaks, and a subtropical lifestyle that defines the Australian dream. The Gold Coast's theme parks, hinterland rainforests, and booming population make it Australia's premier resort city.",
    "https://images.unsplash.com/photo-1578497236217-58f8a6f4e95f?auto=format&fit=crop&w=800&q=80",
    {"Housing": 4.5, "Cost of Living": 5.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 6.0, "Commute": 4.5, "Business Freedom": 8.5, "Safety": 7.5,
     "Healthcare": 8.0, "Education": 6.5, "Environmental Quality": 8.5, "Economy": 6.0,
     "Taxation": 4.5, "Internet Access": 7.0, "Leisure & Culture": 6.0, "Tolerance": 7.5, "Outdoors": 10.0})

add_city("Canberra", "Australia", "Canberra, ACT, Australia", "Oceania",
    -35.2809, 149.1300, 462213,
    "Australia's purpose-built capital is a city of parklands, institutions, and the country's highest average income amid bush-covered hills. Canberra's excellent schools, safe neighborhoods, and proximity to ski fields and coast make it a family-friendly government hub.",
    "",
    {"Housing": 4.0, "Cost of Living": 4.0, "Startups": 4.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.0, "Commute": 6.0, "Business Freedom": 8.5, "Safety": 8.5,
     "Healthcare": 8.5, "Education": 8.5, "Environmental Quality": 8.5, "Economy": 7.0,
     "Taxation": 4.5, "Internet Access": 7.5, "Leisure & Culture": 6.0, "Tolerance": 8.5, "Outdoors": 8.0})

add_city("Newcastle", "Australia", "Newcastle, New South Wales, Australia", "Oceania",
    -32.9283, 151.7817, 322278,
    "This former steel city has reinvented itself as a surfing and creative hub with revitalized heritage buildings and world-class beaches. Newcastle's affordability compared to Sydney, coastal lifestyle, and proximity to the Hunter Valley wine region make it increasingly popular.",
    "",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 4.5, "Commute": 5.0, "Business Freedom": 8.5, "Safety": 8.0,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 8.0, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 7.0, "Leisure & Culture": 5.5, "Tolerance": 7.5, "Outdoors": 9.0})

add_city("Hobart", "Australia", "Hobart, Tasmania, Australia", "Oceania",
    -42.8821, 147.3272, 247461,
    "Tasmania's charming capital sits between mountain and harbor with the world-famous MONA museum and a thriving food and whisky scene. Hobart's natural beauty, creative community, and Australia's most affordable capital city living make it a hidden gem.",
    "https://images.unsplash.com/photo-1588000049095-6bfba5a3a748?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.0, "Commute": 5.5, "Business Freedom": 8.5, "Safety": 8.5,
     "Healthcare": 7.5, "Education": 7.0, "Environmental Quality": 9.0, "Economy": 5.0,
     "Taxation": 4.5, "Internet Access": 6.5, "Leisure & Culture": 6.5, "Tolerance": 7.5, "Outdoors": 9.5})

# ═══════════════════════════════════════════════════════════════════════════════
# SOUTH AMERICA
# ═══════════════════════════════════════════════════════════════════════════════

add_city("Córdoba", "Argentina", "Córdoba, Argentina", "South America",
    -31.4201, -64.1888, 1535000,
    "Argentina's second city is a vibrant university town with stunning Jesuit architecture, a legendary nightlife, and gateway to the Sierras. Córdoba's student energy, affordable living, and cultural richness make it an excellent alternative to Buenos Aires.",
    "",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 4.5, "Business Freedom": 4.5, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 6.0, "Economy": 4.5,
     "Taxation": 4.5, "Internet Access": 6.0, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 7.0})

add_city("Rosario", "Argentina", "Rosario, Argentina", "South America",
    -32.9587, -60.6930, 1237000,
    "Messi's hometown on the Paraná River is a cultural powerhouse with excellent museums, riverside beaches, and the birthplace of the Argentine flag. Rosario's vibrant nightlife, university culture, and affordable living make it one of Argentina's most livable cities.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 4.5, "Commute": 5.0, "Business Freedom": 4.5, "Safety": 5.0,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 6.0, "Economy": 4.5,
     "Taxation": 4.5, "Internet Access": 6.0, "Leisure & Culture": 6.5, "Tolerance": 7.5, "Outdoors": 6.0})

add_city("Santa Cruz de la Sierra", "Bolivia", "Santa Cruz de la Sierra, Bolivia", "South America",
    -17.7863, -63.1812, 1838000,
    "Bolivia's economic engine is a tropical lowland city with a booming economy, modern infrastructure, and warm Camba hospitality. Santa Cruz offers an adventurous South American experience with extremely low costs and access to stunning natural areas.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 2.5, "Venture Capital": 1.0,
     "Travel Connectivity": 4.0, "Commute": 3.5, "Business Freedom": 4.0, "Safety": 5.0,
     "Healthcare": 4.0, "Education": 4.5, "Environmental Quality": 5.0, "Economy": 4.5,
     "Taxation": 6.0, "Internet Access": 4.5, "Leisure & Culture": 4.5, "Tolerance": 5.0, "Outdoors": 6.5})

add_city("Belo Horizonte", "Brazil", "Belo Horizonte, Minas Gerais, Brazil", "South America",
    -19.9167, -43.9345, 2722000,
    "Brazil's third-largest city is the gateway to historic Minas Gerais with the country's best bar scene and legendary boteco culture. Belo Horizonte's affordable living, friendly people, and stunning surrounding countryside make it a favorite among Brazilians.",
    "",
    {"Housing": 6.5, "Cost of Living": 7.0, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 4.0, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 6.0, "Education": 6.0, "Environmental Quality": 5.5, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 6.0, "Leisure & Culture": 7.0, "Tolerance": 6.5, "Outdoors": 6.0})

add_city("Brasília", "Brazil", "Brasília, Federal District, Brazil", "South America",
    -15.7975, -47.8919, 3055149,
    "Brazil's modernist capital was designed by Niemeyer and Costa as a utopian city of the future, and its sweeping architecture still impresses. Brasília's high salaries, planned green spaces, and dry climate offer a different Brazilian experience from the coastal cities.",
    "https://images.unsplash.com/photo-1532009877282-3340270e0529?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.0, "Startups": 3.5, "Venture Capital": 2.5,
     "Travel Connectivity": 6.0, "Commute": 4.0, "Business Freedom": 5.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 6.0,
     "Taxation": 4.5, "Internet Access": 6.5, "Leisure & Culture": 5.0, "Tolerance": 6.0, "Outdoors": 5.0})

add_city("Campinas", "Brazil", "Campinas, São Paulo, Brazil", "South America",
    -22.9099, -47.0626, 1213792,
    "São Paulo state's tech hub hosts major research universities and a thriving innovation ecosystem in Brazil's Silicon Valley corridor. Campinas's educated workforce, pleasant climate, and proximity to São Paulo make it an attractive Brazilian tech destination.",
    "",
    {"Housing": 6.0, "Cost of Living": 6.0, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 6.0, "Commute": 4.0, "Business Freedom": 5.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 7.5, "Environmental Quality": 6.0, "Economy": 6.0,
     "Taxation": 4.5, "Internet Access": 6.5, "Leisure & Culture": 5.5, "Tolerance": 6.5, "Outdoors": 5.0})

add_city("Curitiba", "Brazil", "Curitiba, Paraná, Brazil", "South America",
    -25.4290, -49.2671, 1948626,
    "Brazil's most planned city pioneered bus rapid transit and urban sustainability with stunning parks and a strong European heritage. Curitiba's quality of life, green spaces, and innovative urban design make it Brazil's most livable large city.",
    "https://images.unsplash.com/photo-1587843240952-938b3ef1cb8a?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 4.5, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 6.0, "Business Freedom": 5.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 7.5, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 6.5, "Leisure & Culture": 6.0, "Tolerance": 7.0, "Outdoors": 6.5})

add_city("Fortaleza", "Brazil", "Fortaleza, Ceará, Brazil", "South America",
    -3.7172, -38.5433, 2686612,
    "Brazil's sunny northeastern beach city offers year-round tropical warmth, dramatic sand dunes, and a vibrant forró music and seafood culture. Fortaleza's incredibly affordable beachfront living and warm hospitality make it popular with budget-conscious expats.",
    "https://images.unsplash.com/photo-1584465144554-5d6e0b5f738a?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 4.5, "Safety": 4.0,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 5.5, "Economy": 4.5,
     "Taxation": 4.5, "Internet Access": 5.5, "Leisure & Culture": 6.5, "Tolerance": 6.0, "Outdoors": 8.0})

add_city("Manaus", "Brazil", "Manaus, Amazonas, Brazil", "South America",
    -3.1190, -60.0217, 2219580,
    "The gateway to the Amazon Rainforest is a surprisingly modern city where the Rio Negro meets the Solimões in a spectacular meeting of waters. Manaus's opera house legacy, free trade zone economy, and unparalleled access to the world's greatest rainforest make it unique.",
    "",
    {"Housing": 6.5, "Cost of Living": 6.5, "Startups": 2.5, "Venture Capital": 1.0,
     "Travel Connectivity": 4.0, "Commute": 3.5, "Business Freedom": 4.5, "Safety": 4.5,
     "Healthcare": 4.5, "Education": 4.5, "Environmental Quality": 6.0, "Economy": 4.5,
     "Taxation": 5.5, "Internet Access": 5.0, "Leisure & Culture": 5.0, "Tolerance": 5.5, "Outdoors": 8.5})

add_city("Porto Alegre", "Brazil", "Porto Alegre, Rio Grande do Sul, Brazil", "South America",
    -30.0346, -51.2177, 1488252,
    "Southern Brazil's cultural capital blends gaucho traditions with a cosmopolitan food scene and one of Brazil's best quality-of-life indices. Porto Alegre's European-influenced architecture, vibrant nightlife, and subtropical climate make it a sophisticated Brazilian choice.",
    "",
    {"Housing": 6.0, "Cost of Living": 6.5, "Startups": 4.0, "Venture Capital": 2.5,
     "Travel Connectivity": 5.5, "Commute": 4.5, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 6.5, "Education": 7.0, "Environmental Quality": 6.0, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 6.5, "Leisure & Culture": 7.0, "Tolerance": 7.0, "Outdoors": 6.0})

add_city("Recife", "Brazil", "Recife, Pernambuco, Brazil", "South America",
    -8.0476, -34.8770, 1653461,
    "The 'Venice of Brazil' is built across islands and waterways with stunning baroque churches, world-class carnival, and thriving tech sector. Recife's beaches, cultural richness, and growing Porto Digital innovation hub make it northeast Brazil's most dynamic city.",
    "",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 4.0, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 4.5, "Safety": 4.0,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 5.0, "Economy": 4.5,
     "Taxation": 4.5, "Internet Access": 6.0, "Leisure & Culture": 7.0, "Tolerance": 6.5, "Outdoors": 7.0})

add_city("Rio de Janeiro", "Brazil", "Rio de Janeiro, Brazil", "South America",
    -22.9068, -43.1729, 6748000,
    "The Marvelous City lives up to its name with Christ the Redeemer, Sugarloaf Mountain, Copacabana, and a samba-infused joie de vivre that's infectious. Rio's stunning natural setting, beach culture, and creative energy make it one of the most beautiful cities on Earth.",
    "https://images.unsplash.com/photo-1483729558449-99ef09a8c325?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.0, "Cost of Living": 5.5, "Startups": 5.0, "Venture Capital": 3.5,
     "Travel Connectivity": 7.5, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 3.5,
     "Healthcare": 5.5, "Education": 6.0, "Environmental Quality": 6.5, "Economy": 5.5,
     "Taxation": 4.5, "Internet Access": 6.0, "Leisure & Culture": 9.0, "Tolerance": 7.0, "Outdoors": 9.5})

add_city("Salvador", "Brazil", "Salvador, Bahia, Brazil", "South America",
    -12.9714, -38.5124, 2886698,
    "Brazil's first capital is the heart of Afro-Brazilian culture with the most vibrant carnival, capoeira on the streets, and incredible Bahian cuisine. Salvador's historic Pelourinho district, tropical beaches, and rich cultural heritage make it Brazil's most soulful city.",
    "https://images.unsplash.com/photo-1579987323085-ee89b0d610b0?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 5.5, "Commute": 3.5, "Business Freedom": 4.5, "Safety": 4.0,
     "Healthcare": 5.0, "Education": 5.0, "Environmental Quality": 6.0, "Economy": 4.5,
     "Taxation": 4.5, "Internet Access": 5.5, "Leisure & Culture": 8.5, "Tolerance": 7.0, "Outdoors": 8.0})


# Rest of South America
add_city("Valparaíso", "Chile", "Valparaíso, Chile", "South America",
    -33.0472, -71.6127, 296655,
    "Chile's bohemian port city cascades down colorful hillsides to the Pacific with street art-covered funiculars and Pablo Neruda's former home. Valparaíso's creative spirit, stunning views, and UNESCO heritage make it South America's most artistic city.",
    "https://images.unsplash.com/photo-1523706907708-28e9da1ac9ae?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.5, "Cost of Living": 6.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 4.5, "Business Freedom": 7.0, "Safety": 5.5,
     "Healthcare": 6.5, "Education": 6.5, "Environmental Quality": 6.5, "Economy": 5.0,
     "Taxation": 5.5, "Internet Access": 6.5, "Leisure & Culture": 8.0, "Tolerance": 7.0, "Outdoors": 8.0})

add_city("Cali", "Colombia", "Cali, Colombia", "South America",
    3.4516, -76.5320, 2228000,
    "The world capital of salsa pulsates with music, dance, and a warm tropical energy that's contagious from the moment you arrive. Cali's affordability, vibrant nightlife, and passionate culture make it one of South America's most exciting cities.",
    "",
    {"Housing": 7.5, "Cost of Living": 8.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 4.0,
     "Healthcare": 6.0, "Education": 5.5, "Environmental Quality": 5.5, "Economy": 5.0,
     "Taxation": 5.0, "Internet Access": 5.5, "Leisure & Culture": 7.5, "Tolerance": 6.0, "Outdoors": 6.5})

add_city("Guayaquil", "Ecuador", "Guayaquil, Ecuador", "South America",
    -2.1710, -79.9224, 2723665,
    "Ecuador's largest city and Pacific port has undergone a dramatic waterfront revival with the stunning Malecón 2000 promenade. Guayaquil's tropical energy, gateway to the Galápagos, and affordable dollar-based economy attract adventurous expats.",
    "",
    {"Housing": 7.5, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 5.0, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 4.5,
     "Healthcare": 5.5, "Education": 5.0, "Environmental Quality": 5.0, "Economy": 4.5,
     "Taxation": 6.0, "Internet Access": 5.5, "Leisure & Culture": 5.0, "Tolerance": 5.5, "Outdoors": 6.0})

add_city("Quito", "Ecuador", "Quito, Ecuador", "South America",
    -0.1807, -78.4678, 2011388,
    "Ecuador's capital sits spectacularly at 2,800 meters in an Andean valley with a stunning UNESCO-listed colonial center and year-round spring weather. Quito's dollar economy, incredible biodiversity access, and affordable living attract retirees and adventurers alike.",
    "https://images.unsplash.com/photo-1510711789248-087061ceda95?auto=format&fit=crop&w=800&q=80",
    {"Housing": 7.0, "Cost of Living": 7.5, "Startups": 3.0, "Venture Capital": 1.5,
     "Travel Connectivity": 5.5, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 6.5, "Economy": 4.5,
     "Taxation": 6.0, "Internet Access": 5.5, "Leisure & Culture": 6.5, "Tolerance": 5.5, "Outdoors": 8.0})

add_city("Asunción", "Paraguay", "Asunción, Paraguay", "South America",
    -25.2637, -57.5759, 525294,
    "Paraguay's riverside capital is one of South America's most affordable cities with a growing economy and guaraní cultural heritage. Asunción's colonial architecture, friendly people, and low costs make it an emerging destination for budget-conscious expats.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 2.5, "Venture Capital": 1.0,
     "Travel Connectivity": 3.5, "Commute": 3.5, "Business Freedom": 5.0, "Safety": 5.0,
     "Healthcare": 4.5, "Education": 4.5, "Environmental Quality": 5.0, "Economy": 4.0,
     "Taxation": 7.0, "Internet Access": 5.0, "Leisure & Culture": 4.5, "Tolerance": 5.0, "Outdoors": 5.0})

add_city("Lima", "Peru", "Lima, Peru", "South America",
    -12.0464, -77.0428, 10883000,
    "The gastronomic capital of the Americas sits on dramatic Pacific cliffs with a food scene that rivals any city in the world. Lima's colonial center, world-class ceviche, and pre-Columbian heritage make it South America's most underappreciated great city.",
    "https://images.unsplash.com/photo-1531968455001-5c5272a67c8e?auto=format&fit=crop&w=800&q=80",
    {"Housing": 6.0, "Cost of Living": 7.0, "Startups": 4.5, "Venture Capital": 3.0,
     "Travel Connectivity": 7.0, "Commute": 3.0, "Business Freedom": 5.5, "Safety": 4.5,
     "Healthcare": 5.5, "Education": 5.5, "Environmental Quality": 4.5, "Economy": 5.5,
     "Taxation": 5.5, "Internet Access": 5.5, "Leisure & Culture": 8.0, "Tolerance": 5.5, "Outdoors": 6.0})

add_city("Montevideo", "Uruguay", "Montevideo, Uruguay", "South America",
    -34.9011, -56.1645, 1947604,
    "Uruguay's laid-back capital stretches along the Río de la Plata with a 22-kilometer rambla promenade, excellent steak, and progressive social policies. Montevideo's stability, safety, and European-influenced culture make it South America's most livable and tolerant capital.",
    "https://images.unsplash.com/photo-1576089073624-b5751a8f4de1?auto=format&fit=crop&w=800&q=80",
    {"Housing": 5.5, "Cost of Living": 5.0, "Startups": 3.5, "Venture Capital": 2.0,
     "Travel Connectivity": 5.5, "Commute": 5.0, "Business Freedom": 7.0, "Safety": 6.5,
     "Healthcare": 7.0, "Education": 6.5, "Environmental Quality": 7.0, "Economy": 5.5,
     "Taxation": 5.0, "Internet Access": 7.0, "Leisure & Culture": 6.5, "Tolerance": 8.5, "Outdoors": 7.0})

add_city("Caracas", "Venezuela", "Caracas, Venezuela", "South America",
    10.4806, -66.9036, 2942000,
    "Venezuela's mountain-ringed capital offers dramatic scenery and a resilient population navigating economic challenges with creative spirit. Caracas's cultural institutions, Avila National Park backdrop, and Caribbean proximity hint at the city's enormous potential.",
    "",
    {"Housing": 8.0, "Cost of Living": 8.5, "Startups": 2.0, "Venture Capital": 1.0,
     "Travel Connectivity": 4.0, "Commute": 3.0, "Business Freedom": 2.5, "Safety": 2.5,
     "Healthcare": 3.5, "Education": 5.0, "Environmental Quality": 4.5, "Economy": 2.5,
     "Taxation": 5.5, "Internet Access": 3.5, "Leisure & Culture": 5.0, "Tolerance": 5.0, "Outdoors": 7.0})


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    # Load source data
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        all_cities = json.load(f)

    print(f"Loaded {len(all_cities)} cities from master file")

    # Filter cities
    curated = []
    removed_names = []
    kept_names = []

    for city in all_cities:
        key = (city["name"], city["country"])
        if key in REMOVE_CITIES:
            removed_names.append(f"  - {city['name']}, {city['country']}")
            continue

        if key in CITY_DATA:
            curated.append(CITY_DATA[key])
            kept_names.append(f"  + {city['name']}, {city['country']}")
        else:
            removed_names.append(f"  ? {city['name']}, {city['country']} (no data)")

    # Fix duplicate slugs
    for city in curated:
        if city["name"] == "San José" and city["country"] == "Costa Rica":
            city["id"] = "san-jose-costa-rica"

    # Save output
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(curated, f, indent=2, ensure_ascii=False)

    # Print summary
    print(f"\n{'='*60}")
    print(f"CURATION SUMMARY")
    print(f"{'='*60}")
    print(f"Original cities: {len(all_cities)}")
    print(f"Removed: {len(removed_names)}")
    print(f"Curated (with data): {len(curated)}")

    # Continent breakdown
    continents = {}
    for city in curated:
        cont = city["continent"]
        continents[cont] = continents.get(cont, 0) + 1

    print(f"\nBreakdown by continent:")
    for cont in sorted(continents.keys()):
        print(f"  {cont}: {continents[cont]}")

    # Score stats
    scores_all = [c["teleport_city_score"] for c in curated]
    print(f"\nTeleport City Score range: {min(scores_all):.1f} - {max(scores_all):.1f}")
    print(f"Average: {sum(scores_all)/len(scores_all):.1f}")

    print(f"\nOutput saved to: {OUTPUT_FILE}")

    # Check for any cities that were in master but had no data and weren't in remove list
    missing = [n for n in removed_names if n.startswith("  ?")]
    if missing:
        print(f"\nWARNING: {len(missing)} cities had no data and weren't in remove list:")
        for m in missing:
            print(m)


if __name__ == "__main__":
    main()

