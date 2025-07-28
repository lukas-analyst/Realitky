"""
Český katastr nemovitostí API
Napojení pro získání katastálních dat pro realitní projekt

Hlavní API endpointy:
- ČÚZK WMS/WFS služby
- Nahlizenidokn.cuzk.cz API
- Dálkový přístup do katastru

Užitečná data pro realitní projekt:
1. Parcely a pozemky
2. Stavby a budovy  
3. Vlastnické vztahy
4. Právní vztahy
5. Územní plánování
6. Cenové mapy
"""

import requests
import xml.etree.ElementTree as ET
from typing import Dict, List, Optional, Tuple
import json
import time
from dataclasses import dataclass
from urllib.parse import urlencode
import os
from dotenv import load_dotenv


@dataclass
class ParcelaInfo:
    """Informace o parcele"""
    cislo_parcely: str
    katastralni_uzemi: str
    plocha: float  # m²
    druh_pozemku: str
    zpusob_vyuziti: str
    vlastnici: List[str]
    lv_cislo: str  # číslo listu vlastnictví


@dataclass
class StavbaInfo:
    """Informace o stavbě"""
    cislo_popisne: Optional[str]
    cislo_evidencni: Optional[str]
    typ_stavby: str
    zpusob_vyuziti: str
    zastavena_plocha: float  # m²
    pocet_podlazi: Optional[int]
    parcela_cislo: str
    vlastnici: List[str]


@dataclass
class CenovaMapaInfo:
    """Informace z cenové mapy"""
    cena_za_m2: float
    lokalita: str
    kategorie: str
    platnost_od: str
    platnost_do: Optional[str]


