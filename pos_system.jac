"""
Main POS System class that coordinates all operations.
Provides high-level interface for the point of sale system.
"""

import:py uuid, datetime;
include:jac models, data_manager;

# Main POS System
object POSSystem {
    has data_manager: DataManager;

    can init(data_dir: str = "data") {
        self.data_manager = DataManager(data_dir);
    }

    # Product management methods
    can add_product(name: str, price: float, cost: float, category: str, 
                   barcode: str = "", description: str = "") -> str {
        product_id = str(uuid.uuid4())[:8];
        product = Product(product_id, name, price, cost, category, barcode, description);
        
        if self.data_manager.add_product(product) {
            # Initialize stock for the new product
            self.data_manager.update_stock(product_id, 0, 10);
            return product_id;
        }
        return None;
    }

    can update_product(product_id: str, name: str = None, price: float = None, 
                      cost: float = None, category: str = None, 
                      barcode: str = None, description: str = None) -> bool {
        product = self.data_manager.get_product(product_id);
        if not product {
            return False;
        }

        # Update only provided fields
        if name is not None { product.name = name; }
        if price is not None { product.price = price; }
        if cost is not None { product.cost = cost; }
        if category is not None { product.category = category; }
        if barcode is not None { product.barcode = barcode; }
        if description is not None { product.description = description; }

        return self.data_manager.update_product(product);
    }

    can get_product(product_id: str) -> Product {
        return self.data_manager.get_product(product_id);
    }

    can list_products -> list[Product] {
        return self.data_manager.load_products();
    }

    can delete_product(product_id: str) -> bool {
        return self.data_manager.delete_product(product_id);
    }

    # Inventory management methods
    can update_stock(product_id: str, quantity: int, reorder_level: int = None) -> bool {
        # Verify product exists
        if not self.data_manager.get_product(product_id) {
            return False;
        }
        return self.data_manager.update_stock(product_id, quantity, reorder_level);
    }

    can get_stock_level(product_id: str) -> int {
        stock_item = self.data_manager.get_stock_item(product_id);
        return stock_item.quantity if stock_item else 0;
    }

    can get_stock_info(product_id: str) -> dict {
        stock_item = self.data_manager.get_stock_item(product_id);
        product = self.data_manager.get_product(product_id);
        
        if not stock_item or not product {
            return None;
        }

        return {
            "product": product.to_dict(),
            "quantity": stock_item.quantity,
            "reorder_level": stock_item.reorder_level,
            "needs_reorder": stock_item.needs_reorder(),
            "last_updated": stock_item.last_updated
        };
    }

    can get_low_stock_report -> list[dict] {
        low_stock_items = self.data_manager.get_low_stock_items();
        report = [];
        
        for stock_item in low_stock_items {
            product = self.data_manager.get_product(stock_item.product_id);
            if product {
                report.append({
                    "product": product.to_dict(),
                    "current_stock": stock_item.quantity,
                    "reorder_level": stock_item.reorder_level,
                    "suggested_order": stock_item.reorder_level * 2
                });
            }
        }
        return report;
    }

    # Sales processing methods
    can create_sale(items: list, payment_method: str, customer_name: str = "") -> str {
        # Validate items and check stock
        validated_items = [];
        for item in items {
            product_id = item["product_id"];
            quantity = item["quantity"];
            
            product = self.data_manager.get_product(product_id);
            if not product {
                print(f"Product {product_id} not found");
                return None;
            }
            
            stock_item = self.data_manager.get_stock_item(product_id);
            if not stock_item or stock_item.quantity < quantity {
                print(f"Insufficient stock for {product.name}. Available: {stock_item.quantity if stock_item else 0}");
                return None;
            }
            
            validated_items.append({
                "product_id": product_id,
                "quantity": quantity,
                "unit_price": product.price
            });
        }

        # Create sale
        sale_id = str(uuid.uuid4())[:8];
        sale = Sale(sale_id, validated_items, payment_method, customer_name);
        
        if self.data_manager.add_sale(sale) {
            return sale_id;
        }
        return None;
    }

    can get_sale(sale_id: str) -> Sale {
        return self.data_manager.get_sale(sale_id);
    }

