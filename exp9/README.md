# Experiment 9: Firestore Data Update

## Aim
To develop a Flutter application that allows users to update existing records stored in Google Cloud Firestore based on user input and displays the updated information dynamically.

## Key Update Mechanics
- **Document Update API**:
  - `FirebaseFirestore.instance.collection('members').doc(recordId).update(updatedData)`
  - Stores timestamped changes with `FieldValue.serverTimestamp()`.
- **Pre-populated Edit Form**:
  - Tapping 'Edit' pre-populates name, role, department, phone, and performance rating into form controllers.
  - Form validation verifies input integrity before committing updates.
- **Dynamic Real-Time Refresh**:
  - Firestore document updates trigger `snapshots()` stream events.
  - UI updates immediately with feedback SnackBar confirming successful persistence.

## How to Run
```bash
cd exp9
flutter pub get
flutter run
```
