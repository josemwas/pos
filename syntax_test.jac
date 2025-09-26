import:py json, datetime;

node Product {
    has id: str;
    has name: str;
    has price: float;
    has cost: float;
    has category: str;
    has barcode: str;
    has description: str;

    can init(id: str, name: str, price: float, cost: float, category: str, 
             barcode: str = "", description: str = "") {
        self.id = id;
        self.name = name;
        self.price = price;
        self.cost = cost;
        self.category = category;
        self.barcode = barcode;
        self.description = description;
    }

    can to_dict -> dict {
        return {
            "id": self.id,
            "name": self.name,
            "price": self.price,
            "cost": self.cost,
            "category": self.category,
            "barcode": self.barcode,
            "description": self.description
        };
    }
}

with entry {
    product = Product("1", "Test Product", 10.0, 5.0, "Test Category");
    print("Product created:", product.to_dict());
}