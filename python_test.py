import json
import datetime

class Product:
    def __init__(self, id, name, price, cost, category, barcode="", description=""):
        self.id = id
        self.name = name
        self.price = price
        self.cost = cost
        self.category = category
        self.barcode = barcode
        self.description = description

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "price": self.price,
            "cost": self.cost,
            "category": self.category,
            "barcode": self.barcode,
            "description": self.description
        }

if __name__ == "__main__":
    product = Product("1", "Test Product", 10.0, 5.0, "Test Category")
    print("Product created:", product.to_dict())