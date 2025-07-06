import pandas as pd
from bs4 import BeautifulSoup
import requests
from pprint import pprint


url = "https://www.flipkart.com/search?q=mobiles&otracker=search&otracker1=search&marketplace=FLIPKART&as-show=on&as=off&page=1"
response = requests.get(url)

soup = BeautifulSoup(response.text, "lxml")
soup = soup.find('div', {'class': 'DOjaWF gdgoEp'})

# print(box)

products = []

# Loop through each product block
for product in soup.find_all("a", class_="CGtC98"):
    try:
        product_name = product.find("div", class_="KzDlHZ").text.strip()
    except:
        product_name = None

    try:
        price = product.find("div", class_="Nx9bqj _4b5DiR").text.strip()
    except:
        price = None

    try:
        rating = product.find("div", class_="XQDdHH").text.strip()
    except:
        rating = None

    try:
        review_text = product.find("span", class_="Wphh3N").text.strip()
        review_count = review_text.split('&')[-1].strip().replace("Reviews", "").strip()
    except:
        review_count = None

    try:
        availability = "in_stock" if "Add to Compare" in product.text else "unknown"
    except:
        availability = None

    try:
        image_url = product.find("img", class_="DByuf4")["src"]
    except:
        image_url = None

    products.append({
        "product_name": product_name,
        "price": price,
        "rating": rating,
        "review_count": review_count,
        "availability": availability,
        "image_url": image_url
    })

# Print sample output
pprint(products)

df = pd.DataFrame(products)
print(df)
df.to_csv("flipkart_mobile.csv", index=False)
print("Saved to CSV: flipkart_mobiles.csv")
