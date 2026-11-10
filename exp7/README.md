# Experiment 7: Data Persistence using Google Cloud Firestore

## Aim
To develop a Flutter application that stores and retrieves employee or student information using Google Cloud Firestore, ensuring data persistence even after the application is closed and reopened.

## Firebase & Firestore Concepts Implemented
- **Firebase Initialization**: `Firebase.initializeApp()`
- **Document Creation (Store)**:
  - Validates user input through a form modal.
  - Converts data to Firestore document map using `Timestamp` and server timestamps.
  - Inserts into Cloud Firestore collection: `FirebaseFirestore.instance.collection('employees').add(employee.toMap())`.
- **Document Streaming (Retrieve)**:
  - Listens to document updates via real-time streams: `.collection('employees').orderBy('joiningDate').snapshots()`.
  - Uses `StreamBuilder<List<Employee>>` to dynamically update the UI whenever changes occur in the database.
- **Persistence Across App Sessions**:
  - Cloud Firestore caches data locally on device and automatically syncs with Google Cloud upon connection.

## How to Run
```bash
cd exp7
flutter pub get
flutter run
```
