"""
Command Line Interface for the POS System.
Provides an interactive menu-driven interface for all POS operations.
"""

import:py datetime;
include:jac pos_system;

# CLI Interface
object POSCLI {
    has pos_system: POSSystem;

    can init(data_dir: str = "data") {
        self.pos_system = POSSystem(data_dir);
        print("🛍️  Welcome to Small Shop POS System");
        print("=====================================");
    }

    can display_menu {
        print("\n📋 Main Menu:");
        print("1. 📦 Product Management");
        print("2. 📊 Inventory Management");
        print("3. 💰 Process Sale");
        print("4. 💸 Record Expense");
        print("5. 📈 Reports");
        print("6. 🏠 Dashboard");
        print("0. 🚪 Exit");
        print("-" * 30);
    }

    can display_product_menu {
        print("\n📦 Product Management:");
        print("1. Add Product");
        print("2. View All Products");
        print("3. Update Product");
        print("4. Delete Product");
        print("0. Back to Main Menu");
    }

    can display_inventory_menu {
        print("\n📊 Inventory Management:");
        print("1. Update Stock");
        print("2. View Stock Status");
        print("3. Low Stock Report");
        print("0. Back to Main Menu");
    }

    can display_reports_menu {
        print("\n📈 Reports:");
        print("1. Sales Report");
        print("2. Expenses Report");
        print("3. Profit Analysis");
        print("0. Back to Main Menu");
    }

    # Utility methods
    can get_input(prompt: str) -> str {
        return input(f"➤ {prompt}: ").strip();
    }

    can get_float_input(prompt: str) -> float {
        while True {
            try {
                return float(self.get_input(prompt));
            } except ValueError {
                print("❌ Please enter a valid number.");
            }
        }
    }

    can get_int_input(prompt: str) -> int {
        while True {
            try {
                return int(self.get_input(prompt));
            } except ValueError {
                print("❌ Please enter a valid integer.");
            }
        }
    }

    # Product management methods
    can handle_add_product {
        print("\n➕ Add New Product");
        name = self.get_input("Product name");
        if not name {
            print("❌ Product name is required.");
            return;
        }

        price = self.get_float_input("Selling price");
        cost = self.get_float_input("Cost price");
        category = self.get_input("Category");
        barcode = self.get_input("Barcode (optional)");
        description = self.get_input("Description (optional)");

        product_id = self.pos_system.add_product(name, price, cost, category, barcode, description);
        if product_id {
            print(f"✅ Product added successfully! ID: {product_id}");
        } else {
            print("❌ Failed to add product.");
        }
    }

    can handle_view_products {
        print("\n📋 All Products:");
        products = self.pos_system.list_products();
        
        if not products {
            print("📭 No products found.");
            return;
        }

        print(f"{'ID':<10} {'Name':<20} {'Price':<10} {'Cost':<10} {'Category':<15} {'Stock':<8}");
        print("-" * 75);
        
        for product in products {
            stock_level = self.pos_system.get_stock_level(product.id);
            print(f"{product.id:<10} {product.name:<20} ${product.price:<9.2f} ${product.cost:<9.2f} {product.category:<15} {stock_level:<8}");
        }
    }

    can handle_update_product {
        print("\n✏️  Update Product");
        product_id = self.get_input("Product ID");
        
        product = self.pos_system.get_product(product_id);
        if not product {
            print("❌ Product not found.");
            return;
        }

        print(f"Current product: {product.name}");
        print("Leave blank to keep current value:");
        
        name = self.get_input(f"Name [{product.name}]") or None;
        price_str = self.get_input(f"Price [{product.price}]");
        price = float(price_str) if price_str else None;
        cost_str = self.get_input(f"Cost [{product.cost}]");
        cost = float(cost_str) if cost_str else None;
        category = self.get_input(f"Category [{product.category}]") or None;

        if self.pos_system.update_product(product_id, name, price, cost, category) {
            print("✅ Product updated successfully!");
        } else {
            print("❌ Failed to update product.");
        }
    }

    can handle_delete_product {
        print("\n🗑️  Delete Product");
        product_id = self.get_input("Product ID");
        
        product = self.pos_system.get_product(product_id);
        if not product {
            print("❌ Product not found.");
            return;
        }

        confirm = self.get_input(f"Delete '{product.name}'? (yes/no)");
        if confirm.lower() == "yes" {
            if self.pos_system.delete_product(product_id) {
                print("✅ Product deleted successfully!");
            } else {
                print("❌ Failed to delete product.");
            }
        } else {
            print("❌ Deletion cancelled.");
        }
    }

