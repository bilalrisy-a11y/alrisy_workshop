import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/project.dart';
import '../models/opening.dart';

class OpeningsScreen extends StatefulWidget {
  final Project project;
  const OpeningsScreen({super.key, required this.project});

  @override
  State<OpeningsScreen> createState() => _OpeningsScreenState();
}

class _OpeningsScreenState extends State<OpeningsScreen> {
  List<Opening> _openings = [];

  // حقول الإدخال
  String _selectedType = 'نافذة';
  String _selectedCategory = 'غرف';
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // تفاصيل العقد
  bool _hasArch = false;
  final TextEditingController _archSittingController = TextEditingController();
  final TextEditingController _archTotalController = TextEditingController();

  final List<String> _categories = ['غرف', 'حمامات', 'مطابخ', 'درج', 'صالة', 'مجلس', 'أبواب'];

  @override
  void initState() {
    super.initState();
    _refreshOpenings();
  }

  void _refreshOpenings() async {
    final data = await DBHelper.getOpeningsByProject(widget.project.id!);
    setState(() {
      _openings = data;
    });
  }

  void _addOpening() async {
    if (_widthController.text.isEmpty || _heightController.text.isEmpty) return;

    final code = await DBHelper.generateNextCode(widget.project.id!, _selectedType);

    await DBHelper.insertOpening(
      Opening(
        projectId: widget.project.id!,
        autoCode: code,
        type: _selectedType,
        category: _selectedCategory,
        width: double.parse(_widthController.text),
        height: double.parse(_heightController.text),
        hasArch: _hasArch,
        archSittingHeight: _hasArch && _archSittingController.text.isNotEmpty ? double.parse(_archSittingController.text) : null,
        archTotalHeight: _hasArch && _archTotalController.text.isNotEmpty ? double.parse(_archTotalController.text) : null,
        description: _descController.text.trim(),
      ),
    );

    _widthController.clear();
    _heightController.clear();
    _descController.clear();
    _archSittingController.clear();
    _archTotalController.clear();
    _hasArch = false;

    if (mounted) Navigator.pop(context);
    _refreshOpenings();
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('إدخال فتحة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('نافذة'),
                        value: 'نافذة',
                        groupValue: _selectedType,
                        onChanged: (v) => setModalState(() => _selectedType = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('باب'),
                        value: 'باب',
                        groupValue: _selectedType,
                        onChanged: (v) => setModalState(() => _selectedType = v!),
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setModalState(() => _selectedCategory = v!),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'العرض (سم)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الارتفاع (سم)'),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('هل يوجد عقد؟'),
                  value: _hasArch,
                  onChanged: (v) => setModalState(() => _hasArch = v),
                ),
                if (_hasArch) ...[
                  TextField(
                    controller: _archSittingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الارتفاع الجالس (سم)'),
                  ),
                  TextField(
                    controller: _archTotalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الارتفاع الكلي (سم)'),
                  ),
                ],
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'الوصف / المكان'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addOpening,
                  child: const Text('حفظ الفتحة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مقاسات: ${widget.project.projectName}'),
      ),
      body: _openings.isEmpty
          ? const Center(child: Text('لا توجد فتحات مسجلة. اضغط + لتسجيل مقاس'))
          : ListView.builder(
              itemCount: _openings.length,
              itemBuilder: (ctx, i) {
                final item = _openings[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.type == 'نافذة' ? Colors.blue.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.autoCode,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    title: Text('${item.category} — ${item.width}×${item.height} سم'),
                    subtitle: Text(
                      '${item.description ?? ''} ${item.hasArch ? '(يوجد عقد)' : ''}',
                    ),
                    trailing: const Icon(Icons.design_services, color: Colors.green),
                    onTap: () {
                      // الانتقال إلى شاشة المصمم لاحقاً
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
