# Realitky Scraper

## Popis
Projekt pro hromadný scraping realitních webů, ukládání detailů nemovitostí a obrázků, čištění a sjednocení dat.

### Weby
- Seznam realitek:
- Remax.cz
- Bezrealitky
- Bidli
- CENTURY 21
- Flat Zone
- PATREAL
- Bazoš
- iDnes reality
- Realitymat
- RealSpektrum
- Sreality
- UNICAREAL
- České Reality
- RealityMix
- Realitní komora
- UlovDomov

## Struktura
- `core/` – logika scraperů, utilit, čištění dat
- `config/` – konfigurační soubory
- `data/` – uložená data (raw, cleaned, images)
- `scripts/` – spouštěcí a pomocné skripty
- `tests/` – jednotkové testy

## Konfigurace
Nastavení v `config/settings.yaml`:
- lokalita, typ nemovitosti, režim (prodej/pronájem)
- výstupní formát (CSV/DB)
- cesty k datům

## Spuštění
```bash
python scripts/run_scraper.py

## Struktura
Realitky/
│
├── core/
│   ├── __init__.py
│   ├── base_scraper.py         # Abstraktní třída pro scrapery
│   ├── websites/
│   │   ├── __init__.py
│   │   ├── remax_scraper.py    # Konkrétní scraper pro Remax
│   │   └── ...                 # Další weby
│   ├── utils.py                # Pomocné funkce (hash, ukládání, atd.)
│   └── cleaning.py             # Sjednocení a čištění dat
│
├── config/
│   ├── settings.yaml           # Hlavní konfigurační soubor
│   └── ...                     # Další konfigurace (např. mapping polí)
│
├── data/
│   ├── raw/                    # Neupravená data (HTML, JSON, atd.)
│   ├── cleaned/                # Vyčištěná data (CSV, Parquet, atd.)
│   └── images/                 # Obrázky nemovitostí (struktura viz níže)
│
├── scripts/
│   ├── run_scraper.py          # Spouštěcí skript
│   └── clean_data.py           # Skript na čištění/sjednocení
│
├── tests/                      # Jednotkové testy
│
├── requirements.txt
├── README.md
└── .gitignore