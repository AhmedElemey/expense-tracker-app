# Expense Tracker App

A Flutter-based expense tracking application with modern UI and advanced features.

---

## 📐 Overview & Architecture

This app is built using *Clean Architecture* principles:
- *Presentation Layer:* UI screens, widgets, and Riverpod providers
- *Domain Layer:* Business logic, use cases, and repository interfaces
- *Data Layer:* Hive for local storage, API services for currency conversion

*Project Structure:*

lib/
  core/           # Theme, constants, utilities
  data/           # Models, repositories, datasources, services
  domain/         # Repository interfaces, use cases
  presentation/   # Screens, providers, widgets


---

## 🗂 State Management
- Uses *Riverpod* for robust, testable, and scalable state management.
- Providers manage expenses, currency, and UI state.

---

## 🌐 API Integration
- Currency conversion uses [open.er-api.com](https://open.er-api.com/).
- API is called when adding an expense in a non-USD currency; the converted USD amount is stored and displayed.
- HTTP requests are handled via the Dio package in CurrencyService.

---

## 🔄 Pagination Strategy
- *Local Pagination:*
  - Expenses are paginated locally using Hive.
  - The provider fetches a page of expenses at a time (default: 10 per page).
  - No server-side pagination (all data is local).

## ⚖️ Trade-offs & Assumptions
- *Offline-first:* All data is stored locally; no remote sync.
- *Currency rates:* Conversion is done at the time of adding an expense; rates are not updated retroactively.
- *No authentication:* Login is UI-only (no backend auth).
- *No cloud backup:* Data is lost if the app is uninstalled.
- *Testing:* Includes unit and widget tests for validation and currency logic.

---

## 🚀 How to Run

1. *Clone the repository:*
   bash
   git clone https://github.com/AhmedElemey/expense-tracker-app.git
   cd expense-tracker-app
   
2. *Install dependencies:*
   bash
   flutter pub get
   
3. *Run the app:*
   bash
   flutter run
   
4. *Run tests:*
   bash
   flutter test
   

---

## 🐞 Known Bugs / Unimplemented Features
- No cloud sync or backup
- No user authentication (login is UI only)
- Currency rates are not cached or updated after expense creation
- No dark mode
- No push notifications

---

## 🤝 Contributing
1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

