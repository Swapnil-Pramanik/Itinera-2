import httpx
def _fetch_wikimedia_image(topic: str):
    with httpx.Client(timeout=8.0) as client:
        slug = topic.strip().replace(" ", "_")
        resp = client.get(
            "https://en.wikipedia.org/w/api.php",
            params={
                "action": "query",
                "prop": "pageimages",
                "titles": slug,
                "format": "json",
                "pithumbsize": 1000
            },
            headers={"User-Agent": "Itinera-Travel-App/1.0"},
        )
        if resp.status_code == 200:
            data = resp.json()
            pages = data.get("query", {}).get("pages", {})
            for page_id, page_data in pages.items():
                if str(page_id) != "-1":
                    return page_data.get("thumbnail", {}).get("source")
    return None

if __name__ == "__main__":
    print(_fetch_wikimedia_image("Paris"))
