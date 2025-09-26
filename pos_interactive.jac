"""
Interactive Point of Sale System CLI in Jaclang.
Command-line interface for the POS system with menu-driven operations.
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
    def __init__(self: POSSystem, data_dir: str = "data") {
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
            print("Error loading data from " + file_path + ": " + str(e));
            return [];
        }
    }

    def save_data(self: POSSystem, file_path: str, data: list) {
        try {
            with open(file_path, 'w') as f {
                json.dump(data, f, indent=2);
            }
        } except Exception as e {
            print("Error saving data to " + file_path + ": " + str(e));
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

    def get_product(self: POSSystem, product_id: str) -> dict {
        products_data = self.load_data(self.products_file);
        for product_data in products_data {
            if product_data["id"] == product_id {
                return product_data;
            }
        }
        return None;
    }

    def list_products(self: POSSystem) -> list {
        return self.load_data(self.products_file);
    }

    def update_stock(self: POSSystem, product_id: str, quantity: int) -> bool {
        stock_data = self.load_data(self.stock_file);
        for stock_item in stock_data {
            if stock_item["product_id"] == product_id {
                stock_item["quantity"] = quantity;
                stock_item["last_updated"] = datetime.datetime.now().isoformat();
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

    def create_sale(self: POSSystem, items: list, payment_method: str) -> str {
        # Validate items and check stock
        validated_items = [];
        for item in items {
            product_id = item["product_id"];
            quantity = item["quantity"];
            
            product_data = self.get_product(product_id);
            if not product_data {
                print("Product " + product_id + " not found");
                return None;
            }
            
            current_stock = self.get_stock_level(product_id);
            if current_stock < quantity {
                print("Insufficient stock for " + product_data['name'] + ". Available: " + str(current_stock));
                return None;
            }
            
            validated_items.append({
                "product_id": product_id,
                "quantity": quantity,
                "unit_price": product_data["price"]
            });
        }

        # Calculate total
        total_amount = 0.0;
        for item in validated_items {
            total_amount += item["quantity"] * item["unit_price"];
        }

        # Create sale
        sale_id = str(uuid.uuid4())[:8];
        sale_data = {
            "id": sale_id,
            "items": validated_items,
            "total_amount": total_amount,
            "payment_method": payment_method,
            "timestamp": datetime.datetime.now().isoformat()
        };
        
        sales_data = self.load_data(self.sales_file);
        sales_data.append(sale_data);
        self.save_data(self.sales_file, sales_data);
        
        # Update stock levels
        for item in validated_items {
            current_stock = self.get_stock_level(item["product_id"]);
            new_stock = current_stock - item["quantity"];
            self.update_stock(item["product_id"], new_stock);
        }
        
        return sale_id;
    }

    def add_expense(self: POSSystem, description: str, amount: float, category: str) -> str {
        expense_id = str(uuid.uuid4())[:8];
        expense_data = {
            "id": expense_id,
            "description": description,
            "amount": amount,
            "category": category,
            "timestamp": datetime.datetime.now().isoformat()
        };
        
        expenses_data = self.load_data(self.expenses_file);
        expenses_data.append(expense_data);
        self.save_data(self.expenses_file, expenses_data);
        
        return expense_id;
    }

    def get_sales_report(self: POSSystem) -> dict {
        sales_data = self.load_data(self.sales_file);
        
        total_sales = len(sales_data);
        total_revenue = 0.0;
        total_cost = 0.0;
        
        for sale_data in sales_data {
            total_revenue += sale_data["total_amount"];
            
            for item in sale_data["items"] {
                product_data = self.get_product(item["product_id"]);
                if product_data {
                    total_cost += product_data["cost"] * item["quantity"];
                }
            }
        }
        
        total_profit = total_revenue - total_cost;
        
        return {
            "total_sales": total_sales,
            "total_revenue": total_revenue,
            "total_cost": total_cost,
            "total_profit": total_profit,
            "average_sale": total_revenue / total_sales if total_sales > 0 else 0
        };
    }

    def get_low_stock_items(self: POSSystem) -> list {
        stock_data = self.load_data(self.stock_file);
        low_stock = [];
        for stock_item in stock_data {
            if stock_item["quantity"] <= stock_item["reorder_level"] {
                product_data = self.get_product(stock_item["product_id"]);
                if product_data {
                    low_stock.append({
                        "product": product_data,
                        "current_stock": stock_item["quantity"],
                        "reorder_level": stock_item["reorder_level"]
                    });
                }
            }
        }
        return low_stock;
    }
}

def display_menu() {
    print("\n🛍️  Small Shop POS System");
    print("=========================");
    print("1. 📦 Add Product");
    print("2. 📋 View Products");
    print("3. 📊 Update Stock");
    print("4. 💰 Process Sale");
    print("5. 💸 Record Expense");
    print("6. 📈 Sales Report");
    print("7. 🔴 Low Stock Alert");
    print("0. 🚪 Exit");
    print("-" * 25);
}

def get_input(prompt: str) -> str {
    return input("➤ " + prompt + ": ").strip();
}

def get_float_input(prompt: str) -> float {
    while True {
        try {
            return float(get_input(prompt));
        } except ValueError {
            print("❌ Please enter a valid number.");
        }
    }
}

def get_int_input(prompt: str) -> int {
    while True {
        try {
            return int(get_input(prompt));
        } except ValueError {
            print("❌ Please enter a valid integer.");
        }
    }
}

def handle_add_product(pos: POSSystem) {
    print("\n➕ Add New Product");
    name = get_input("Product name");
    if not name {
        print("❌ Product name is required.");
        return;
    }

    price = get_float_input("Selling price");
    cost = get_float_input("Cost price");
    category = get_input("Category");

    product_id = pos.add_product(name, price, cost, category);
    print("✅ Product added successfully! ID: " + product_id);
}

def handle_view_products(pos: POSSystem) {
    print("\n📋 All Products:");
    products = pos.list_products();
    
    if not products {
        print("📭 No products found.");
        return;
    }

    print("ID".ljust(10) + " " + "Name".ljust(20) + " " + "Price".ljust(10) + " " + "Cost".ljust(10) + " " + "Category".ljust(15) + " " + "Stock".ljust(8));
    print("-" * 75);
    
    for product in products {
        stock_level = pos.get_stock_level(product["id"]);
        print(product["id"].ljust(10) + " " + product["name"].ljust(20) + " $" + str(product["price"]).ljust(9) + " $" + str(product["cost"]).ljust(9) + " " + product["category"].ljust(15) + " " + str(stock_level).ljust(8));
    }
}

def handle_update_stock(pos: POSSystem) {
    print("\n📦 Update Stock");
    product_id = get_input("Product ID");
    
    product = pos.get_product(product_id);
    if not product {
        print("❌ Product not found.");
        return;
    }

    current_stock = pos.get_stock_level(product_id);
    print("Current stock for '" + product["name"] + "': " + str(current_stock));
    
    new_quantity = get_int_input("New quantity");

    if pos.update_stock(product_id, new_quantity) {
        print("✅ Stock updated successfully!");
    } else {
        print("❌ Failed to update stock.");
    }
}

def handle_process_sale(pos: POSSystem) {
    print("\n💰 Process Sale");
    items = [];
    
    while True {
        product_id = get_input("Product ID (or 'done' to finish)");
        if product_id.lower() == "done" {
            break;
        }
        
        product = pos.get_product(product_id);
        if not product {
            print("❌ Product not found.");
            continue;
        }
        
        current_stock = pos.get_stock_level(product_id);
        print("Product: " + product["name"] + ", Price: $" + str(product["price"]) + ", Available: " + str(current_stock));
        
        quantity = get_int_input("Quantity");
        if quantity <= 0 {
            print("❌ Quantity must be positive.");
            continue;
        }
        
        if quantity > current_stock {
            print("❌ Insufficient stock. Available: " + str(current_stock));
            continue;
        }
        
        items.append({"product_id": product_id, "quantity": quantity});
        print("✅ Added " + str(quantity) + " x " + product["name"]);
    }
    
    if not items {
        print("❌ No items added to sale.");
        return;
    }
    
    # Calculate total
    total = 0.0;
    print("\n🧾 Sale Summary:");
    for item in items {
        product = pos.get_product(item["product_id"]);
        line_total = product["price"] * item["quantity"];
        total += line_total;
        print(str(item["quantity"]) + " x " + product["name"] + " @ $" + str(product["price"]) + " = $" + str(line_total));
    }
    print("Total: $" + str(total));
    
    payment_method = get_input("Payment method (cash/card/other)");
    
    sale_id = pos.create_sale(items, payment_method);
    if sale_id {
        print("✅ Sale completed! Sale ID: " + sale_id);
    } else {
        print("❌ Failed to process sale.");
    }
}

def handle_record_expense(pos: POSSystem) {
    print("\n💸 Record Expense");
    description = get_input("Description");
    if not description {
        print("❌ Description is required.");
        return;
    }
    
    amount = get_float_input("Amount");
    category = get_input("Category");
    
    expense_id = pos.add_expense(description, amount, category);
    print("✅ Expense recorded! ID: " + expense_id);
}

def handle_sales_report(pos: POSSystem) {
    print("\n📊 Sales Report");
    report = pos.get_sales_report();
    
    print("Total Sales: " + str(report["total_sales"]));
    print("Total Revenue: $" + str(report["total_revenue"]));
    print("Total Cost: $" + str(report["total_cost"]));
    print("Total Profit: $" + str(report["total_profit"]));
    print("Average Sale: $" + str(report["average_sale"]));
}

def handle_low_stock_alert(pos: POSSystem) {
    print("\n🔴 Low Stock Alert");
    low_stock_items = pos.get_low_stock_items();
    
    if not low_stock_items {
        print("✅ All products are adequately stocked!");
        return;
    }

    print("Product".ljust(20) + " " + "Current".ljust(10) + " " + "Reorder".ljust(10));
    print("-" * 45);
    
    for item in low_stock_items {
        product = item["product"];
        print(product["name"].ljust(20) + " " + str(item["current_stock"]).ljust(10) + " " + str(item["reorder_level"]).ljust(10));
    }
}

with entry {
    pos = POSSystem("pos_data");
    
    print("🛍️  Welcome to Small Shop POS System!");
    print("=====================================");
    
    while True {
        display_menu();
        choice = get_input("Select option");
        
        if choice == "0" {
            print("👋 Thank you for using Small Shop POS System!");
            break;
        } elif choice == "1" {
            handle_add_product(pos);
        } elif choice == "2" {
            handle_view_products(pos);
        } elif choice == "3" {
            handle_update_stock(pos);
        } elif choice == "4" {
            handle_process_sale(pos);
        } elif choice == "5" {
            handle_record_expense(pos);
        } elif choice == "6" {
            handle_sales_report(pos);
        } elif choice == "7" {
            handle_low_stock_alert(pos);
        } else {
            print("❌ Invalid option. Please try again.");
        }
    }
}