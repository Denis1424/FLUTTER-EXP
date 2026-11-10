# Experiment 6: Data Persistence using SQLite

## Aim
To design and develop a Flutter application that stores and retrieves student records using the SQLite database by implementing Create and Read operations.

## Database Operations Implemented
- **Database Initialization**:
  - Uses `sqflite` and `path` to construct local DB path and initialize `students_records.db`.
  - Executes `CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, rollNo TEXT UNIQUE, department TEXT, email TEXT, gpa REAL)`.
- **CREATE (Insert)**:
  - Form validation for student name, roll number, department, email, and GPA.
  - Invokes `db.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace)`.
- **READ (Query)**:
  - Invokes `db.query('students', orderBy: 'id DESC')`.
  - Maps database rows to strongly-typed `Student` model objects.
  - Dynamically updates the UI list on data changes.
- **Graceful Fallback**:
  - Automatically falls back to local in-memory storage if running on environments without linked native SQLite dynamic libraries, ensuring zero crashes.

## How to Run
```bash
cd exp6
flutter pub get
flutter run
```
