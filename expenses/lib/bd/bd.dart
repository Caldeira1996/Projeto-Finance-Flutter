import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  // Nome da tabela e campos como constantes estáticas
  static const String tableTransactions = 'transactions';
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnValue = 'value';
  static const String columnDate = 'date';
  static const String columnIsSynced = 'isSynced';

  Future<Database> _initDB(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, fileName);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Adiciona suporte para migração
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnValue REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0 
      )
    ''');
  }
  //0 = pendente, 1 = sincronizando em Synced

  // Atualiza a estrutura do banco ao mudar a versão
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableTransactions ADD COLUMN $columnIsSynced INTEGERT NOT NULL DEFAULT 0',
      );
    }
  }

  Future insertTransaction(
    Transaction transaction, {
    bool isSynced = false,
  }) async {
    final db = await database;
    await db.insert(tableTransactions, {
      columnId: transaction.id,
      columnTitle: transaction.title,
      columnValue: transaction.value,
      columnDate: transaction.date.toIso8601String(),
      columnIsSynced: isSynced ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableTransactions);
    //return List.generate(maps.length, (i) {
    return maps.map((map) {
      return Transaction(
        id: map[columnId],
        title: map[columnTitle],
        value: map[columnValue],
        date: DateTime.parse(map[columnDate]),
      );
    }).toList();
  }

  // Obtém apenas transações pendentes de sincronização
  Future<List<Transaction>> getPendingTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTransactions,
      where: '$columnIsSynced = ?',
      whereArgs: [0],
    );
    return maps.map((map) {
      return Transaction(
        id: map[columnId],
        title: map[columnTitle],
        value: map[columnValue],
        date: DateTime.parse(map[columnDate]),
      );
    }).toList();
  }

  Future<void> markTransactionsAsSynced(String id) async {
    final db = await database;
    await db.update(
      tableTransactions,
      {columnIsSynced: 1},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(tableTransactions, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
