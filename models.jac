"""
Core data models for the Point of Sale system.
Defines Product, Sale, Expense, and Stock entities.
"""

import json;
import datetime;

# Product data structure
class Product {
    def __init__(
        self: Product,
        id: str,
        name: str,
        price: float,
        cost: float,
        category: str,
        barcode: str = "",
        description: str = ""
    ) {
        self.id = id;
        self.name = name;
        self.price = price;
        self.cost = cost;
        self.category = category;
        self.barcode = barcode;
        self.description = description;
    }

    def to_dict(self: Product) -> dict {
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

    def from_dict(data: dict) -> Product {
        return Product(
            data["id"], data["name"], data["price"], 
            data["cost"], data["category"],
            data.get("barcode", ""), data.get("description", "")
        );
    }
}

# Stock/Inventory item
object StockItem {
    has product_id: str,
        quantity: int,
        reorder_level: int,
        last_updated: str;

    can init(product_id: str, quantity: int, reorder_level: int = 10) {
        self.product_id = product_id;
        self.quantity = quantity;
        self.reorder_level = reorder_level;
        self.last_updated = datetime.datetime.now().isoformat();
    }

    can update_quantity(new_quantity: int) {
        self.quantity = new_quantity;
        self.last_updated = datetime.datetime.now().isoformat();
    }

    can needs_reorder -> bool {
        return self.quantity <= self.reorder_level;
    }

    can to_dict -> dict {
        return {
            "product_id": self.product_id,
            "quantity": self.quantity,
            "reorder_level": self.reorder_level,
            "last_updated": self.last_updated
        };
    }

    can from_dict(data: dict) -> StockItem {
        item = StockItem(data["product_id"], data["quantity"], data["reorder_level"]);
        item.last_updated = data.get("last_updated", datetime.datetime.now().isoformat());
        return item;
    }
}

# Sale transaction
object Sale {
    has id: str,
        items: list,  # List of {product_id, quantity, unit_price}
        total_amount: float,
        payment_method: str,
        timestamp: str,
        customer_name: str = "";

    can init(id: str, items: list, payment_method: str, customer_name: str = "") {
        self.id = id;
        self.items = items;
        self.payment_method = payment_method;
        self.customer_name = customer_name;
        self.timestamp = datetime.datetime.now().isoformat();
        self.total_amount = self.calculate_total();
    }

    can calculate_total -> float {
        total = 0.0;
        for item in self.items {
            total += item["quantity"] * item["unit_price"];
        }
        return total;
    }

    can add_item(product_id: str, quantity: int, unit_price: float) {
        self.items.append({
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": unit_price
        });
        self.total_amount = self.calculate_total();
    }

    can to_dict -> dict {
        return {
            "id": self.id,
            "items": self.items,
            "total_amount": self.total_amount,
            "payment_method": self.payment_method,
            "timestamp": self.timestamp,
            "customer_name": self.customer_name
        };
    }

    can from_dict(data: dict) -> Sale {
        sale = Sale(data["id"], data["items"], data["payment_method"], data.get("customer_name", ""));
        sale.timestamp = data.get("timestamp", datetime.datetime.now().isoformat());
        sale.total_amount = data.get("total_amount", sale.calculate_total());
        return sale;
    }
}

# Expense record
object Expense {
    has id: str,
        description: str,
        amount: float,
        category: str,
        timestamp: str,
        receipt_number: str = "";

    can init(id: str, description: str, amount: float, category: str, receipt_number: str = "") {
        self.id = id;
        self.description = description;
        self.amount = amount;
        self.category = category;
        self.receipt_number = receipt_number;
        self.timestamp = datetime.datetime.now().isoformat();
    }

    can to_dict -> dict {
        return {
            "id": self.id,
            "description": self.description,
            "amount": self.amount,
            "category": self.category,
            "timestamp": self.timestamp,
            "receipt_number": self.receipt_number
        };
    }

    can from_dict(data: dict) -> Expense {
        expense = Expense(
            data["id"], data["description"], data["amount"], 
            data["category"], data.get("receipt_number", "")
        );
        expense.timestamp = data.get("timestamp", datetime.datetime.now().isoformat());
        return expense;
    }
}