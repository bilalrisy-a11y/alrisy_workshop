import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';
import 'projects_screen.dart'; // تم إضافة استيراد شاشة المشاريع

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Customer> _customers = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCustomers();
  }

  void _refreshCustomers() async {
    final data = await DBHelper.getCustomers();
    setState(() {
      _customers = data;
    });
  }

  void _addCustomer() async {
    if (_nameController.text.trim().isEmpty) return;

    await DBHelper.insertCustomer(
      Customer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );

    _nameController.clear();
    _phoneController.clear();
    if (mounted) Navigator.pop(context);
    _refreshCustomers();
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'إضافة زبون جديد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الزبون / العملاق'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCustomer,
              child: const Text('حفظ الزبون'),
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
        title: const Text('ورشة الريسي للألومنيوم'),
        centerTitle: true,
      ),
      body: _customers.isEmpty
          ? const Center(child: Text('لا يوجد زبائن حالياً. اضغط + للإضافة'))
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (ctx, i) {
                final customer = _customers[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${customer.id}')),
                    title: Text(customer.name),
                    subtitle: Text(customer.phone?.isNotEmpty == true ? customer.phone! : 'بدون رقم'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    // هنا التعديل المطلوب: عند الضغط على اسم الزبون يتم فتح شاشة مشاريع هذا الزبون
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectsScreen(customer: customer),
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
