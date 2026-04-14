import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 7 Database Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();

  String _status = 'Ready to initialize database.';
  bool _saving = false;
  bool _isInitialized = false;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (!_isInitialized) return;

    try {
      final students = await DatabaseService().getStudents();
      setState(() {
        _students = students;
        if (_students.isEmpty) {
          _status = '✅ Database ready! No students yet.';
        } else {
          _status = '✅ Database ready! ${_students.length} student(s) loaded.';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Load error: $e';
      });
    }
  }

  Future<void> _initDatabase() async {
    setState(() {
      _status = 'Initializing database...';
      _saving = true;
    });

    try {
      final db = await DatabaseService().database;
      if (kDebugMode) print('Database instance: $db');

      setState(() {
        _isInitialized = true;
        _saving = false;
      });

      await _loadStudents();
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _saving = false;
      });
    }
  }

  Future<void> _addStudent() async {
    final name = _nameController.text.trim();
    final course = _courseController.text.trim();

    if (name.isEmpty || course.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both name and course')),
        );
      }
      return;
    }

    if (!_isInitialized) {
      setState(() {
        _status = 'Please initialize database first.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _status = 'Saving "$name"...';
    });

    try {
      await DatabaseService().insertStudent(name: name, course: course);
      _nameController.clear();
      _courseController.clear();

      await _loadStudents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ "$name" added successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error saving: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week 7: SQLite Lab'),
        elevation: 0,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _saving ? null : _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 4,
              color: _status.contains('✅')
                  ? Colors.green.shade50
                  : _status.contains('❌')
                  ? Colors.red.shade50
                  : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _status.contains('✅')
                          ? Icons.check_circle
                          : _status.contains('❌')
                          ? Icons.error
                          : Icons.info,
                      color: _status.contains('✅')
                          ? Colors.green
                          : _status.contains('❌')
                          ? Colors.red
                          : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_status)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _initDatabase,
                    icon: const Icon(Icons.storage), // ✅ FIXED
                    label: const Text('Initialize DB'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Input Form
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Student',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        labelText: 'Student Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _courseController,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _saving ? null : _addStudent(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _addStudent,
                        icon: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(_saving ? 'Saving...' : 'Add Student'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Students List
            Text(
              'Students (${_students.length})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isInitialized && _students.isNotEmpty
                  ? ListView.separated(
                      itemCount: _students.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text('${student['id'] ?? '?'}'),
                          ),
                          title: Text(student['name']?.toString() ?? ''),
                          subtitle: Text(student['course']?.toString() ?? ''),
                          trailing: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isInitialized ? Icons.school : Icons.storage,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isInitialized
                                ? 'No students yet.\nAdd your first student above!'
                                : 'Initialize database first to see students',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
