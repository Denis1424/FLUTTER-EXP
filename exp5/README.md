# Experiment 5: Application State Management

## Aim
To develop a Personal Budget Calculator that accepts user income and expenses, calculates the remaining balance, and displays the financial status using Flutter state management techniques.

## State Management Architecture
- **ChangeNotifier (`BudgetManager`)**:
  - Centralized store managing all income and expense items.
  - Automatically computes derived metrics: `totalIncome`, `totalExpense`, `remainingBalance`, and `financialStatus`.
  - Dispatches `notifyListeners()` on state mutations (`addTransaction`, `deleteTransaction`).
- **ListenableBuilder**:
  - Efficiently binds UI widgets to state changes without unnecessary full-page rebuilds.
- **Dynamic Financial Health Evaluation**:
  - Surplus / Healthy Savings (> 40% saved): Green indicator.
  - Stable Budget (15% - 40%): Blue indicator.
  - Tight Budget (< 15%): Amber indicator.
  - Deficit / Overspending (< 0 balance): Red critical indicator.
- **Dismissible List Item**:
  - Allows swipe-to-delete gesture with instant reactive state recalculation.

## How to Run
```bash
cd exp5
flutter pub get
flutter run
```
