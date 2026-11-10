import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Employee Model
class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String designation;
  final DateTime joiningDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.joiningDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'designation': designation,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Employee.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime date;
    if (data['joiningDate'] is Timestamp) {
      date = (data['joiningDate'] as Timestamp).toDate();
    } else {
      date = DateTime.now();
    }

    return Employee(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      designation: data['designation'] ?? '',
      joiningDate: date,
    );
  }

  factory Employee.fromMap(Map<String, dynamic> map, String docId) {
    return Employee(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      designation: map['designation'] ?? '',
      joiningDate: map['joiningDate'] is DateTime ? map['joiningDate'] : DateTime.now(),
    );
  }
}

/// Firestore Service Layer for Persistent Employee Records
class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  bool _isFirebaseAvailable = false;

  // Fallback persistent memory stream controller for lab testing without Firebase config
  final List<Employee> _mockStorage = [
    Employee(
      id: 'emp_01',
      name: 'Rohan Sharma',
      email: 'rohan.sharma@corp.com',
      department: 'Cloud Solutions',
      designation: 'Senior DevOps Engineer',
      joiningDate: DateTime(2023, 4, 15),
    ),
    Employee(
      id: 'emp_02',
      name: 'Ananya Verma',
      email: 'ananya.v@corp.com',
      department: 'Mobile Engineering',
      designation: 'Flutter Tech Lead',
      joiningDate: DateTime(2022, 8, 10),
    ),
  ];
  late final StreamController<List<Employee>> _mockStreamController =
      StreamController<List<Employee>>.broadcast();

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;
      }
    } catch (e) {
      debugPrint('Firebase not configured with google-services.json, using lab fallback: $e');
      _isFirebaseAvailable = false;
    }
    _mockStreamController.add(List.unmodifiable(_mockStorage));
  }

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  CollectionReference get _collection =>
      FirebaseFirestore.instance.collection('employees');

  /// PERSIST: Add employee record to Cloud Firestore
  Future<void> addEmployee(Employee employee) async {
    if (_isFirebaseAvailable) {
      await _collection.add(employee.toMap());
    } else {
      // Local persistent simulated document
      final newEmp = Employee(
        id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
        name: employee.name,
        email: employee.email,
        department: employee.department,
        designation: employee.designation,
        joiningDate: employee.joiningDate,
      );
      _mockStorage.insert(0, newEmp);
      _mockStreamController.add(List.unmodifiable(_mockStorage));
    }
  }

  /// RETRIEVE: Stream employee records in real-time from Cloud Firestore
  Stream<List<Employee>> getEmployeesStream() {
    if (_isFirebaseAvailable) {
      return _collection
          .orderBy('joiningDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Employee.fromDocument(doc)).toList();
      });
    } else {
      // Return stream from mock storage
      return _mockStreamController.stream;
    }
  }
}
