# Experiment 8: Firestore Data Retrieval

## Aim
To design and implement a Flutter application that retrieves information from Google Cloud Firestore based on user search input and displays the corresponding records dynamically.

## Key Implementation Details
- **Dynamic Search Input**:
  - `TextField` controller listening to real-time keystrokes.
  - Department filtering dropdown (`DropdownButton`).
- **Firestore Query Mechanics**:
  - Structured queries using `.where()` clauses:
    - Equality match: `.where('department', isEqualTo: selectedDept)`
    - Range queries for string prefix search:
      `.where('name', isGreaterThanOrEqualTo: query).where('name', isLessThanOrEqualTo: '$query\uf8ff')`
- **Dynamic UI Presentation**:
  - `StreamBuilder` dynamically subscribes to Firestore query snapshots and re-renders matching results in real-time.
  - Empty search state feedback when no documents match the criteria.

## How to Run
```bash
cd exp8
flutter pub get
flutter run
```
