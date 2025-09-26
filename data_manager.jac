"""
Data management module for the POS system.
Handles persistence and CRUD operations for all entities.
"""

import:py json, os;
include:jac models;

# Data manager for file-based persistence
object DataManager {
    has data_dir: str,
        products_file: str,
        stock_file: str,
        sales_file: str,
        expenses_file: str;

    can init(data_dir: str = "data") {
        self.data_dir = data_dir;
        self.products_file = os.path.join(data_dir, "products.json");
        self.stock_file = os.path.join(data_dir, "stock.json");
        self.sales_file = os.path.join(data_dir, "sales.json");
        self.expenses_file = os.path.join(data_dir, "expenses.json");
        
        # Create data directory if it doesn't exist
        if not os.path.exists(data_dir) {
            os.makedirs(data_dir);
        }
        
        # Initialize empty files if they don't exist
        self.init_files();
    }

    can init_files {
        for file_path in [self.products_file, self.stock_file, self.sales_file, self.expenses_file] {
            if not os.path.exists(file_path) {
                with open(file_path, 'w') as f {
                    json.dump([], f);
                }
            }
        }
    }

    can load_data(file_path: str) -> list {
        try {
            with open(file_path, 'r') as f {
                return json.load(f);
            }
        } except Exception as e {
            print(f"Error loading data from {file_path}: {e}");
            return [];
        }
    }

    can save_data(file_path: str, data: list) {
        try {
            with open(file_path, 'w') as f {
                json.dump(data, f, indent=2);
            }
        } except Exception as e {
            print(f"Error saving data to {file_path}: {e}");
        }
    }

    # Product management
    can load_products -> list[Product] {
        data = self.load_data(self.products_file);
        return [Product.from_dict(item) for item in data];
    }

    can save_products(products: list[Product]) {
        data = [product.to_dict() for product in products];
        self.save_data(self.products_file, data);
    }

    can add_product(product: Product) -> bool {
        products = self.load_products();
        # Check if product ID already exists
        for existing in products {
            if existing.id == product.id {
                return False;
            }
        }
        products.append(product);
        self.save_products(products);
        return True;
    }

    can update_product(product: Product) -> bool {
        products = self.load_products();
        for i, existing in enumerate(products) {
            if existing.id == product.id {
                products[i] = product;
                self.save_products(products);
                return True;
            }
        }
        return False;
    }

    can get_product(product_id: str) -> Product {
        products = self.load_products();
        for product in products {
            if product.id == product_id {
                return product;
            }
        }
        return None;
    }

    can delete_product(product_id: str) -> bool {
        products = self.load_products();
        for i, product in enumerate(products) {
            if product.id == product_id {
                products.pop(i);
                self.save_products(products);
                return True;
            }
        }
        return False;
    }

    # Stock management
    can load_stock -> list[StockItem] {
        data = self.load_data(self.stock_file);
        return [StockItem.from_dict(item) for item in data];
    }

    can save_stock(stock_items: list[StockItem]) {
        data = [item.to_dict() for item in stock_items];
        self.save_data(self.stock_file, data);
    }

    can get_stock_item(product_id: str) -> StockItem {
        stock_items = self.load_stock();
        for item in stock_items {
            if item.product_id == product_id {
                return item;
            }
        }
        return None;
    }

    can update_stock(product_id: str, quantity: int, reorder_level: int = None) -> bool {
        stock_items = self.load_stock();
        for item in stock_items {
            if item.product_id == product_id {
                item.update_quantity(quantity);
                if reorder_level is not None {
                    item.reorder_level = reorder_level;
                }
                self.save_stock(stock_items);
                return True;
            }
        }
        # Create new stock item if doesn't exist
        new_item = StockItem(product_id, quantity, reorder_level or 10);
        stock_items.append(new_item);
        self.save_stock(stock_items);
        return True;
    }

    can get_low_stock_items -> list[StockItem] {
        stock_items = self.load_stock();
        return [item for item in stock_items if item.needs_reorder()];
    }

    # Sales management
    can load_sales -> list[Sale] {
        data = self.load_data(self.sales_file);
        return [Sale.from_dict(item) for item in data];
    }

    can save_sales(sales: list[Sale]) {
        data = [sale.to_dict() for sale in sales];
        self.save_data(self.sales_file, data);
    }

    can add_sale(sale: Sale) -> bool {
        sales = self.load_sales();
        sales.append(sale);
        self.save_sales(sales);
        
        # Update stock levels
        for item in sale.items {
            current_stock = self.get_stock_item(item["product_id"]);
            if current_stock {
                new_quantity = max(0, current_stock.quantity - item["quantity"]);
                self.update_stock(item["product_id"], new_quantity);
            }
        }
        return True;
    }

    can get_sale(sale_id: str) -> Sale {
        sales = self.load_sales();
        for sale in sales {
            if sale.id == sale_id {
                return sale;
            }
        }
        return None;
    }

    # Expenses management
    can load_expenses -> list[Expense] {
        data = self.load_data(self.expenses_file);
        return [Expense.from_dict(item) for item in data];
    }

    can save_expenses(expenses: list[Expense]) {
        data = [expense.to_dict() for expense in expenses];
        self.save_data(self.expenses_file, data);
    }

    can add_expense(expense: Expense) -> bool {
        expenses = self.load_expenses();
        expenses.append(expense);
        self.save_expenses(expenses);
        return True;
    }

    can get_expense(expense_id: str) -> Expense {
        expenses = self.load_expenses();
        for expense in expenses {
            if expense.id == expense_id {
                return expense;
            }
        }
        return None;
    }
}