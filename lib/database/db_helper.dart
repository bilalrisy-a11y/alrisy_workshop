import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/customer.dart';
import '../models/project.dart';
import '../models/opening.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'alrisy_workshop.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // جدول الزبائن
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT
          )
        ''');

        // جدول المشاريع
        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            project_name TEXT NOT NULL,
            notes TEXT
          )
        ''');

        // جدول الفتحات والمقاسات
        await db.execute('''
          CREATE TABLE openings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL,
            auto_code TEXT NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            width REAL NOT NULL,
            height REAL NOT NULL,
            has_arch INTEGER NOT NULL,
            arch_sitting_height REAL,
            arch_total_height REAL,
            description TEXT
          )
        ''');
      },
    );
  }

  // === العملاء ===
  static Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  static Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.query('customers', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // === المشاريع ===
  static Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('projects', project.toMap());
  }

  static Future<List<Project>> getProjectsByCustomer(int customerId) async {
    final db = await database;
    final maps = await db.query('projects', where: 'customer_id = ?', whereArgs: [customerId], orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  // === الفتحات والمقاسات ===
  static Future<int> insertOpening(Opening opening) async {
    final db = await database;
    return await db.insert('openings', opening.toMap());
  }

  static Future<List<Opening>> getOpeningsByProject(int projectId) async {
    final db = await database;
    final maps = await db.query('openings', where: 'project_id = ?', whereArgs: [projectId], orderBy: 'id ASC');
    return List.generate(maps.length, (i) => Opening.fromMap(maps[i]));
  }

  // توليد الترقيم التلقائي W01 أو D01
  static Future<String> generateNextCode(int projectId, String type) async {
    final db = await database;
    final prefix = type == 'نافذة' ? 'W' : 'D';
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM openings WHERE project_id = ? AND type = ?',
      [projectId, type],
    );
    int count = Sqflite.firstIntValue(result) ?? 0;
    return '$prefix${(count + 1).toString().padLeft(2, '0')}';
  }
}