class CeskyKatastrAPI:
    """API klient pro český katastr nemovitostí"""
    
    def __init__(self):
        self.base_url_wms = "https://services.cuzk.cz/wms/wms.asp"
        self.base_url_nahlizenidokn = "https://nahlizenidokn.cuzk.cz/api"
        self.base_url_dp = "https://dp.cuzk.cz/api"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'RealitkyProject/1.0'
        })
    
    def get_parcela_by_coordinates(self, lat: float, lon: float) -> Optional[ParcelaInfo]:
        """
        Najde parcelu podle GPS souřadnic
        Užitečné pro: mapování nemovitostí na parcely
        """
        try:
            # WFS dotaz pro identifikaci parcely
            params = {
                'SERVICE': 'WFS',
                'VERSION': '1.0.0',
                'REQUEST': 'GetFeature',
                'TYPENAME': 'KN:PARCELY',
                'OUTPUTFORMAT': 'text/xml',
                'BBOX': f"{lon-0.001},{lat-0.001},{lon+0.001},{lat+0.001}",
                'SRS': 'EPSG:4326'
            }
            
            response = self.session.get(self.base_url_wms, params=params, timeout=30)
            response.raise_for_status()
            
            return self._parse_parcela_xml(response.text)
            
        except Exception as e:
            print(f"Chyba při získávání parcely: {e}")
            return None
    
    def get_stavba_by_coordinates(self, lat: float, lon: float) -> Optional[StavbaInfo]:
        """
        Najde stavbu podle GPS souřadnic
        Užitečné pro: doplnění informací o budovách
        """
        try:
            params = {
                'SERVICE': 'WFS',
                'VERSION': '1.0.0',
                'REQUEST': 'GetFeature',
                'TYPENAME': 'KN:STAVBY',
                'OUTPUTFORMAT': 'text/xml',
                'BBOX': f"{lon-0.001},{lat-0.001},{lon+0.001},{lat+0.001}",
                'SRS': 'EPSG:4326'
            }
            
            response = self.session.get(self.base_url_wms, params=params, timeout=30)
            response.raise_for_status()
            
            return self._parse_stavba_xml(response.text)
            
        except Exception as e:
            print(f"Chyba při získávání stavby: {e}")
            return None

    def get_vlastnici_by_lv(self, lv_cislo: str, katastralni_uzemi: str) -> List[str]:
        """
        Získá vlastníky podle čísla listu vlastnictví
        Užitečné pro: analýzu vlastnických vztahů
        """
        try:
            load_dotenv()
            api_key = os.getenv("CUZK_API_KEY")

            # Sestavení URL pro dálkový přístup (DP)
            url = f"{self.base_url_dp}/lv"
            params = {
                "lv_cislo": lv_cislo,
                "katastralni_uzemi": katastralni_uzemi,
                "api_key": api_key
            }
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            data = response.json()

            # Předpokládáme, že vlastníci jsou v poli 'vlastnici'
            return data.get("vlastnici", [])
        except Exception as e:
            print(f"Chyba při získávání vlastníků: {e}")
            return []
    
    def get_cenova_mapa(self, lat: float, lon: float) -> Optional[CenovaMapaInfo]:
        """
        Získá informace z cenové mapy
        Užitečné pro: odhad tržních cen, analýza lokalit
        """
        try:
            # Cenové mapy jsou dostupné přes speciální WMS službu
            params = {
                'SERVICE': 'WFS',
                'VERSION': '1.0.0', 
                'REQUEST': 'GetFeature',
                'TYPENAME': 'CENOVE_MAPY',
                'OUTPUTFORMAT': 'text/xml',
                'BBOX': f"{lon-0.001},{lat-0.001},{lon+0.001},{lat+0.001}",
                'SRS': 'EPSG:4326'
            }
            
            # Placeholder - skutečná implementace by parsovala XML
            return CenovaMapaInfo(
                cena_za_m2=15000.0,
                lokalita="Praha 4 - Modřany",
                kategorie="Bydlení - bytové domy",
                platnost_od="2024-01-01",
                platnost_do=None
            )
            
        except Exception as e:
            print(f"Chyba při získávání cenové mapy: {e}")
            return None
    
    def get_uzemni_plan(self, lat: float, lon: float) -> Dict[str, str]:
        """
        Získá informace z územního plánu
        Užitečné pro: analýza potenciálu výstavby, omezení
        """
        try:
            params = {
                'SERVICE': 'WFS',
                'VERSION': '1.0.0',
                'REQUEST': 'GetFeature', 
                'TYPENAME': 'UZEMNI_PLAN',
                'OUTPUTFORMAT': 'text/xml',
                'BBOX': f"{lon-0.001},{lat-0.001},{lon+0.001},{lat+0.001}",
                'SRS': 'EPSG:4326'
            }
            
            # Placeholder pro územní plán
            return {
                "funkcni_vyuziti": "Plochy bydlení - bytové",
                "koeficient_zastaveni": "0.4",
                "max_pocet_podlazi": "12",
                "omezeni": "Žádná zvláštní omezení"
            }
            
        except Exception as e:
            print(f"Chyba při získávání územního plánu: {e}")
            return {}
    
    def _parse_parcela_xml(self, xml_content: str) -> Optional[ParcelaInfo]:
        """Parsuje XML odpověď pro parcelu a uloží výsledek do souboru"""
        try:
            # Uložení surové XML odpovědi do souboru
            with open("parcela_response.xml", "w", encoding="utf-8") as f:
                f.write(xml_content)
            
            print("=== XML ODPOVĚĎ PRO PARCELU ===")
            print(xml_content[:1000] + "..." if len(xml_content) > 1000 else xml_content)
            
            root = ET.fromstring(xml_content)
            
            # Pokus o extrakci základních informací
            # (Struktura závisí na skutečné odpovědi z ČÚZK)
            parcela_info = {
                "xml_root": str(root.tag),
                "xml_attributes": root.attrib,
                "child_elements": [child.tag for child in root],
                "full_xml_content": xml_content
            }
            
            # Uložení parsovaných dat do JSON
            with open("parcela_parsed.json", "w", encoding="utf-8") as f:
                json.dump(parcela_info, f, ensure_ascii=False, indent=2)
            
            print(f"XML root element: {root.tag}")
            print(f"Attributes: {root.attrib}")
            print(f"Child elements: {[child.tag for child in root]}")
            
            # Zatím vracíme placeholder data s reálnými informacemi z XML
            return ParcelaInfo(
                cislo_parcely="N/A",
                katastralni_uzemi="N/A", 
                plocha=0.0,
                druh_pozemku="N/A",
                zpusob_vyuziti="N/A",
                vlastnici=["N/A"],
                lv_cislo="N/A"
            )
            
        except Exception as e:
            print(f"Chyba při parsování XML parcely: {e}")
            return None
    
    def _parse_stavba_xml(self, xml_content: str) -> Optional[StavbaInfo]:
        """Parsuje XML odpověď pro stavbu"""
        try:
            # Uložení surové XML odpovědi do souboru
            with open("stavba_response.xml", "w", encoding="utf-8") as f:
                f.write(xml_content)
            
            print("=== XML ODPOVĚĎ PRO STAVBU ===")
            print(xml_content[:1000] + "..." if len(xml_content) > 1000 else xml_content)
            
            root = ET.fromstring(xml_content)
            
            # Pokus o extrakci základních informací
            stavba_info = {
                "xml_root": str(root.tag),
                "xml_attributes": root.attrib,
                "child_elements": [child.tag for child in root],
                "full_xml_content": xml_content
            }
            
            # Uložení parsovaných dat do JSON
            with open("stavba_parsed.json", "w", encoding="utf-8") as f:
                json.dump(stavba_info, f, ensure_ascii=False, indent=2)
            
            print(f"XML root element: {root.tag}")
            print(f"Attributes: {root.attrib}")
            print(f"Child elements: {[child.tag for child in root]}")
            
            return StavbaInfo(
                cislo_popisne="N/A",
                cislo_evidencni=None,
                typ_stavby="N/A",
                zpusob_vyuziti="N/A",
                zastavena_plocha=0.0,
                pocet_podlazi=None,
                parcela_cislo="N/A",
                vlastnici=["N/A"]
            )
            
        except Exception as e:
            print(f"Chyba při parsování XML stavby: {e}")
            return None


