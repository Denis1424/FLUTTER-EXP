# Experiment 4: Form Validation using Stateful Widgets

## Aim
To design and implement a Car Mileage Calculator using Flutter Forms, `TextFormField`, Input Widgets, and Stateful Widgets, with user input validation and dynamic mileage result display.

## Key Concepts & Techniques
- **GlobalKey<FormState>**: Manages form state and coordinates validation checks.
- **TextFormField & Validators**:
  - Distance field: Validates non-empty and positive decimal numbers.
  - Fuel Consumed field: Validates positive values strictly > 0 (prevents division by zero).
  - Fuel Price (Optional): Validates valid non-negative number if entered.
- **DropdownButtonFormField**: Configures vehicle fuel types (Petrol, Diesel, CNG, Hybrid) and distance units (km, miles).
- **Dynamic State Updates**: Computes mileage dynamically, assigns color-coded efficiency ratings (Excellent, Good, Average, High Consumption), and displays trip cost breakdown.
- **Form Reset**: Clears controllers and state dynamically.

## How to Run
```bash
cd exp4
flutter pub get
flutter run
```
