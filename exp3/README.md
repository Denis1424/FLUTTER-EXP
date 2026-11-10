# Experiment 3: Add Interactivity to App – Input and Forms

## Aim
To develop a Flutter application that displays a predefined list of products and allows users to search or filter the products using input widgets, providing an interactive user experience.

## Input Widgets & Techniques Used
- **TextField**: Real-time text search with clear action and dynamic search query listener.
- **ChoiceChips**: Interactive single-selection category filter (All, Laptops, Phones, Tablets, Audio, Accessories).
- **RangeSlider**: Interactive dual-thumb slider to define minimum and maximum price thresholds.
- **Switch**: Interactive toggle button to filter items currently in-stock vs out-of-stock.
- **DropdownButton**: Sorting criteria selection (Alphabetical, Price Low-High, Price High-Low, Rating).
- **Dynamic State Updates**: Immediate reactive updates using `setState()` with empty-state UI fallback when no matches exist.

## How to Run
```bash
cd exp3
flutter pub get
flutter run
```
