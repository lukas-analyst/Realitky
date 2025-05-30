import json
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Příklad: načtení JSONu ze souboru
with open('data\json\sreality_test_details.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Vezmeme první nemovitost (případně iterujte přes všechny)
item = data[0]

def extract_set(items, name):
    for i in items:
        if i['name'] == name and i['type'] == 'set':
            return ', '.join([v['value'] for v in i['value']])
    return None

def extract_value(items, name):
    for i in items:
        if i['name'] == name:
            return i['value']
    return None

def extract_int(items, name):
    val = extract_value(items, name)
    try:
        return int(val.replace('\xa0','').replace(' ',''))
    except:
        return None

conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD')
)
cur = conn.cursor()

cur.execute("""
INSERT INTO sreality (
    id, nazev, popis, kategorie_main, kategorie_sub, kategorie_type, lokalita, adresa, adresa_presnost,
    cena, cena_text, cena_puvodni, pozn_cena, stavba, stav_objektu, vlastnictvi, umisteni_objektu, podlazi,
    uzitna_plocha, sklep, garaz, datum_nastehovani, voda, odpad, telekomunikace, elektrina, doprava, komunikace,
    typ_bytu, lat, lon, kontakt_jmeno, kontakt_email, kontakt_telefon, obrazky
) VALUES (
    %(id)s, %(nazev)s, %(popis)s, %(kategorie_main)s, %(kategorie_sub)s, %(kategorie_type)s, %(lokalita)s, %(adresa)s, %(adresa_presnost)s,
    %(cena)s, %(cena_text)s, %(cena_puvodni)s, %(pozn_cena)s, %(stavba)s, %(stav_objektu)s, %(vlastnictvi)s, %(umisteni_objektu)s, %(podlazi)s,
    %(uzitna_plocha)s, %(sklep)s, %(garaz)s, %(datum_nastehovani)s, %(voda)s, %(odpad)s, %(telekomunikace)s, %(elektrina)s, %(doprava)s, %(komunikace)s,
    %(typ_bytu)s, %(lat)s, %(lon)s, %(kontakt_jmeno)s, %(kontakt_email)s, %(kontakt_telefon)s, %(obrazky)s
)
""", {
    'id': int(extract_value(item['items'], 'ID')),
    'nazev': item['name']['value'],
    'popis': item['text']['value'],
    'kategorie_main': item['seo']['category_main_cb'],
    'kategorie_sub': item['seo']['category_sub_cb'],
    'kategorie_type': item['seo']['category_type_cb'],
    'lokalita': item['seo']['locality'],
    'adresa': item['locality']['value'],
    'adresa_presnost': item['locality']['accuracy'],
    'cena': item['price_czk']['value_raw'],
    'cena_text': item['price_czk']['value'],
    'cena_puvodni': extract_int(item['items'], 'Původní cena'),
    'pozn_cena': extract_value(item['items'], 'Poznámka k ceně'),
    'stavba': extract_value(item['items'], 'Stavba'),
    'stav_objektu': extract_value(item['items'], 'Stav objektu'),
    'vlastnictvi': extract_value(item['items'], 'Vlastnictví'),
    'umisteni_objektu': extract_value(item['items'], 'Umístění objektu'),
    'podlazi': extract_value(item['items'], 'Podlaží'),
    'uzitna_plocha': extract_int(item['items'], 'Užitná ploch'),
    'sklep': extract_int(item['items'], 'Sklep'),
    'garaz': extract_int(item['items'], 'Garáž'),
    'datum_nastehovani': extract_value(item['items'], 'Datum nastěhování'),
    'voda': extract_set(item['items'], 'Voda'),
    'odpad': extract_set(item['items'], 'Odpad'),
    'telekomunikace': extract_set(item['items'], 'Telekomunikace'),
    'elektrina': extract_set(item['items'], 'Elektřina'),
    'doprava': extract_set(item['items'], 'Doprava'),
    'komunikace': extract_set(item['items'], 'Komunikace'),
    'typ_bytu': extract_value(item['items'], 'Typ bytu'),
    'lat': item['map']['lat'],
    'lon': item['map']['lon'],
    'kontakt_jmeno': item['contact']['name'],
    'kontakt_email': item['contact']['email'],
    'kontakt_telefon': item['contact']['phones'][0]['number'] if item['contact']['phones'] else None,
    'obrazky': json.dumps(item['_embedded']['images'])
})

conn.commit()
cur.close()
conn.close()