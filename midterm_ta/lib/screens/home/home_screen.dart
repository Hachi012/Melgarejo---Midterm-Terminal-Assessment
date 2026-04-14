import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resource_provider.dart';
import '../../services/connectivity_service.dart';
import '../../models/task.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();
      if (authProvider.currentUser != null) {
        taskProvider.loadTasks(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STRM - Home'),
        elevation: 2,
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: connectivity.isOnline ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          connectivity.isOnline
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          connectivity.isOnline ? 'Online' : 'Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () async {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.logout();
                  if (!mounted) return;
                  if (mounted) {
                    Navigator.of(this.context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return Column(
            children: [
              // Unsync tasks indicator
              if (taskProvider.unsyncedCount > 0)
                Consumer<ConnectivityService>(
                  builder: (context, connectivity, _) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sync, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${taskProvider.unsyncedCount} unsynced task(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                if (!connectivity.isOnline)
                                  Text(
                                    'Waiting for connection...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (connectivity.isOnline && !taskProvider.isSyncing)
                            ElevatedButton.icon(
                              onPressed: () async {
                                final authProvider = context
                                    .read<AuthProvider>();
                                if (authProvider.currentUser != null) {
                                  await taskProvider.syncTasks(
                                    authProvider.currentUser!.id,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(taskProvider.errorMessage),
                                      backgroundColor:
                                          taskProvider.errorMessage.contains(
                                                'success',
                                              ) ||
                                              taskProvider.errorMessage
                                                  .contains('Synced')
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.cloud_upload, size: 16),
                              label: const Text('Sync Now'),
                            ),
                          if (taskProvider.isSyncing)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              // Tab navigation
              Expanded(
                child: PageView(
                  onPageChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  children: [
                    _buildTasksTab(taskProvider),
                    _buildResourcesTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          // Manually trigger PageView change (you might need to add a PageController instead)
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Resources',
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(TaskProvider taskProvider) {
    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskProvider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              'No tasks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Text(
              'Create a new task to get started',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        task.status,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: task.status == 'draft'
                          ? Colors.orange.shade200
                          : Colors.green.shade200,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    const SizedBox(width: 8),
                    if (!task.isSynced)
                      const Chip(
                        label: Text(
                          'Unsynced',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        labelPadding: EdgeInsets.symmetric(horizontal: 6),
                      ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) async {
                if (result == 'edit') {
                  if (mounted) {
                    _showEditTaskDialog(context, taskProvider, task);
                  }
                } else if (result == 'delete') {
                  await taskProvider.deleteTask(task.id ?? '', task.userId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResourcesTab() {
    return Consumer<ResourceProvider>(
      builder: (context, resourceProvider, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'External Resources',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    resourceProvider.loadPosts();
                  },
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Load Posts'),
                ),
                const SizedBox(height: 16),
                if (resourceProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (resourceProvider.errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            resourceProvider.errorMessage,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (resourceProvider.posts.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: resourceProvider.posts.length,
                    itemBuilder: (context, index) {
                      final post = resourceProvider.posts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(post['title'] ?? 'No title'),
                          subtitle: Text(
                            post['body'] ?? 'No description',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    TaskProvider taskProvider,
    Task task,
  ) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title cannot be empty')),
                );
                return;
              }

              final updatedTask = task.copyWith(
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
              );

              await taskProvider.updateTask(updatedTask);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
