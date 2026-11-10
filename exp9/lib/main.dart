import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase auto-initialization skipped or unconfigured: $e');
  }
  runApp(const FirestoreUpdateApp());
}

/// Member Record Model
class MemberRecord {
  final String id;
  final String name;
  final String department;
  final String role;
  final String phone;
  final double rating;

  MemberRecord({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    required this.phone,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'role': role,
      'phone': phone,
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory MemberRecord.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return MemberRecord(
      id: doc.id,
      name: d['name'] ?? '',
      department: d['department'] ?? '',
      role: d['role'] ?? '',
      phone: d['phone'] ?? '',
      rating: (d['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

class FirestoreUpdateApp extends StatelessWidget {
  const FirestoreUpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Data Update',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const UpdateRecordsScreen(),
    );
  }
}

class UpdateRecordsScreen extends StatefulWidget {
  const UpdateRecordsScreen({super.key});

  @override
  State<UpdateRecordsScreen> createState() => _UpdateRecordsScreenState();
}

class _UpdateRecordsScreenState extends State<UpdateRecordsScreen> {
  bool _isFirebaseActive = false;

  // Local state container for fallback mode
  final List<MemberRecord> _records = [
    MemberRecord(id: 'rec_101', name: 'Karthik Raja', department: 'Mobile Development', role: 'Flutter Specialist', phone: '+91 9876543210', rating: 4.8),
    MemberRecord(id: 'rec_102', name: 'Meera Nambiar', department: 'UI/UX Design', role: 'Senior Product Designer', phone: '+91 9123456789', rating: 4.9),
    MemberRecord(id: 'rec_103', name: 'Siddharth Roy', department: 'Backend Systems', role: 'Go / Microservices Engineer', phone: '+91 9988776655', rating: 4.6),
  ];
  late final StreamController<List<MemberRecord>> _mockStreamCtrl =
      StreamController<List<MemberRecord>>.broadcast(
    onListen: () {
      _mockStreamCtrl.add(List.unmodifiable(_records));
    },
  );

  @override
  void initState() {
    super.initState();
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseActive = true;
      }
    } catch (_) {
      _isFirebaseActive = false;
    }
  }

  @override
  void dispose() {
    _mockStreamCtrl.close();
    super.dispose();
  }

  Stream<List<MemberRecord>> _getRecordsStream() {
    if (_isFirebaseActive) {
      return FirebaseFirestore.instance
          .collection('members')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => MemberRecord.fromDoc(d)).toList());
    } else {
      return _mockStreamCtrl.stream;
    }
  }

  /// UPDATE: Update document in Firestore based on user input
  Future<void> _updateRecord(String docId, Map<String, dynamic> updatedData) async {
    if (_isFirebaseActive) {
      await FirebaseFirestore.instance.collection('members').doc(docId).update(updatedData);
    } else {
      final index = _records.indexWhere((r) => r.id == docId);
      if (index != -1) {
        _records[index] = MemberRecord(
          id: docId,
          name: updatedData['name'] ?? _records[index].name,
          department: updatedData['department'] ?? _records[index].department,
          role: updatedData['role'] ?? _records[index].role,
          phone: updatedData['phone'] ?? _records[index].phone,
          rating: (updatedData['rating'] as num?)?.toDouble() ?? _records[index].rating,
        );
        _mockStreamCtrl.add(List.unmodifiable(_records));
      }
    }
  }

  /// Dialog to accept user inputs to update existing record
  void _openEditDialog(MemberRecord record) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: record.name);
    final deptCtrl = TextEditingController(text: record.department);
    final roleCtrl = TextEditingController(text: record.role);
    final phoneCtrl = TextEditingController(text: record.phone);
    double ratingVal = record.rating;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit_note, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text('Update ${record.name}'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${record.id}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: roleCtrl,
                        decoration: const InputDecoration(labelText: 'Designation / Role', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: deptCtrl,
                        decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.trim().length < 6 ? 'Valid phone required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Performance Rating:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(ratingVal.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                      Slider(
                        value: ratingVal,
                        min: 1.0,
                        max: 5.0,
                        divisions: 40,
                        activeColor: Colors.teal,
                        onChanged: (val) {
                          setDialogState(() => ratingVal = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final updatePayload = {
                        'name': nameCtrl.text.trim(),
                        'role': roleCtrl.text.trim(),
                        'department': deptCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'rating': ratingVal,
                      };

                      await _updateRecord(record.id, updatePayload);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Record for "${nameCtrl.text.trim()}" updated successfully in Firestore!'),
                            backgroundColor: Colors.teal.shade800,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _seedInitialRecords() async {
    if (!_isFirebaseActive) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      final col = FirebaseFirestore.instance.collection('members');
      for (final r in _records) {
        batch.set(col.doc(r.id), r.toMap());
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample records seeded to Firestore!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding records: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Data Update', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade50,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(
                Icons.circle,
                size: 10,
                color: _isFirebaseActive ? Colors.green : Colors.amber.shade900,
              ),
              label: Text(
                _isFirebaseActive ? 'Firestore Live' : 'Local Mock Mode',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.teal.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.teal, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap "Edit" on any record to update its details in Firestore and reflect changes dynamically.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MemberRecord>>(
              initialData: _isFirebaseActive ? null : List.unmodifiable(_records),
              stream: _getRecordsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No records available to update.'),
                        if (_isFirebaseActive) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _seedInitialRecords,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Seed Sample Records'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final item = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.teal.shade100,
                              child: Text(
                                item.name.isNotEmpty ? item.name[0] : 'M',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 3),
                                  Text('${item.role} • ${item.department}', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800)),
                                  const SizedBox(height: 3),
                                  Text('📞 ${item.phone}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('${item.rating.toStringAsFixed(1)} / 5.0', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade50,
                                foregroundColor: Colors.teal.shade900,
                                elevation: 0,
                                side: BorderSide(color: Colors.teal.shade200),
                              ),
                              onPressed: () => _openEditDialog(item),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