    # Inventory management methods
    can handle_update_stock {
        print("\n📦 Update Stock");
        product_id = self.get_input("Product ID");
        
        product = self.pos_system.get_product(product_id);
        if not product {
            print("❌ Product not found.");
            return;
        }

        current_stock = self.pos_system.get_stock_level(product_id);
        print(f"Current stock for '{product.name}': {current_stock}");
        
        new_quantity = self.get_int_input("New quantity");
        reorder_level_str = self.get_input("Reorder level (optional, current will be kept if blank)");
        reorder_level = int(reorder_level_str) if reorder_level_str else None;

        if self.pos_system.update_stock(product_id, new_quantity, reorder_level) {
            print("✅ Stock updated successfully!");
        } else {
            print("❌ Failed to update stock.");
        }
    }

    can handle_view_stock {
        print("\n📊 Stock Status:");
        products = self.pos_system.list_products();
        
        if not products {
            print("📭 No products found.");
            return;
        }

        print(f"{'Product':<20} {'Current':<10} {'Reorder':<10} {'Status':<15}");
        print("-" * 60);
        
        for product in products {
            stock_info = self.pos_system.get_stock_info(product.id);
            if stock_info {
                status = "🔴 LOW STOCK" if stock_info["needs_reorder"] else "✅ OK";
                print(f"{product.name:<20} {stock_info['quantity']:<10} {stock_info['reorder_level']:<10} {status:<15}");
            }
        }
    }

    can handle_low_stock_report {
        print("\n🔴 Low Stock Report:");
        low_stock_report = self.pos_system.get_low_stock_report();
        
        if not low_stock_report {
            print("✅ All products are adequately stocked!");
            return;
        }

        print(f"{'Product':<20} {'Current':<10} {'Reorder':<10} {'Suggested':<12}");
        print("-" * 60);
        
        for item in low_stock_report {
            product = item["product"];
            print(f"{product['name']:<20} {item['current_stock']:<10} {item['reorder_level']:<10} {item['suggested_order']:<12}");
        }
    }

    # Sales processing
    can handle_process_sale {
        print("\n💰 Process Sale");
        items = [];
        
        while True {
            product_id = self.get_input("Product ID (or 'done' to finish)");
            if product_id.lower() == "done" {
                break;
            }
            
            product = self.pos_system.get_product(product_id);
            if not product {
                print("❌ Product not found.");
                continue;
            }
            
            current_stock = self.pos_system.get_stock_level(product_id);
            print(f"Product: {product.name}, Price: ${product.price}, Available: {current_stock}");
            
            quantity = self.get_int_input("Quantity");
            if quantity <= 0 {
                print("❌ Quantity must be positive.");
                continue;
            }
            
            if quantity > current_stock {
                print(f"❌ Insufficient stock. Available: {current_stock}");
                continue;
            }
            
            items.append({"product_id": product_id, "quantity": quantity});
            print(f"✅ Added {quantity} x {product.name}");
        }
        
        if not items {
            print("❌ No items added to sale.");
            return;
        }
        
        # Calculate total
        total = 0.0;
        print("\n🧾 Sale Summary:");
        for item in items {
            product = self.pos_system.get_product(item["product_id"]);
            line_total = product.price * item["quantity"];
            total += line_total;
            print(f"{item['quantity']} x {product.name} @ ${product.price} = ${line_total:.2f}");
        }
        print(f"Total: ${total:.2f}");
        
        payment_method = self.get_input("Payment method (cash/card/other)");
        customer_name = self.get_input("Customer name (optional)");
        
        sale_id = self.pos_system.create_sale(items, payment_method, customer_name);
        if sale_id {
            print(f"✅ Sale completed! Sale ID: {sale_id}");
        } else {
            print("❌ Failed to process sale.");
        }
    }

    # Expense recording
    can handle_record_expense {
        print("\n💸 Record Expense");
        description = self.get_input("Description");
        if not description {
            print("❌ Description is required.");
            return;
        }
        
        amount = self.get_float_input("Amount");
        category = self.get_input("Category");
        receipt_number = self.get_input("Receipt number (optional)");
        
        expense_id = self.pos_system.add_expense(description, amount, category, receipt_number);
        if expense_id {
            print(f"✅ Expense recorded! ID: {expense_id}");
        } else {
            print("❌ Failed to record expense.");
        }
    }

