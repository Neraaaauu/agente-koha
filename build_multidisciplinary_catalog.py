# -*- coding: utf-8 -*-
"""
Generador del catálogo multidisciplinario oficial ampliado (750 libros)
para la Biblioteca Central Mexicali (UABC).
Cubre todas las facultades con autores y libros de texto canónicos:
- 200 libros: Ingeniería y Tecnología (FCITEC)
- 190 libros: Derecho, Ciencias Sociales, Humanidades y Metodología (Sampieri)
- 180 libros: Administración, Contabilidad y Negocios
- 180 libros: Salud, Medicina, Ciencias Básicas y Artes
"""

import csv
import json
import os
import re

CSV_PATH = r"C:\Users\Nera\Downloads\DIB-ACERVO-BIBLIOTECA CENTRAL MEXICALI.csv"
OUTPUT_PATH = r"C:\Users\Nera\.gemini\antigravity\scratch\koha_agent_mvp\catalog_mock.json"

TARGET_QUOTAS = {
    'ingenieria': 200,
    'derecho_humanidades': 190,
    'admon_economia': 180,
    'salud_ciencias': 180
}

PREFIX_MAP = {
    'ingenieria': {'QA', 'TK', 'TA', 'TJ', 'T', 'TS', 'TH', 'TP', 'TN'},
    'derecho_humanidades': {'KGF', 'K', 'KG', 'KD', 'KF', 'F', 'PQ', 'PN', 'PS', 'P', 'LB', 'L', 'B', 'BF', 'JL', 'JC', 'J'},
    'admon_economia': {'HD', 'HF', 'HC', 'HB', 'HG', 'HM', 'HJ', 'HE'},
    'salud_ciencias': {'R', 'RA', 'RB', 'RC', 'RD', 'RM', 'RT', 'RJ', 'RK', 'QP', 'QM', 'QC', 'QD', 'QH', 'QK', 'QL', 'QR', 'Q', 'S', 'NA', 'N'}
}

CANONICAL_PRIORITY = {
    'ingenieria': [
        'russell', 'norvig', 'goodfellow', 'tanenbaum', 'silberschatz', 'korth', 'elmasri',
        'sommerville', 'pressman', 'stallings', 'joyanes', 'deitel', 'mckinney', 'stewart',
        'larson', 'zill', 'granville', 'baldor', 'anton', 'kreyszig', 'chapra', 'boylestad',
        'floyd', 'hayt', 'alexander', 'sadiku', 'ogata', 'dorf', 'olivares', 'cengel', 'mott',
        'shigley', 'hibbeler', 'beer', 'johnston', 'park', 'nilson', 'perez alama', 'gonzalez cuevas',
        'juarez badillo', 'groover', 'gutierrez pulido', 'montgomery', 'chang'
    ],
    'derecho_humanidades': [
        'sampieri', 'hernandez sampieri', 'burgoa', 'carbonell', 'fix-zamudio', 'fix zamudio',
        'rojina villegas', 'trueba urbina', 'de pina', 'castellanos', 'davalos mejia', 'tena ramirez',
        'acosta romero', 'garcia maynez', 'orozco henriquez', 'tamayo', 'bunge', 'piaget', 'freud',
        'papalia', 'garcia marquez', 'octavio paz', 'carlos fuentes', 'juan rulfo', 'pinera ramirez',
        'leon-portilla', 'krauze', 'sejourne', 'cosio villegas', 'cabanellas'
    ],
    'admon_economia': [
        'chiavenato', 'lara flores', 'garcia colin', 'guajardo', 'robbins', 'koontz', 'weihrich',
        'kotler', 'stanton', 'fischer', 'gitman', 'ross', 'van horne', 'samuelson', 'mankiw',
        'parkin', 'porter', 'drucker', 'horngren', 'warren', 'meigs', 'ramirez padilla', 'krugman',
        'stiglitz', 'anisi', 'blanchard', 'fischer, stanley', 'dornbusch'
    ],
    'salud_ciencias': [
        'guyton', 'hall', 'moore', 'netter', 'tortora', 'goodman', 'gilman', 'robbins', 'harrison',
        'ganong', 'harper', 'murray', 'brunner', 'suddarth', 'potter', 'perry', 'kumate', 'farreras',
        'rozman', 'jawetz', 'sears', 'zemansky', 'tipler', 'serway', 'resnick', 'halliday', 'chang',
        'brown', 'petrucci', 'curtis', 'campbell', 'ching', 'neufert', 'bazant'
    ]
}

COVERS = {
    'ingenieria': "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&auto=format&fit=crop&q=80",
    'derecho_humanidades': "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&auto=format&fit=crop&q=80",
    'admon_economia': "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&auto=format&fit=crop&q=80",
    'salud_ciencias': "https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?w=400&auto=format&fit=crop&q=80"
}

def clean_title(title):
    t = re.sub(r'\[.*?\]', '', title)
    t = t.split('/')[0].strip()
    t = t.split('=')[0].strip()
    t = re.sub(r'[:;.,\s]+$', '', t)
    t = re.sub(r'\s+', ' ', t)
    return t.strip()

def clean_subject(subj):
    s = re.sub(r'\blemb\b', '', subj, flags=re.IGNORECASE)
    s = re.sub(r'\s+', ' ', s).strip()
    s = re.sub(r'[,.;\s]+$', '', s)
    return s

