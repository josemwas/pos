import:py from json;
import:py from datetime;

node Product {
    has id: str;
    has name: str;
    has price: float;

    can init(id: str, name: str, price: float) {
        self.id = id;
        self.name = name;
        self.price = price;
    }
}

with entry {
    product = Product("1", "Test Product", 10.0);
    print("Product created:", product.name);
}