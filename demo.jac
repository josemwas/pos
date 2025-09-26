"""
Demo script for the POS System.
Shows basic usage and populates with sample data.
"""

include:jac pos_system;

# Demo function to populate sample data
can populate_sample_data(pos: POSSystem) {
    print("🌱 Populating sample data...");
    
    # Add sample products
    products_data = [
        {"name": "Coca Cola 500ml", "price": 2.50, "cost": 1.50, "category": "Beverages"},
        {"name": "White Bread", "price": 3.00, "cost": 2.00, "category": "Bakery"},
        {"name": "Milk 1L", "price": 4.50, "cost": 3.00, "category": "Dairy"},
        {"name": "Bananas (per kg)", "price": 2.00, "cost": 1.20, "category": "Fruits"},
        {"name": "Potato Chips", "price": 1.75, "cost": 1.00, "category": "Snacks"},
        {"name": "Chocolate Bar", "price": 2.25, "cost": 1.30, "category": "Snacks"},
        {"name": "Orange Juice 1L", "price": 5.00, "cost": 3.50, "category": "Beverages"},
        {"name": "Apples (per kg)", "price": 3.50, "cost": 2.00, "category": "Fruits"}
    ];
    
    product_ids = [];
    for product_data in products_data {
        product_id = pos.add_product(
            product_data["name"], 
            product_data["price"], 
            product_data["cost"], 
            product_data["category"]
        );
        if product_id {
            product_ids.append(product_id);
            print(f"  ✅ Added: {product_data['name']} (ID: {product_id})");
        }
    }
    
    # Add stock for products
    stock_levels = [50, 30, 25, 40, 60, 35, 20, 45];
    for i, product_id in enumerate(product_ids) {
        pos.update_stock(product_id, stock_levels[i], 10);
    }
    
    # Create some sample sales
    print("\n💰 Creating sample sales...");
    
    # Sale 1: Morning customer
    sale_items_1 = [
        {"product_id": product_ids[0], "quantity": 2},  # 2 Coca Cola
        {"product_id": product_ids[1], "quantity": 1},  # 1 Bread
        {"product_id": product_ids[2], "quantity": 1}   # 1 Milk
    ];
    sale_id_1 = pos.create_sale(sale_items_1, "cash", "John Smith");
    if sale_id_1 {
        print(f"  ✅ Sale 1 created (ID: {sale_id_1})");
    }
    
    # Sale 2: Afternoon customer
    sale_items_2 = [
        {"product_id": product_ids[3], "quantity": 2},  # 2kg Bananas
        {"product_id": product_ids[4], "quantity": 3},  # 3 Chips
        {"product_id": product_ids[5], "quantity": 1}   # 1 Chocolate
    ];
    sale_id_2 = pos.create_sale(sale_items_2, "card");
    if sale_id_2 {
        print(f"  ✅ Sale 2 created (ID: {sale_id_2})");
    }
    
    # Add sample expenses
    print("\n💸 Adding sample expenses...");
    
    expenses_data = [
        {"description": "Electricity Bill", "amount": 125.50, "category": "Utilities"},
        {"description": "Product Restocking", "amount": 500.00, "category": "Inventory"},
        {"description": "Cleaning Supplies", "amount": 35.75, "category": "Maintenance"},
        {"description": "Internet Bill", "amount": 45.00, "category": "Utilities"}
    ];
    
    for expense_data in expenses_data {
        expense_id = pos.add_expense(
            expense_data["description"],
            expense_data["amount"],
            expense_data["category"]
        );
        if expense_id {
            print(f"  ✅ Expense added: {expense_data['description']} (ID: {expense_id})");
        }
    }
    
    print("\n🎉 Sample data populated successfully!");
}

# Demo function to show reports
can show_demo_reports(pos: POSSystem) {
    print("\n" + "="*50);
    print("📊 DEMO REPORTS");
    print("="*50);
    
    # Dashboard
    print("\n🏠 Dashboard Summary:");
    summary = pos.get_dashboard_summary();
    print(f"  📦 Total Products: {summary['total_products']}");
    print(f"  💰 Total Sales: {summary['total_sales']}");
    print(f"  📅 Today's Sales: {summary['today_sales_count']}");
    print(f"  💵 Today's Revenue: ${summary['today_revenue']:.2f}");
    print(f"  💸 This Month's Expenses: ${summary['month_expenses']:.2f}");
    print(f"  🔴 Low Stock Items: {summary['low_stock_count']}");
    
    # Sales Report
    print("\n📊 Sales Report:");
    sales_report = pos.get_sales_report();
    print(f"  Total Sales: {sales_report['total_sales']}");
    print(f"  Total Revenue: ${sales_report['total_revenue']:.2f}");
    print(f"  Total Cost: ${sales_report['total_cost']:.2f}");
    print(f"  Total Profit: ${sales_report['total_profit']:.2f}");
    print(f"  Average Sale: ${sales_report['average_sale']:.2f}");
    
    # Expenses Report
    print("\n💸 Expenses Report:");
    expenses_report = pos.get_expenses_report();
    print(f"  Total Expenses: ${expenses_report['total_expenses']:.2f}");
    print(f"  Number of Expenses: {expenses_report['expense_count']}");
    
    if expenses_report["expenses_by_category"] {
        print("  Expenses by Category:");
        for category, amount in expenses_report["expenses_by_category"].items() {
            print(f"    {category}: ${amount:.2f}");
        }
    }
    
    # Low Stock Report
    print("\n🔴 Low Stock Report:");
    low_stock_report = pos.get_low_stock_report();
    if low_stock_report {
        for item in low_stock_report {
            product = item["product"];
            print(f"  {product['name']}: {item['current_stock']} (reorder at {item['reorder_level']})");
        }
    } else {
        print("  ✅ All products are adequately stocked!");
    }
    
    # Product List
    print("\n📦 All Products:");
    products = pos.list_products();
    print(f"  {'Name':<20} {'Price':<8} {'Cost':<8} {'Category':<12} {'Stock':<6}");
    print(f"  {'-'*20} {'-'*8} {'-'*8} {'-'*12} {'-'*6}");
    for product in products {
        stock_level = pos.get_stock_level(product.id);
        print(f"  {product.name:<20} ${product.price:<7.2f} ${product.cost:<7.2f} {product.category:<12} {stock_level:<6}");
    }
}

# Main demo execution
with entry {
    print("🛍️  Small Shop POS System - Demo");
    print("=================================");
    
    # Initialize POS system
    pos = POSSystem("demo_data");
    
    # Check if we already have data
    products = pos.list_products();
    if not products {
        # Populate sample data if empty
        populate_sample_data(pos);
    } else {
        print("📂 Using existing data...");
    }
    
    # Show demo reports
    show_demo_reports(pos);
    
    print("\n" + "="*50);
    print("✨ Demo completed!");
    print("💡 Run 'jac cli.jac' to use the interactive interface");
    print("📁 Data stored in 'demo_data' directory");
    print("="*50);
}