def clean_year(yr):
    m = re.search(r'\b(19\d{2}|20\d{2})\b', yr)
    return m.group(1) if m else "2020"

def extract_fallback_author(raw_title, raw_author):
    a = re.sub(r'\d{4}(-\d{4})?', '', raw_author)
    a = re.sub(r'[,.;\s]+$', '', a).strip()
    if a and len(a) > 3:
        return a
    if '/' in raw_title:
        stmt = raw_title.split('/')[1].split(';')[0].strip()
        stmt = re.sub(r'^(por|tr\.|trad\.|text\s+by)\s+', '', stmt, flags=re.I)
        stmt = re.sub(r'\s*\.\.\..*$', '', stmt)
        stmt = re.sub(r'[,.;\s]+$', '', stmt).strip()
        if len(stmt) > 3:
            return stmt
    return "Facultad UABC"

def build_catalog():
    print("Iniciando extracción multidisciplinaria del catálogo oficial UABC...")
    
    priority_books = {k: {} for k in TARGET_QUOTAS}
    regular_books = {k: {} for k in TARGET_QUOTAS}

    with open(CSV_PATH, mode='r', encoding='utf-8', errors='replace') as f:
        reader = csv.reader(f, delimiter=';')
        next(reader)
        for row in reader:
            if len(row) < 3:
                continue
            clasif = row[0].strip()
            raw_title = row[1].strip()
            raw_author = row[2].strip()
            inv = row[3].strip() if len(row) > 3 else ''
            publisher = row[9].strip() if len(row) > 9 else ''
            year_raw = row[10].strip() if len(row) > 10 else ''
            raw_subj = row[14].strip() if len(row) > 14 else ''
            isbn = row[17].strip() if len(row) > 17 else ''
            estado = row[21].strip() if len(row) > 21 else 'DISPONIBLE'

            m = re.match(r'^([A-Z]{1,3})', clasif)
            if not m:
                continue
            prefix = m.group(1)

            ct = clean_title(raw_title)
            ca = extract_fallback_author(raw_title, raw_author)
            if not ct or len(ct) < 4:
                continue

            full_str = f"{ct} {ca} {raw_title}".lower()

            # Mapeo especial para Metodología de la Investigación (Sampieri)
            if 'sampieri' in full_str or 'metodología de la investigación' in full_str:
                target_area = 'derecho_humanidades'
            else:
                target_area = None
                for area_key, prefixes in PREFIX_MAP.items():
                    if prefix in prefixes:
                        target_area = area_key
                        break

            if not target_area:
                continue

            norm_key = (ct.lower(), ca.lower())
            status_desc = "En préstamo" if "PRESTADO" in estado.upper() else "Disponible"
            item_obj = {
                "item_id": 0,
                "barcode": inv if inv else f"MXL-{100000 + len(regular_books[target_area])}",
                "holding_library": "Biblioteca Central Mexicali",
                "location": "Colección General - Planta Alta",
                "item_call_number": clasif,
                "status": status_desc
            }

            is_priority = any(canon in full_str for canon in CANONICAL_PRIORITY.get(target_area, []))
            target_dict = priority_books[target_area] if is_priority else regular_books[target_area]

            if norm_key in target_dict:
                if len(target_dict[norm_key]["items"]) < 3:
                    target_dict[norm_key]["items"].append(item_obj)
            elif norm_key in regular_books[target_area]:
                if len(regular_books[target_area][norm_key]["items"]) < 3:
                    regular_books[target_area][norm_key]["items"].append(item_obj)
            else:
                clean_s = clean_subject(raw_subj)
                if not clean_s or len(clean_s) < 5:
                    clean_s = f"Acervo General, {target_area.replace('_', ' ').title()}"

                book_data = {
                    "title": ct,
                    "author": ca,
                    "call_number": clasif,
                    "publisher": publisher.rstrip(',;.') if publisher else "Editorial Universitaria UABC",
                    "publication_year": clean_year(year_raw),
                    "isbn": isbn.split(' ')[0] if isbn else "978-607-0000-00",
                    "subject": clean_s,
                    "abstract": f"Obra especializada sobre {ct}. Recurso bibliográfico recomendado por la Biblioteca Central Mexicali para las carreras de la UABC.",
                    "cover_url": COVERS[target_area],
                    "items": [item_obj]
                }
                target_dict[norm_key] = book_data

    final_books = []
    current_biblio_id = 101
    current_item_id = 1001

    for area_key, quota in TARGET_QUOTAS.items():
        priorities = list(priority_books[area_key].values())
        regular = list(regular_books[area_key].values())

        selected = priorities[:quota]
        if len(selected) < quota:
            remaining = quota - len(selected)
            selected.extend(regular[:remaining])

        print(f"  {area_key}: {len(selected)} libros (de los cuales {min(len(priorities), quota)} son autores canónicos).")

        for b in selected:
            b["biblio_id"] = current_biblio_id
            current_biblio_id += 1
            for it in b["items"]:
                it["item_id"] = current_item_id
                current_item_id += 1
            final_books.append(b)

    print(f"\nTotal libros generados para el Mock Multidisciplinario: {len(final_books)}")

    with open(OUTPUT_PATH, mode='w', encoding='utf-8') as f:
        json.dump(final_books, f, indent=2, ensure_ascii=False)

    print(f"[OK] Archivo guardado: {OUTPUT_PATH}")

if __name__ == "__main__":
    build_catalog()
