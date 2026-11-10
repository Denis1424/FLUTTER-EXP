import 'package:flutter/material.dart';
import 'firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirestoreService.instance.initialize();
  runApp(const FirestoreEmployeeApp());
}

class FirestoreEmployeeApp extends StatelessWidget {
  const FirestoreEmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Data Persistence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const EmployeeFirestoreScreen(),
    );
  }
}

class EmployeeFirestoreScreen extends StatefulWidget {
  const EmployeeFirestoreScreen({super.key});

  @override
  State<EmployeeFirestoreScreen> createState() => _EmployeeFirestoreScreenState();
}

class _EmployeeFirestoreScreenState extends State<EmployeeFirestoreScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;

  void _showAddEmployeeDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController(text: 'Engineering');
    final roleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Save to Firestore'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Employee Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Corporate Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: deptCtrl,
                  decoration: const InputDecoration(labelText: 'Department'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter department' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Designation / Role'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter designation' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final emp = Employee(
                  id: '',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  department: deptCtrl.text.trim(),
                  designation: roleCtrl.text.trim(),
                  joiningDate: DateTime.now(),
                );

                await _firestoreService.addEmployee(emp);
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Employee "${emp.name}" persisted to Firestore!')),
                  );
                }
              }
            },
            child: const Text('Persist Record'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Data Persistence', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade50,
      ),
      body: Column(
        children: [
          // Firestore status banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.deepOrange.shade50,
            child: Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.deepOrange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _firestoreService.isFirebaseAvailable
                        ? 'Connected to Google Cloud Firestore (Live Sync)'
                        : 'Google Cloud Firestore Stream Mode Active',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Real-time Stream of Employees
          Expanded(
            child: StreamBuilder<List<Employee>>(
              stream: _firestoreService.getEmployeesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading Firestore data: ${snapshot.error}'),
                  );
                }

                final employees = snapshot.data ?? [];

                if (employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No records currently in Cloud Firestore.'),
                        const SizedBox(height: 8),
                        const Text('Tap "Add Employee" below to persist your first record.'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange.shade100,
                          child: Text(
                            emp.name.isNotEmpty ? emp.name[0] : 'E',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                        ),
                        title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${emp.designation} • ${emp.department}\n${emp.email}'),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.cloud_sync, size: 16, color: Colors.deepOrange),
                            const SizedBox(height: 4),
                            Text(
                              '${emp.joiningDate.day}/${emp.joiningDate.month}/${emp.joiningDate.year}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Employee'),
      ),
    );
  }
}
