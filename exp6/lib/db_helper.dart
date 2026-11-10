import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Student Model
class Student {
  final int? id;
  final String name;
  final String rollNo;
  final String department;
  final String email;
  final double gpa;

  Student({
    this.id,
    required this.name,
    required this.rollNo,
    required this.department,
    required this.email,
    required this.gpa,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNo': rollNo,
      'department': department,
      'email': email,
      'gpa': gpa,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      rollNo: map['rollNo'] as String,
      department: map['department'] as String,
      email: map['email'] as String,
      gpa: (map['gpa'] as num).toDouble(),
    );
  }
}

/// SQLite Database Helper for Student Records
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Fallback in-memory store for platforms where native SQLite binaries aren't linked
  final List<Student> _fallbackMemoryStore = [];
  bool _useFallback = false;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_useFallback) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDB('students_records.db');
      return _database;
    } catch (e) {
      debugPrint('SQLite native unavailable on this runner, switching to memory persistence: $e');
      _useFallback = true;
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rollNo TEXT NOT NULL UNIQUE,
        department TEXT NOT NULL,
        email TEXT NOT NULL,
        gpa REAL NOT NULL
      )
    ''');
  }

  /// CREATE: Insert a new student record
  Future<int> insertStudent(Student student) async {
    final db = await database;
    if (db == null) {
      // In-memory fallback
      final newId = _fallbackMemoryStore.length + 1;
      final newStudent = Student(
        id: newId,
        name: student.name,
        rollNo: student.rollNo,
        department: student.department,
        email: student.email,
        gpa: student.gpa,
      );
      _fallbackMemoryStore.add(newStudent);
      return newId;
    }
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ: Retrieve all student records
  Future<List<Student>> getStudents() async {
    final db = await database;
    if (db == null) {
      return List.from(_fallbackMemoryStore);
    }
    final result = await db.query('students', orderBy: 'id DESC');
    return result.map((json) => Student.fromMap(json)).toList();
  }

  /// READ: Retrieve student by ID
  Future<Student?> getStudentById(int id) async {
    final db = await database;
    if (db == null) {
      try {
        return _fallbackMemoryStore.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
    final maps = await db.query(
      'students',
      columns: ['id', 'name', 'rollNo', 'department', 'email', 'gpa'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}
