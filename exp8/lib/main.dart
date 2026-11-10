import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirestoreSearchApp());
}

class RecordItem {
  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String location;

  RecordItem({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.location,
  });

  factory RecordItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return RecordItem(
      id: doc.id,
      name: d['name'] ?? '',
      role: d['role'] ?? '',
      department: d['department'] ?? '',
      email: d['email'] ?? '',
      location: d['location'] ?? '',
    );
  }
}

class FirestoreSearchApp extends StatelessWidget {
  const FirestoreSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Data Retrieval & Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FirestoreSearchScreen(),
    );
  }
}

class FirestoreSearchScreen extends StatefulWidget {
  const FirestoreSearchScreen({super.key});

  @override
  State<FirestoreSearchScreen> createState() => _FirestoreSearchScreenState();
}

class _FirestoreSearchScreenState extends State<FirestoreSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDept = 'All';

  // Seed sample records for retrieval demonstration
  final List<RecordItem> _fallbackRecords = [
    RecordItem(id: '1', name: 'Dr. Ramesh Kumar', role: 'Professor', department: 'Computer Science', email: 'ramesh.k@univ.edu', location: 'Block A - 302'),
    RecordItem(id: '2', name: 'Dr. Priya Sundaram', role: 'Associate Professor', department: 'Information Technology', email: 'priya.s@univ.edu', location: 'Block B - 105'),
    RecordItem(id: '3', name: 'Arun Balaji', role: 'Research Scholar', department: 'Artificial Intelligence', email: 'arun.b@univ.edu', location: 'AI Lab - 201'),
    RecordItem(id: '4', name: 'Kavitha Ramachandran', role: 'Assistant Professor', department: 'Computer Science', email: 'kavitha.r@univ.edu', location: 'Block A - 210'),
    RecordItem(id: '5', name: 'Vikram Seth', role: 'System Architect', department: 'Information Technology', email: 'vikram.s@univ.edu', location: 'Server Center'),
    RecordItem(id: '6', name: 'Deepa Nair', role: 'Data Scientist', department: 'Artificial Intelligence', email: 'deepa.n@univ.edu', location: 'AI Lab - 204'),
  ];

  final List<String> _departments = ['All', 'Computer Science', 'Information Technology', 'Artificial Intelligence'];

  bool _isFirebaseConfigured = false;

  @override
  void initState() {
    super.initState();
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseConfigured = true;
      }
    } catch (_) {
      _isFirebaseConfigured = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Query method for Firestore
  Stream<List<RecordItem>> _getFilteredStream() {
    if (_isFirebaseConfigured) {
      Query query = FirebaseFirestore.instance.collection('faculty_records');

      if (_selectedDept != 'All') {
        query = query.where('department', isEqualTo: _selectedDept);
      }

      if (_searchQuery.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: _searchQuery)
            .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
      }

      return query.snapshots().map(
            (snap) => snap.docs.map((doc) => RecordItem.fromDoc(doc)).toList(),
          );
    } else {
      // Local reactive fallback stream
      final filtered = _fallbackRecords.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.email.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesDept = _selectedDept == 'All' || item.department == _selectedDept;
        return matchesQuery && matchesDept;
      }).toList();

      return Stream.value(filtered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Search & Retrieval', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: Column(
        children: [
          // Search & Filter Header Card
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  // Search Input Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by faculty name or role...',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.deepPurple.shade50.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Department Filter Dropdown
                  Row(
                    children: [
                      const Icon(Icons.filter_list, size: 20, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      const Text('Filter by Dept: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedDept,
                          underline: Container(height: 1, color: Colors.deepPurple),
                          items: _departments.map((d) {
                            return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDept = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // StreamBuilder for Dynamic Firestore Retrieval
          Expanded(
            child: StreamBuilder<List<RecordItem>>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Query error: ${snapshot.error}'));
                }

                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No records matching "$_searchQuery"',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        const Text('Try modifying your query or selecting "All" departments.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.deepPurple.shade100,
                              child: const Icon(Icons.person, color: Colors.deepPurple),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.role} • ${item.department}',
                                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 14, color: Colors.deepPurple),
                                      const SizedBox(width: 4),
                                      Text(item.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.room_outlined, size: 14, color: Colors.deepOrange),
                                      const SizedBox(width: 4),
                                      Text(item.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
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
