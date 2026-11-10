import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentRecordsApp());
}

class StudentRecordsApp extends StatelessWidget {
  const StudentRecordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Student Records',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getStudents();
    if (data.isEmpty) {
      // Seed initial sample data for demonstration
      await _dbHelper.insertStudent(Student(
        name: 'Alex Johnson',
        rollNo: 'CS2026-001',
        department: 'Computer Science',
        email: 'alex.j@college.edu',
        gpa: 8.9,
      ));
      await _dbHelper.insertStudent(Student(
        name: 'Sophia Patel',
        rollNo: 'AI2026-015',
        department: 'Artificial Intelligence',
        email: 'sophia.p@college.edu',
        gpa: 9.4,
      ));
    }
    await _refreshStudentList();
  }

  Future<void> _refreshStudentList() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getStudents();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  void _showAddStudentDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final rollNoController = TextEditingController();
    final deptController = TextEditingController(text: 'Computer Science');
    final emailController = TextEditingController();
    final gpaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Colors.blueGrey),
              SizedBox(width: 8),
              Text('Add Student Record'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: rollNoController,
                    decoration: const InputDecoration(labelText: 'Roll / Reg Number'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: deptController,
                    decoration: const InputDecoration(labelText: 'Department'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: gpaController,
                    decoration: const InputDecoration(labelText: 'GPA / CGPA (0 - 10)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      final n = double.tryParse(val ?? '');
                      if (n == null || n < 0 || n > 10) return 'Enter GPA between 0.0 and 10.0';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newStudent = Student(
                    name: nameController.text.trim(),
                    rollNo: rollNoController.text.trim(),
                    department: deptController.text.trim(),
                    email: emailController.text.trim(),
                    gpa: double.parse(gpaController.text.trim()),
                  );

                  await _dbHelper.insertStudent(newStudent);
                  Navigator.of(ctx).pop();
                  await _refreshStudentList();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Student "${newStudent.name}" added successfully!')),
                    );
                  }
                }
              },
              child: const Text('Save Record'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Student Records', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload from SQLite',
            onPressed: _refreshStudentList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.blueGrey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Operations: Create (Insert) & Read (Query)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blueGrey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_students.length} Records',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Students List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No student records found in SQLite DB',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Text('Click the "+" button below to add a student.'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _students.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.blueGrey.shade100,
                                    child: Text(
                                      student.name.isNotEmpty ? student.name[0] : 'S',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Roll No: ${student.rollNo} • ${student.department}',
                                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          student.email,
                                          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: student.gpa >= 8.5 ? Colors.green.shade50 : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: student.gpa >= 8.5 ? Colors.green.shade300 : Colors.blue.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('CGPA', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        Text(
                                          student.gpa.toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: student.gpa >= 8.5 ? Colors.green.shade800 : Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }
}
