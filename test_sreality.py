import asyncio
import httpx
import json
import os
import psycopg2
from dotenv import load_dotenv

BASE_URL = "https://www.sreality.cz/api/cs/v2/estates"
DETAIL_URL = "https://www.sreality.cz/api/cs/v2/estates/{}"
PER_PAGE = 10
PAGES = 2

# Načti .env
load_dotenv()

def save_to_postgres(details):
    conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)
    cur = conn.cursor()
    # Vytvořte tabulku jednorázově ručně nebo přidejte CREATE TABLE IF NOT EXISTS
    cur.execute("""
        CREATE TABLE IF NOT EXISTS sreality_estates (
            id TEXT PRIMARY KEY,
            name TEXT,
            locality TEXT,
            price NUMERIC
        );
    """)
    for detail in details:
        cur.execute("""
            INSERT INTO sreality_estates (id, name, locality, price)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING
        """, (
            detail.get('hash_id'),
            detail.get('name'),
            detail.get('locality'),
            detail.get('price', {}).get('value_raw', None)
        ))
    conn.commit()
    cur.close()
    conn.close()
    print("Výsledek uložen do PostgreSQL tabulky sreality_estates")

async def fetch_page(page):
    params = {"per_page": PER_PAGE, "page": page}
    async with httpx.AsyncClient() as client:
        response = await client.get(BASE_URL, params=params)
        response.raise_for_status()
        data = response.json()
        return data.get('_embedded', {}).get('estates', [])

async def fetch_detail(hash_id):
    async with httpx.AsyncClient() as client:
        response = await client.get(DETAIL_URL.format(hash_id))
        response.raise_for_status()
        return response.json()

async def main():
    all_details = []
    for page in range(1, PAGES + 1):
        estates = await fetch_page(page)
        print(f"Stránka {page}: {len(estates)} nemovitostí")
        tasks = [fetch_detail(estate["hash_id"]) for estate in estates]
        details = await asyncio.gather(*tasks)
        for detail in details:
            print(f"- {detail.get('name')} ({detail.get('locality')})")
        all_details.extend(details)
    # # Uložení do CSV
    # os.makedirs("data/csv", exist_ok=True)
    # csv_path = "data/csv/sreality_test_details.csv"
    # with open(csv_path, "w", encoding="utf-8") as f:
    #     f.write("id,name,locality,price\n")
    #     for detail in all_details:
    #         f.write(f"{detail.get('hash_id')},{detail.get('name')},{detail.get('locality')},{detail.get('price', {}).get('value_raw', 'N/A')}\n")

    # # Uložení do JSON
    # os.makedirs("data/json", exist_ok=True)
    # with open("data/json/sreality_test_details.json", "w", encoding="utf-8") as f:
    #     json.dump(all_details, f, ensure_ascii=False, indent=2)
    # print("Výsledek uložen do data/json/sreality_test_details.json")

    # Uložení do PostgreSQL
    save_to_postgres(all_details)

if __name__ == "__main__":
    asyncio.run(main())