    # Reports
    can handle_sales_report {
        print("\n📊 Sales Report");
        start_date = self.get_input("Start date (YYYY-MM-DD, optional)");
        end_date = self.get_input("End date (YYYY-MM-DD, optional)");
        
        report = self.pos_system.get_sales_report(start_date or None, end_date or None);
        
        print(f"\n📈 Sales Summary:");
        print(f"Total Sales: {report['total_sales']}");
        print(f"Total Revenue: ${report['total_revenue']:.2f}");
        print(f"Total Cost: ${report['total_cost']:.2f}");
        print(f"Total Profit: ${report['total_profit']:.2f}");
        print(f"Average Sale: ${report['average_sale']:.2f}");
    }

    can handle_expenses_report {
        print("\n💸 Expenses Report");
        start_date = self.get_input("Start date (YYYY-MM-DD, optional)");
        end_date = self.get_input("End date (YYYY-MM-DD, optional)");
        
        report = self.pos_system.get_expenses_report(start_date or None, end_date or None);
        
        print(f"\n💰 Expenses Summary:");
        print(f"Total Expenses: ${report['total_expenses']:.2f}");
        print(f"Number of Expenses: {report['expense_count']}");
        
        if report["expenses_by_category"] {
            print("\nExpenses by Category:");
            for category, amount in report["expenses_by_category"].items() {
                print(f"  {category}: ${amount:.2f}");
            }
        }
    }

    can handle_dashboard {
        print("\n🏠 Dashboard");
        summary = self.pos_system.get_dashboard_summary();
        
        print(f"📦 Total Products: {summary['total_products']}");
        print(f"💰 Total Sales: {summary['total_sales']}");
        print(f"📅 Today's Sales: {summary['today_sales_count']}");
        print(f"💵 Today's Revenue: ${summary['today_revenue']:.2f}");
        print(f"💸 This Month's Expenses: ${summary['month_expenses']:.2f}");
        print(f"🔴 Low Stock Items: {summary['low_stock_count']}");
        
        if summary["low_stock_items"] {
            print("Low stock products:", ", ".join(summary["low_stock_items"]));
        }
    }

    # Main run method
    can run {
        while True {
            self.display_menu();
            choice = self.get_input("Select option");
            
            if choice == "0" {
                print("👋 Thank you for using Small Shop POS System!");
                break;
            } elif choice == "1" {
                self.handle_product_management();
            } elif choice == "2" {
                self.handle_inventory_management();
            } elif choice == "3" {
                self.handle_process_sale();
            } elif choice == "4" {
                self.handle_record_expense();
            } elif choice == "5" {
                self.handle_reports();
            } elif choice == "6" {
                self.handle_dashboard();
            } else {
                print("❌ Invalid option. Please try again.");
            }
        }
    }

    can handle_product_management {
        while True {
            self.display_product_menu();
            choice = self.get_input("Select option");
            
            if choice == "0" {
                break;
            } elif choice == "1" {
                self.handle_add_product();
            } elif choice == "2" {
                self.handle_view_products();
            } elif choice == "3" {
                self.handle_update_product();
            } elif choice == "4" {
                self.handle_delete_product();
            } else {
                print("❌ Invalid option. Please try again.");
            }
        }
    }

    can handle_inventory_management {
        while True {
            self.display_inventory_menu();
            choice = self.get_input("Select option");
            
            if choice == "0" {
                break;
            } elif choice == "1" {
                self.handle_update_stock();
            } elif choice == "2" {
                self.handle_view_stock();
            } elif choice == "3" {
                self.handle_low_stock_report();
            } else {
                print("❌ Invalid option. Please try again.");
            }
        }
    }

    can handle_reports {
        while True {
            self.display_reports_menu();
            choice = self.get_input("Select option");
            
            if choice == "0" {
                break;
            } elif choice == "1" {
                self.handle_sales_report();
            } elif choice == "2" {
                self.handle_expenses_report();
            } elif choice == "3" {
                print("📊 Profit Analysis");
                self.handle_sales_report();  # Shows profit in sales report
            } else {
                print("❌ Invalid option. Please try again.");
            }
        }
    }
}

# Main entry point
with entry {
    cli = POSCLI();
    cli.run();
}