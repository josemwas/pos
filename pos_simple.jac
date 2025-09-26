"""
Simple Point of Sale System in Jaclang.
A complete POS system for small shops to track sales, expenses, and stock.
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

class StockItem {
    def __init__(self: StockItem, product_id: str, quantity: int, reorder_level: int = 10) {
        self.product_id = product_id;
        self.quantity = quantity;
        self.reorder_level = reorder_level;
        self.last_updated = datetime.datetime.now().isoformat();
    }

    def needs_reorder(self: StockItem) -> bool {
        return self.quantity <= self.reorder_level;
    }

    def to_dict(self: StockItem) -> dict {
        return {
            "product_id": self.product_id,
            "quantity": self.quantity,
            "reorder_level": self.reorder_level,
            "last_updated": self.last_updated
        };
    }
}

class Sale {
    def __init__(self: Sale, id: str, items: list, payment_method: str) {
        self.id = id;
        self.items = items;
        self.payment_method = payment_method;
        self.timestamp = datetime.datetime.now().isoformat();
        self.total_amount = self.calculate_total();
    }

    def calculate_total(self: Sale) -> float {
        total = 0.0;
        for item in self.items {
            total += item["quantity"] * item["unit_price"];
        }
        return total;
    }

    def to_dict(self: Sale) -> dict {
        return {
            "id": self.id,
            "items": self.items,
            "total_amount": self.total_amount,
            "payment_method": self.payment_method,
            "timestamp": self.timestamp
        };
    }
}

class Expense {
    def __init__(self: Expense, id: str, description: str, amount: float, category: str) {
        self.id = id;
        self.description = description;
        self.amount = amount;
        self.category = category;
        self.timestamp = datetime.datetime.now().isoformat();
    }

    def to_dict(self: Expense) -> dict {
        return {
            "id": self.id,
            "description": self.description,
            "amount": self.amount,
            "category": self.category,
            "timestamp": self.timestamp
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
        stock_item = StockItem(product_id, 0, 10);
        stock_data.append(stock_item.to_dict());
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

        # Create sale
        sale_id = str(uuid.uuid4())[:8];
        sale = Sale(sale_id, validated_items, payment_method);
        
        sales_data = self.load_data(self.sales_file);
        sales_data.append(sale.to_dict());
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
        expense = Expense(expense_id, description, amount, category);
        
        expenses_data = self.load_data(self.expenses_file);
        expenses_data.append(expense.to_dict());
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

    def get_expenses_report(self: POSSystem) -> dict {
        expenses_data = self.load_data(self.expenses_file);
        
        total_expenses = 0.0;
        expenses_by_category = {};
        
        for expense_data in expenses_data {
            total_expenses += expense_data["amount"];
            category = expense_data["category"];
            if category not in expenses_by_category {
                expenses_by_category[category] = 0.0;
            }
            expenses_by_category[category] += expense_data["amount"];
        }
        
        return {
            "total_expenses": total_expenses,
            "expenses_by_category": expenses_by_category,
            "expense_count": len(expenses_data)
        };
    }

    def get_dashboard_summary(self: POSSystem) -> dict {
        products_data = self.load_data(self.products_file);
        sales_data = self.load_data(self.sales_file);
        expenses_data = self.load_data(self.expenses_file);
        low_stock_items = self.get_low_stock_items();

        # Today's sales
        today = datetime.datetime.now().date().isoformat();
        today_sales = [];
        today_revenue = 0.0;
        
        for sale_data in sales_data {
            sale_date = datetime.datetime.fromisoformat(sale_data["timestamp"]).date().isoformat();
            if sale_date == today {
                today_sales.append(sale_data);
                today_revenue += sale_data["total_amount"];
            }
        }

        return {
            "total_products": len(products_data),
            "total_sales": len(sales_data),
            "today_sales_count": len(today_sales),
            "today_revenue": today_revenue,
            "low_stock_count": len(low_stock_items)
        };
    }
}

def populate_sample_data(pos: POSSystem) {
    print("🌱 Populating sample data...");
    
    # Add sample products
    products_info = [
        ["Coca Cola 500ml", 2.50, 1.50, "Beverages"],
        ["White Bread", 3.00, 2.00, "Bakery"],
        ["Milk 1L", 4.50, 3.00, "Dairy"],
        ["Bananas (per kg)", 2.00, 1.20, "Fruits"],
        ["Potato Chips", 1.75, 1.00, "Snacks"]
    ];
    
    product_ids = [];
    for product_info in products_info {
        product_id = pos.add_product(product_info[0], product_info[1], product_info[2], product_info[3]);
        product_ids.append(product_id);
        print("  ✅ Added: " + product_info[0] + " (ID: " + product_id + ")");
    }
    
    # Add stock for products
    stock_levels = [50, 30, 25, 40, 60];
    for i in range(len(product_ids)) {
        pos.update_stock(product_ids[i], stock_levels[i]);
    }
    
    # Create sample sales
    print("\n💰 Creating sample sales...");
    sale_items = [
        {"product_id": product_ids[0], "quantity": 2},
        {"product_id": product_ids[1], "quantity": 1}
    ];
    sale_id = pos.create_sale(sale_items, "cash");
    if sale_id {
        print("  ✅ Sale created (ID: " + sale_id + ")");
    }
    
    # Add sample expenses
    print("\n💸 Adding sample expenses...");
    expense_id = pos.add_expense("Electricity Bill", 125.50, "Utilities");
    if expense_id {
        print("  ✅ Expense added (ID: " + expense_id + ")");
    }
    
    print("\n🎉 Sample data populated successfully!");
}

def show_reports(pos: POSSystem) {
    print("\n" + "="*50);
    print("📊 POS SYSTEM REPORTS");
    print("="*50);
    
    # Dashboard
    print("\n🏠 Dashboard Summary:");
    summary = pos.get_dashboard_summary();
    print("  📦 Total Products:", summary['total_products']);
    print("  💰 Total Sales:", summary['total_sales']);
    print("  📅 Today's Sales:", summary['today_sales_count']);
    print("  💵 Today's Revenue: $", summary['today_revenue']);
    print("  🔴 Low Stock Items:", summary['low_stock_count']);
    
    # Sales Report
    print("\n📊 Sales Report:");
    sales_report = pos.get_sales_report();
    print("  Total Sales:", sales_report['total_sales']);
    print("  Total Revenue: $", sales_report['total_revenue']);
    print("  Total Cost: $", sales_report['total_cost']);
    print("  Total Profit: $", sales_report['total_profit']);
    print("  Average Sale: $", sales_report['average_sale']);
    
    # Expenses Report
    print("\n💸 Expenses Report:");
    expenses_report = pos.get_expenses_report();
    print("  Total Expenses: $", expenses_report['total_expenses']);
    print("  Number of Expenses:", expenses_report['expense_count']);
    
    if expenses_report["expenses_by_category"] {
        print("  Expenses by Category:");
        for category in expenses_report["expenses_by_category"] {
            amount = expenses_report["expenses_by_category"][category];
            print("    " + category + ": $" + str(amount));
        }
    }
    
    # Low Stock Report
    print("\n🔴 Low Stock Report:");
    low_stock_items = pos.get_low_stock_items();
    if low_stock_items {
        for item in low_stock_items {
            product = item["product"];
            print("  " + product['name'] + ": " + str(item['current_stock']) + " (reorder at " + str(item['reorder_level']) + ")");
        }
    } else {
        print("  ✅ All products are adequately stocked!");
    }
    
    # Product List
    print("\n📦 All Products:");
    products = pos.list_products();
    print("  " + "Name".ljust(20) + " " + "Price".ljust(8) + " " + "Cost".ljust(8) + " " + "Category".ljust(12) + " " + "Stock".ljust(6));
    print("  " + "-" * 20 + " " + "-" * 8 + " " + "-" * 8 + " " + "-" * 12 + " " + "-" * 6);
    for product in products {
        stock_level = pos.get_stock_level(product["id"]);
        print("  " + product['name'].ljust(20) + " $" + str(product['price']).ljust(7) + " $" + str(product['cost']).ljust(7) + " " + product['category'].ljust(12) + " " + str(stock_level).ljust(6));
    }
}

with entry {
    print("🛍️  Small Shop POS System");
    print("=========================");
    
    pos = POSSystem("pos_data");
    
    # Check if we have existing data
    products = pos.list_products();
    if not products {
        populate_sample_data(pos);
    } else {
        print("📂 Using existing data...");
    }
    
    show_reports(pos);
    
    print("\n" + "="*50);
    print("✨ POS System Demo completed!");
    print("📁 Data stored in 'pos_data' directory");
    print("="*50);
}