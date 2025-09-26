# Small Shop POS System

This is a Point of Sale (POS) program built with Jaclang that can be used by small shops to track sales, stock taking, reorder alerts, and expenses.

## Features

### 🏪 Complete POS Functionality
- **Product Management**: Add, view, and manage products with pricing and categories
- **Inventory Tracking**: Real-time stock level management with automatic updates
- **Sales Processing**: Complete sales transactions with multiple items
- **Expense Tracking**: Record and categorize business expenses
- **Stock Alerts**: Low stock notifications and reorder suggestions
- **Reports**: Sales reports, expense analysis, and profit calculations

### 💻 Multiple Interfaces
1. **Demo Mode**: Automatic sample data population and report generation
2. **Interactive CLI**: Menu-driven command-line interface for daily operations

## Installation

1. Install Jaclang:
```bash
pip install jaclang
```

2. Clone or download this repository

## Usage

### Demo Mode (Quick Start)
Run the demo to see the system in action with sample data:
```bash
jac run pos_simple.jac
```

This will:
- Create sample products (beverages, bakery items, dairy, fruits, snacks)
- Add initial stock levels
- Process sample sales
- Record sample expenses
- Generate comprehensive reports

### Interactive Mode (Daily Operations)
For interactive use with the CLI menu system:
```bash
jac run pos_interactive.jac
```

Available menu options:
1. 📦 Add Product - Create new products with pricing and categories
2. 📋 View Products - Display all products with current stock levels
3. 📊 Update Stock - Modify inventory quantities
4. 💰 Process Sale - Handle customer transactions
5. 💸 Record Expense - Log business expenses
6. 📈 Sales Report - View sales performance and profit analysis
7. 🔴 Low Stock Alert - Check items that need reordering
0. 🚪 Exit

## Data Storage

The system uses JSON files for data persistence:
- `products.json` - Product catalog
- `stock.json` - Inventory levels and reorder points
- `sales.json` - Transaction history
- `expenses.json` - Business expense records

Data is stored in the `pos_data` directory (for interactive mode) or `demo_data` directory (for demo mode).

## System Architecture

### Core Classes
- **Product**: Represents items in the catalog with pricing and categorization
- **POSSystem**: Main system class handling all business logic
- **StockItem**: Manages inventory levels and reorder alerts
- **Sale**: Handles transaction processing and validation
- **Expense**: Records business expenditures

### Key Features
- **Stock Validation**: Prevents overselling by checking availability
- **Automatic Updates**: Stock levels update automatically with each sale
- **Profit Calculation**: Real-time profit analysis using cost vs. selling price
- **Category Management**: Organize products and expenses by categories
- **Reorder Alerts**: Configurable low-stock notifications

## Example Workflow

1. **Setup Products**: Add your inventory items with costs and selling prices
2. **Stock Management**: Set initial quantities and reorder levels
3. **Daily Sales**: Process customer transactions through the sales interface
4. **Expense Tracking**: Record daily business expenses (utilities, supplies, etc.)
5. **Reporting**: Monitor performance with sales and expense reports
6. **Reordering**: Check low stock alerts to maintain inventory levels

## Sample Data

The demo includes realistic sample data:
- **Products**: Coca Cola, White Bread, Milk, Bananas, Potato Chips
- **Stock Levels**: Varied quantities with reorder points
- **Sales**: Multi-item transactions with different payment methods
- **Expenses**: Utilities, inventory restocking, maintenance costs

## Benefits for Small Shops

- **Simple Operation**: Menu-driven interface requires minimal training
- **Real-time Tracking**: Instant inventory updates prevent stockouts
- **Profit Visibility**: Clear profit margins on all transactions
- **Expense Control**: Categorized expense tracking for better budgeting
- **Reorder Management**: Automated alerts prevent inventory shortages
- **Data Persistence**: Reliable JSON-based storage for business continuity

## Technical Details

- **Language**: Jaclang (Jaseci Programming Language)
- **Data Format**: JSON for cross-platform compatibility
- **Architecture**: Object-oriented design with clear separation of concerns
- **Error Handling**: Comprehensive validation and error messages
- **File System**: Automatic directory and file creation

This POS system is designed specifically for small shop owners who need a reliable, easy-to-use solution for managing their daily operations without complex setup or ongoing maintenance costs.