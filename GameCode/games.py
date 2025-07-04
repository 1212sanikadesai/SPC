import os
import requests
from pathlib import Path
from urllib.parse import urlparse

# Constants
API_URL = "https://partner-auth.dev-lab.uk/api/providers/1/games"
BASE_DIR = Path("slots")
HEADERS = {
    "Authorization": "Bearer YOUR_API_TOKEN"  # Replace with actual token if needed
}

def sanitize_filename(name):
    name = str(name)  # Convert int/float/None to string safely
    return "".join(c if c.isalnum() else "_" for c in name)


def download_image(url, path):
    try:
        response = requests.get(url, stream=True, timeout=10)
        response.raise_for_status()
        with open(path, "wb") as f:
            for chunk in response.iter_content(8192):
                f.write(chunk)
        print(f"Downloaded: {path}")
    except Exception as e:
        print(f"Failed to download {url}: {e}")

def fetch_games():
    response = requests.get(API_URL, headers=HEADERS)
    response.raise_for_status()
    return response.json()

def main():
    games = fetch_games()

    for game in games:
        name = sanitize_filename(game.get("name", "unknown"))
        game_code = sanitize_filename(game.get("game_code", "code"))
        category = sanitize_filename(game.get("category", "misc"))

        filename = f"{name}_{game_code}.jpg"

        # Square image
        image_square_url = game.get("image_square")
        if image_square_url:
            square_path = BASE_DIR / "square" / category
            square_path.mkdir(parents=True, exist_ok=True)
            image_path = square_path / filename
            download_image(image_square_url, image_path)

        # Optional: Round image (if API includes it)
        image_round_url = game.get("image_round")
        if image_round_url:
            round_path = BASE_DIR / "round" / category
            round_path.mkdir(parents=True, exist_ok=True)
            image_path = round_path / filename
            download_image(image_round_url, image_path)

if __name__ == "__main__":
    main()
