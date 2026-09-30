import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/project.dart';
import 'openings_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final Customer customer;
  const ProjectsScreen({super.key, required this.customer});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project> _projects = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }

  void _refreshProjects() async {
    final data = await DBHelper.getProjectsByCustomer(widget.customer.id!);
    setState(() {
      _projects = data;
    });
  }

  void _addProject() async {
    if (_nameController.text.trim().isEmpty) return;

    await DBHelper.insertProject(
      Project(
        customerId: widget.customer.id!,
        projectName: _nameController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );

    _nameController.clear();
    _notesController.clear();
    if (mounted) Navigator.pop(context);
    _refreshProjects();
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20, left: 20, right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('مشروع / بناية جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المشروع/البناية'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProject,
              child: const Text('حفظ وبدء رفع المقاسات'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مشاريع: ${widget.customer.name}'),
      ),
      body: _projects.isEmpty
          ? const Center(child: Text('لا توجد مشاريع لهذا الزبون. اضغط + لإضافة مشروع'))
          : ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (ctx, i) {
                final project = _projects[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.business, color: Colors.blue),
                    title: Text(project.projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(project.notes?.isNotEmpty == true ? project.notes! : 'لا توجد ملاحظات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OpeningsScreen(project: project),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
