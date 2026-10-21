#!/usr/bin/env python3
"""Download Iceland landmark photos from Wikimedia Commons into the app bundle.

Each place lists candidate Commons files; the first one that resolves is used.
A "wiki:" candidate falls back to the lead image of that English Wikipedia
article. Attribution (author, license, source page) is written to credits.json,
which the app shows on the Info tab.
"""

import html
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

API = "https://en.wikipedia.org/w/api.php"
COMMONS_API = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "IcelandApp/1.0 (https://github.com/PeterPanSwift/Iceland-App; demo build)"
WIDTH = 1280
OUT_DIR = Path(__file__).resolve().parent.parent / "IcelandApp" / "Photos"

PLACES = {
    "hallgrimskirkja": ["Hallgrímskirkja Reykjavík.jpg", "wiki:Hallgrímskirkja"],
    "thingvellir": ["wiki:Þingvellir"],
    "strokkur": ["Strokkur Eruption.JPG", "Strokkur Geysir Iceland 2005-7.JPG", "wiki:Strokkur"],
    "gullfoss": [
        "Gullfoss, Suðurland, Islandia, 2014-08-16, DD 119.JPG",
        "Gullfoss, Iceland, 20230501 0940 3780.jpg",
        "wiki:Gullfoss",
    ],
    "seljalandsfoss": [
        "Seljalandsfoss (16467797491).jpg",
        "Seljalandsfoss, Suðurland, Islandia, 2014-08-17, DD 117.JPG",
        "wiki:Seljalandsfoss",
    ],
    "skogafoss": [
        "Skogafoss waterfall - Iceland - Landscape photography (34692750741).jpg",
        "Skógafoss, Iceland (Unsplash aiKyJ6rHCP4).jpg",
        "wiki:Skógafoss",
    ],
    "reynisfjara": [
        "Reynisfjara and Reynisdrangar, Iceland.jpg",
        "Reynisfjara, Iceland, 20230501 1639 4044.jpg",
        "wiki:Reynisfjara",
    ],
    "jokulsarlon": [
        "Jökulsárlón glacier lagoon, Iceland, 20240719 1141 2538.jpg",
        "Glacier Lagoon with an Iceberg (31899020178).jpg",
        "wiki:Jökulsárlón",
    ],
    "kirkjufell": [
        "Kirkjufellsfoss, Iceland, 20230505 1406 5209.jpg",
        "Kirkjufellsfoss Waterfall (29432886018).jpg",
        "wiki:Kirkjufell",
    ],
    "bluelagoon": [
        "Blue Lagoon, Iceland (22360145156).jpg",
        "Iceland - Blue Lagoon 09 (6571266721).jpg",
        "wiki:Blue Lagoon (geothermal spa)",
    ],
    "dettifoss": ["wiki:Dettifoss"],
    "aurora": [
        "Aurora Borealis - Iceland - 2 Nov. 2013.jpg",
        "Iceland Aurora 1.jpg",
        "wiki:Aurora",
    ],
}


def get(url, attempts=4):
    for attempt in range(attempts):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=60) as resp:
                return resp.read()
        except Exception as exc:  # noqa: BLE001 - retry on any network error
            if attempt == attempts - 1:
                raise
            print(f"  retry after error: {exc}")
            time.sleep(2 ** (attempt + 1))


def api(endpoint=API, **params):
    params.update(format="json", formatversion="2")
    return json.loads(get(endpoint + "?" + urllib.parse.urlencode(params)))


def lead_image(title):
    pages = api(action="query", prop="pageimages", piprop="name", titles=title, redirects="1")
    pages = pages.get("query", {}).get("pages", [])
    return pages[0].get("pageimage") if pages else None


def strip_html(value):
    return html.unescape(re.sub(r"<[^>]+>", "", value or "")).strip()


def image_info(filename):
    data = api(
        COMMONS_API,
        action="query",
        titles="File:" + filename,
        prop="imageinfo",
        iiprop="url|size|extmetadata",
        iiurlwidth=str(WIDTH),
    )
    pages = data.get("query", {}).get("pages", [])
    if not pages or "imageinfo" not in pages[0]:
        return None
    info = pages[0]["imageinfo"][0]
    meta = info.get("extmetadata", {})
    return {
        "file": filename,
        "download": info.get("thumburl") or info["url"],
        "artist": strip_html(meta.get("Artist", {}).get("value")) or "Unknown",
        "license": strip_html(meta.get("LicenseShortName", {}).get("value")) or "See source",
        "url": info.get("descriptionurl", ""),
    }


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    credits = {}
    failures = []
    for place_id, candidates in PLACES.items():
        print(f"{place_id}:")
        for candidate in candidates:
            filename = lead_image(candidate[5:]) if candidate.startswith("wiki:") else candidate
            if not filename:
                print(f"  no lead image for {candidate}")
                continue
            try:
                info = image_info(filename)
                if not info:
                    print(f"  missing: {filename}")
                    continue
                (OUT_DIR / f"{place_id}.jpg").write_bytes(get(info["download"]))
            except Exception as exc:  # noqa: BLE001
                print(f"  failed {filename}: {exc}")
                continue
            print(f"  ok: {filename} ({info['license']}, {info['artist']})")
            info.pop("download")
            credits[place_id] = info
            break
        else:
            failures.append(place_id)
        time.sleep(0.5)

    (OUT_DIR / "credits.json").write_text(json.dumps(credits, ensure_ascii=False, indent=2) + "\n")
    print(f"Downloaded {len(credits)}/{len(PLACES)} photos")
    if failures:
        print("No photo for: " + ", ".join(failures))
    return 0 if credits else 1


if __name__ == "__main__":
    sys.exit(main())