def enrich_property_with_cadastral_data(property_data: Dict, 
                                       lat: float, 
                                       lon: float) -> Dict:
    """
    Obohacuje data nemovitosti o katastálne informace
    
    Užitečné pro:
    - Doplnění chybějících údajů o nemovitostech
    - Validace existujících dat
    - Přidání informací o vlastnictví
    - Analýza územního potenciálu
    """
    api = CeskyKatastrAPI()
    
    # Základní katastálne data
    parcela = api.get_parcela_by_coordinates(lat, lon)
    stavba = api.get_stavba_by_coordinates(lat, lon)
    cenova_mapa = api.get_cenova_mapa(lat, lon)
    uzemni_plan = api.get_uzemni_plan(lat, lon)
    
    # Obohacení property_data
    enriched_data = property_data.copy()
    
    if parcela:
        enriched_data.update({
            'katastr_parcela_cislo': parcela.cislo_parcely,
            'katastr_uzemi': parcela.katastralni_uzemi,
            'katastr_plocha_pozemku': parcela.plocha,
            'katastr_druh_pozemku': parcela.druh_pozemku,
            'katastr_lv_cislo': parcela.lv_cislo
        })
    
    if stavba:
        enriched_data.update({
            'katastr_cislo_popisne': stavba.cislo_popisne,
            'katastr_typ_stavby': stavba.typ_stavby,
            'katastr_zastavena_plocha': stavba.zastavena_plocha,
            'katastr_pocet_podlazi': stavba.pocet_podlazi
        })
    
    if cenova_mapa:
        enriched_data.update({
            'cenova_mapa_cena_m2': cenova_mapa.cena_za_m2,
            'cenova_mapa_kategorie': cenova_mapa.kategorie
        })
    
    if uzemni_plan:
        enriched_data.update({
            'uzemni_plan_vyuziti': uzemni_plan.get('funkcni_vyuziti'),
            'uzemni_plan_max_podlazi': uzemni_plan.get('max_pocet_podlazi')
        })
    
    return enriched_data


# Příklad použití
if __name__ == "__main__":
    # Test API
    api = CeskyKatastrAPI()
    
    # GPS souřadnice nějaké nemovitosti v Praze
    lat, lon = 49.943275, 14.704288
    
    print("=== TESTOVÁNÍ ČESKÉHO KATASTRU API ===")
    print(f"GPS souřadnice: {lat}, {lon}")
    print()
    
    print("=== KATASTÁLNE INFORMACE ===")
    
    # Test získání parcely
    print("Získávám informace o parcele...")
    parcela = api.get_parcela_by_coordinates(lat, lon)
    if parcela:
        print(f"✓ Parcela nalezena:")
        print(f"  Číslo parcely: {parcela.cislo_parcely}")
        print(f"  Katastrální území: {parcela.katastralni_uzemi}")
        print(f"  Plocha: {parcela.plocha} m²")
        print(f"  Druh pozemku: {parcela.druh_pozemku}")
    else:
        print("✗ Parcela nenalezena nebo chyba API")
    print()
    
    # Test získání stavby
    print("Získávám informace o stavbě...")
    stavba = api.get_stavba_by_coordinates(lat, lon)
    if stavba:
        print(f"✓ Stavba nalezena:")
        print(f"  Číslo popisné: {stavba.cislo_popisne}")
        print(f"  Typ stavby: {stavba.typ_stavby}")
        print(f"  Zastavěná plocha: {stavba.zastavena_plocha} m²")
        print(f"  Počet podlaží: {stavba.pocet_podlazi}")
    else:
        print("✗ Stavba nenalezena nebo chyba API")
    print()
    
    # Test cenové mapy
    print("Získávám informace z cenové mapy...")
    cenova_mapa = api.get_cenova_mapa(lat, lon)
    if cenova_mapa:
        print(f"✓ Cenová mapa:")
        print(f"  Cena za m²: {cenova_mapa.cena_za_m2} Kč/m²")
        print(f"  Kategorie: {cenova_mapa.kategorie}")
        print(f"  Lokalita: {cenova_mapa.lokalita}")
    else:
        print("✗ Cenová mapa nenalezena nebo chyba API")
    print()
    
    print("=== SOUHRN ===")
    print("Soubory s odpověďmi byly uloženy:")
    print("- parcela_response.xml - surová XML odpověď pro parcelu")
    print("- parcela_parsed.json - parsované informace o parcele")
    print("- stavba_response.xml - surová XML odpověď pro stavbu") 
    print("- stavba_parsed.json - parsované informace o stavbě")
