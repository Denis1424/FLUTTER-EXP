# Experiment 2: Adaptive and Responsive UI Design

## Aim
To design and implement a responsive Flutter application for an E-Commerce Product Catalog by creating reusable custom product widgets and adapting the layout to different screen sizes using responsive layout techniques.

## Concepts & Responsive Techniques Used
- **LayoutBuilder**: Dynamically observes constraints and adapts layout properties (e.g. number of columns and aspect ratios).
- **Adaptive Grid**:
  - Desktop (> 1100px): 4 Columns.
  - Tablet (750px - 1100px): 3 Columns.
  - Standard Mobile (450px - 750px): 2 Columns.
  - Compact Mobile (< 450px): 1 Column wide card view.
- **Adaptive Navigation**:
  - `NavigationRail` for wide desktop/tablet displays.
  - `BottomNavigationBar` for mobile screens.
- **Reusable Custom Widget (`ProductCard`)**:
  - Standardized product image banner, category tag, title, price, rating badge, and interactive 'Add to Cart' button.

## How to Run
```bash
cd exp2
flutter pub get
flutter run
```