    can get_sales_report(start_date: str = None, end_date: str = None) -> dict {
        sales = self.data_manager.load_sales();
        
        # Filter by date range if provided
        if start_date or end_date {
            filtered_sales = [];
            for sale in sales {
                sale_date = datetime.datetime.fromisoformat(sale.timestamp).date();
                if start_date and sale_date < datetime.datetime.fromisoformat(start_date).date() {
                    continue;
                }
                if end_date and sale_date > datetime.datetime.fromisoformat(end_date).date() {
                    continue;
                }
                filtered_sales.append(sale);
            }
            sales = filtered_sales;
        }

        # Calculate totals
        total_sales = len(sales);
        total_revenue = sum(sale.total_amount for sale in sales);
        
        # Calculate profit (requires cost information)
        total_cost = 0.0;
        for sale in sales {
            for item in sale.items {
                product = self.data_manager.get_product(item["product_id"]);
                if product {
                    total_cost += product.cost * item["quantity"];
                }
            }
        }
        total_profit = total_revenue - total_cost;

        return {
            "total_sales": total_sales,
            "total_revenue": total_revenue,
            "total_cost": total_cost,
            "total_profit": total_profit,
            "average_sale": total_revenue / total_sales if total_sales > 0 else 0,
            "sales": [sale.to_dict() for sale in sales]
        };
    }

    # Expense management methods
    can add_expense(description: str, amount: float, category: str, receipt_number: str = "") -> str {
        expense_id = str(uuid.uuid4())[:8];
        expense = Expense(expense_id, description, amount, category, receipt_number);
        
        if self.data_manager.add_expense(expense) {
            return expense_id;
        }
        return None;
    }

    can get_expense(expense_id: str) -> Expense {
        return self.data_manager.get_expense(expense_id);
    }

    can get_expenses_report(start_date: str = None, end_date: str = None) -> dict {
        expenses = self.data_manager.load_expenses();
        
        # Filter by date range if provided
        if start_date or end_date {
            filtered_expenses = [];
            for expense in expenses {
                expense_date = datetime.datetime.fromisoformat(expense.timestamp).date();
                if start_date and expense_date < datetime.datetime.fromisoformat(start_date).date() {
                    continue;
                }
                if end_date and expense_date > datetime.datetime.fromisoformat(end_date).date() {
                    continue;
                }
                filtered_expenses.append(expense);
            }
            expenses = filtered_expenses;
        }

        # Calculate totals by category
        total_expenses = sum(expense.amount for expense in expenses);
        expenses_by_category = {};
        
        for expense in expenses {
            category = expense.category;
            if category not in expenses_by_category {
                expenses_by_category[category] = 0.0;
            }
            expenses_by_category[category] += expense.amount;
        }

        return {
            "total_expenses": total_expenses,
            "expenses_by_category": expenses_by_category,
            "expense_count": len(expenses),
            "expenses": [expense.to_dict() for expense in expenses]
        };
    }

    # Utility methods
    can get_dashboard_summary -> dict {
        products = self.data_manager.load_products();
        sales = self.data_manager.load_sales();
        expenses = self.data_manager.load_expenses();
        low_stock_items = self.data_manager.get_low_stock_items();

        # Today's sales
        today = datetime.datetime.now().date();
        today_sales = [sale for sale in sales 
                      if datetime.datetime.fromisoformat(sale.timestamp).date() == today];
        today_revenue = sum(sale.total_amount for sale in today_sales);

        # This month's expenses
        current_month = datetime.datetime.now().replace(day=1).date();
        month_expenses = [expense for expense in expenses 
                         if datetime.datetime.fromisoformat(expense.timestamp).date() >= current_month];
        month_expense_total = sum(expense.amount for expense in month_expenses);

        return {
            "total_products": len(products),
            "total_sales": len(sales),
            "today_sales_count": len(today_sales),
            "today_revenue": today_revenue,
            "month_expenses": month_expense_total,
            "low_stock_count": len(low_stock_items),
            "low_stock_items": [item.product_id for item in low_stock_items]
        };
    }
}