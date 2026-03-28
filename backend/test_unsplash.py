import sys
from dotenv import load_dotenv
load_dotenv()
from api.destinations import _fetch_unsplash_image

if __name__ == "__main__":
    result = _fetch_unsplash_image("Bali")
    print(f"Result URL: {result}")
