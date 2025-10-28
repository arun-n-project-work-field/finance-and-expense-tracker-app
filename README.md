# 💰 Smart Personal Finance & Expense Tracker

A **cross-platform Flutter app** for tracking income, expenses, and budgets — built using **Provider** for state management and **SQLite** for local storage.

---

## 🧩 Tech Stack

| Technology | Purpose |
|-------------|----------|
| **Flutter 3.x** | UI framework |
| **Dart 3.x** | Language |
| **Provider** | State management |
| **Sqflite** | Local database |
| **Path Provider** | File path handling |
| **fl_chart** | Charts for analytics |
| **Share Plus** | CSV export & sharing |
| **CSV** | Data export formatting |
| **Intl** | Currency/date formatting |
| **Month Picker Dialog** | Month selection |
| **Shared Preferences** | Theme persistence |

---

## 🚀 Features

### 🏠 Dashboard
- Displays **current balance** (Income − Expenses)
- Shows **recent transactions**
- Includes **animated pie chart** of expenses by category
- Fully responsive layout for mobile screens

### 💵 Transactions
- Add, edit, and delete transactions  
- Categories: Food, Travel, Bills, Shopping, etc.  
- Income vs Expense toggle  
- Input validation & date picker  
- Stored locally using **SQLite**  
- Swipe-to-delete (with undo coming soon)

### 🎯 Budgets
- Set monthly budgets per category  
- Color-coded progress bars:
  - 🟢 Safe (<80%)
  - 🟠 Warning (80–100%)
  - 🔴 Exceeded (>100%)
- Automatic updates based on monthly transactions  
- Smooth progress bar animation

### 🌗 Appearance
- **Light/Dark mode toggle**  
- Theme preference saved locally  

### 📤 Data Export
- Export transactions to **CSV**  
- Save or share via native share sheet  
- Stored safely in app’s documents folder  

---

## 🧠 Architecture

### Folder Structure
```
lib/
├── data/
│   ├── db/
│   │   └── database_helper.dart
│   └── models/
│       ├── transaction_model.dart
│       └── budget_model.dart
├── providers/
│   ├── transaction_provider.dart
│   ├── budget_provider.dart
│   └── theme_provider.dart
├── ui/
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── budgets_screen.dart
│   │   └── add_edit_transaction_screen.dart
│   └── widgets/
│       ├── balance_card.dart
│       ├── expense_chart.dart
│       └── transaction_tile.dart
└── main.dart
```

### State Management: **Provider**
- Each major feature (Transactions, Budgets, Theme) uses a separate `ChangeNotifier`  
- Automatic UI updates with `Consumer` and `Provider.of()`  
- Simple, lightweight, and clean structure  

### Local Storage: **SQLite**
- All data persists locally using `sqflite`
- Two tables:  
  - **transactions** → income & expenses  
  - **budgets** → per-category monthly limits  

---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK ≥ 3.3  
- Dart ≥ 3.0  
- Android Studio / VS Code  
- Android SDK or Xcode  

### Installation
```bash
git clone https://github.com/<your-username>/finance-and-expense-tracker-app.git
cd finance-and-expense-tracker-app
flutter pub get
flutter run
```

### Build Release
```bash
flutter build apk --release
```

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Includes:
- ✅ Transaction CRUD logic tests  
- ✅ Dashboard widget tests  
- ✅ Budget calculation tests  

---

## ✨ Bonus Features
- Light/Dark mode persistence  
- Animated category charts  
- Export to CSV  
- Smooth Material transitions  

---

## 📊 Evaluation Criteria (Assignment)
| Criteria | Implemented |
|-----------|--------------|
| State Management (Provider) | ✅ |
| Local Storage (SQLite) | ✅ |
| UI/UX & Responsiveness | ✅ |
| Code Quality & Linting | ✅ |
| Testing | ✅ (Unit + Widget) |
| Bonus: Dark Mode + CSV Export | ✅ |

---

## 🎨 Design Highlights
- Material 3 theme  
- Rounded cards & clean typography  
- Consistent color palette  
- Subtle shadows & spacing  
- Smooth animated transitions  

---

## 🧾 Example Git Commit Flow
```bash
feat: setup provider state management
feat: add transaction CRUD with SQLite
feat: implement dashboard chart & UI
feat: create budgets screen with alerts
fix: resolve theme persistence bug
feat: add CSV export & share functionality
```

---

## 🧑‍💻 Author
**Your Name**  
GitHub: [@arun-n-project-work-field](https://github.com/arun-n-project-work-field)

---

## 📄 License
This project is licensed under the **MIT License**.
