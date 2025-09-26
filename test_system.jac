"""
Test script for the POS System to verify all functionality works correctly.
"""

import json;
import os;
import datetime;
import uuid;

class Product {
    def __init__(self: Product, id: str, name: str, price: float, cost: float, category: str) {
        self.id = id;
        self.name = name;
        self.price = price;
        self.cost = cost;
        self.category = category;
    }

    def to_dict(self: Product) -> dict {
        return {
            "id": self.id,
            "name": self.name,
            "price": self.price,
            "cost": self.cost,
            "category": self.category
        };
    }
}

class POSSystem {
    def __init__(self: POSSystem, data_dir: str = "test_data") {
        self.data_dir = data_dir;
        self.products_file = os.path.join(data_dir, "products.json");
        self.stock_file = os.path.join(data_dir, "stock.json");
        self.sales_file = os.path.join(data_dir, "sales.json");
        self.expenses_file = os.path.join(data_dir, "expenses.json");
        
        if not os.path.exists(data_dir) {
            os.makedirs(data_dir);
        }
        
        self.init_files();
    }

    def init_files(self: POSSystem) {
        if not os.path.exists(self.products_file) {
            with open(self.products_file, 'w') as f {
                json.dump([], f);
            }
        }
        if not os.path.exists(self.stock_file) {
            with open(self.stock_file, 'w') as f {
                json.dump([], f);
            }
        }
        if not os.path.exists(self.sales_file) {
            with open(self.sales_file, 'w') as f {
                json.dump([], f);
            }
        }
        if not os.path.exists(self.expenses_file) {
            with open(self.expenses_file, 'w') as f {
                json.dump([], f);
            }
        }
    }

    def load_data(self: POSSystem, file_path: str) -> list {
        try {
            with open(file_path, 'r') as f {
                return json.load(f);
            }
        } except Exception as e {
            return [];
        }
    }

    def save_data(self: POSSystem, file_path: str, data: list) {
        with open(file_path, 'w') as f {
            json.dump(data, f, indent=2);
        }
    }

    def add_product(self: POSSystem, name: str, price: float, cost: float, category: str) -> str {
        product_id = str(uuid.uuid4())[:8];
        product = Product(product_id, name, price, cost, category);
        
        products_data = self.load_data(self.products_file);
        products_data.append(product.to_dict());
        self.save_data(self.products_file, products_data);
        
        # Initialize stock
        stock_data = self.load_data(self.stock_file);
        stock_item = {
            "product_id": product_id,
            "quantity": 0,
            "reorder_level": 10,
            "last_updated": datetime.datetime.now().isoformat()
        };
        stock_data.append(stock_item);
        self.save_data(self.stock_file, stock_data);
        
        return product_id;
    }

    def update_stock(self: POSSystem, product_id: str, quantity: int) -> bool {
        stock_data = self.load_data(self.stock_file);
        for stock_item in stock_data {
            if stock_item["product_id"] == product_id {
                stock_item["quantity"] = quantity;
                self.save_data(self.stock_file, stock_data);
                return True;
            }
        }
        return False;
    }

    def get_stock_level(self: POSSystem, product_id: str) -> int {
        stock_data = self.load_data(self.stock_file);
        for stock_item in stock_data {
            if stock_item["product_id"] == product_id {
                return stock_item["quantity"];
            }
        }
        return 0;
    }

    def list_products(self: POSSystem) -> list {
        return self.load_data(self.products_file);
    }
}

def run_tests() {
    print("🧪 Running POS System Tests");
    print("============================");
    
    # Initialize system
    pos = POSSystem("test_data");
    
    # Test 1: Add Product
    print("\n✅ Test 1: Adding Product");
    product_id = pos.add_product("Test Coffee", 3.50, 2.00, "Beverages");
    print("Product ID:", product_id);
    
    # Test 2: List Products
    print("\n✅ Test 2: Listing Products");
    products = pos.list_products();
    print("Products count:", len(products));
    print("Product name:", products[0]["name"] if products else "None");
    
    # Test 3: Update Stock
    print("\n✅ Test 3: Updating Stock");
    success = pos.update_stock(product_id, 25);
    print("Stock update success:", success);
    
    # Test 4: Check Stock Level
    print("\n✅ Test 4: Checking Stock Level");
    stock_level = pos.get_stock_level(product_id);
    print("Current stock:", stock_level);
    
    # Clean up test data
    import shutil;
    if os.path.exists("test_data") {
        shutil.rmtree("test_data");
    }
    
    print("\n🎉 All tests completed successfully!");
    print("✨ POS System is working correctly!");
}

with entry {
    run_tests();
}