import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/loan_model.dart';
import '../models/investment_model.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();
  static DatabaseService get instance => _instance ??= DatabaseService._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Returns the Finzo directory inside Documents
  static Future<String> get finzoDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'finzo'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Returns the full path for a given book name
  static Future<String> pathForBook(String bookName) async {
    final dir = await finzoDir;
    final safe = bookName.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
    return p.join(dir, '$safe.books.db');
  }

  /// List all .books.db files in finzo directory
  static Future<List<String>> listBooks() async {
    final dir = Directory(await finzoDir);
    if (!await dir.exists()) return [];
    final files = await dir
        .list()
        .where((f) => f.path.endsWith('.books.db'))
        .map((f) => p.basenameWithoutExtension(f.path).replaceAll('.books', ''))
        .toList();
    return files;
  }

  /// Open a specific book database by name
  Future<void> openBook(String bookName) async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final path = await pathForBook(bookName);
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create a new book database
  Future<void> createBook(String bookName) async {
    await openBook(bookName);
  }

  /// Import a .books.db file from the given source path
  static Future<String> importBook(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) throw Exception('File not found');
    final name = p
        .basenameWithoutExtension(sourcePath)
        .replaceAll('.books', '');
    final destPath = await pathForBook(name);
    await file.copy(destPath);
    return name;
  }

  Future<Database> _initDatabase() async {
    // Default: open first available book, or create 'default'
    final books = await listBooks();
    final bookName = books.isNotEmpty ? books.first : 'default';
    final path = await pathForBook(bookName);

    return openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      )
    ''');

    // Index for faster transaction queries
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(date DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions(type)',
    );

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await _createV2Tables(db);
    await _createV3Tables(db);
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
    if (oldVersion < 3) {
      await _createV3Tables(db);
    }
  }

  Future<void> _createV3Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS credit_cards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        card_number_last4 TEXT NOT NULL,
        credit_limit REAL NOT NULL,
        used_amount REAL NOT NULL DEFAULT 0,
        billing_day INTEGER NOT NULL DEFAULT 1,
        due_day INTEGER NOT NULL DEFAULT 15,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL DEFAULT '💳',
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS loans (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        principal_amount REAL NOT NULL,
        outstanding_amount REAL NOT NULL,
        interest_rate REAL NOT NULL,
        tenure_months INTEGER NOT NULL,
        emi_amount REAL NOT NULL,
        emi_day INTEGER NOT NULL DEFAULT 1,
        start_date TEXT NOT NULL,
        end_date TEXT,
        account_id TEXT,
        auto_emi INTEGER NOT NULL DEFAULT 1,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS investments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        invested_amount REAL NOT NULL,
        current_value REAL NOT NULL,
        units REAL,
        buy_price REAL,
        current_price REAL,
        start_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS emi_log (
        id TEXT PRIMARY KEY,
        loan_id TEXT NOT NULL,
        transaction_id TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        FOREIGN KEY (loan_id) REFERENCES loans(id),
        FOREIGN KEY (transaction_id) REFERENCES transactions(id)
      )
    ''');

    // Default currency
    await db.insert('settings', {
      'key': 'currency',
      'value': 'INR',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final expenseCategories = [
      {
        'id': 'cat_food',
        'name': 'Food & Dining',
        'icon': '🍔',
        'color': 0xFFFF6B6B,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_transport',
        'name': 'Transport',
        'icon': '🚗',
        'color': 0xFF4ECDC4,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_shop',
        'name': 'Shopping',
        'icon': '🛍️',
        'color': 0xFF45B7D1,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_bills',
        'name': 'Bills & Utilities',
        'icon': '💡',
        'color': 0xFFF7DC6F,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_health',
        'name': 'Health',
        'icon': '🏥',
        'color': 0xFF82E0AA,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_entertain',
        'name': 'Entertainment',
        'icon': '🎮',
        'color': 0xFFBB8FCE,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_edu',
        'name': 'Education',
        'icon': '📚',
        'color': 0xFFFF8C42,
        'type': 'expense',
        'is_default': 1,
      },
      {
        'id': 'cat_other_exp',
        'name': 'Other',
        'icon': '📦',
        'color': 0xFF95A5A6,
        'type': 'expense',
        'is_default': 1,
      },
    ];

    final incomeCategories = [
      {
        'id': 'cat_salary',
        'name': 'Salary',
        'icon': '💼',
        'color': 0xFF2ECC71,
        'type': 'income',
        'is_default': 1,
      },
      {
        'id': 'cat_freelance',
        'name': 'Freelance',
        'icon': '💻',
        'color': 0xFF3498DB,
        'type': 'income',
        'is_default': 1,
      },
      {
        'id': 'cat_invest',
        'name': 'Investment',
        'icon': '📈',
        'color': 0xFF1ABC9C,
        'type': 'income',
        'is_default': 1,
      },
      {
        'id': 'cat_gift',
        'name': 'Gift',
        'icon': '🎁',
        'color': 0xFFE91E63,
        'type': 'income',
        'is_default': 1,
      },
      {
        'id': 'cat_other_inc',
        'name': 'Other Income',
        'icon': '💰',
        'color': 0xFFF39C12,
        'type': 'income',
        'is_default': 1,
      },
    ];

    final batch = db.batch();
    for (final cat in [...expenseCategories, ...incomeCategories]) {
      batch.insert('categories', cat);
    }

    batch.insert('accounts', {
      'id': 'acc_cash',
      'name': 'Cash',
      'balance': 0.0,
      'color': 0xFF6C63FF,
      'icon': '💵',
      'created_at': now,
    });

    batch.insert('accounts', {
      'id': 'acc_bank',
      'name': 'Bank Account',
      'balance': 0.0,
      'color': 0xFF4CAF50,
      'icon': '🏦',
      'created_at': now,
    });

    await batch.commit(noResult: true);
  }

  // ─── TRANSACTIONS ────────────────────────────────────────────────────────

  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? accountId,
    String? categoryId,
  }) async {
    final db = await database;
    final whereParts = <String>[];
    final args = <dynamic>[];

    if (startDate != null) {
      whereParts.add('date >= ?');
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereParts.add('date <= ?');
      args.add(endDate.toIso8601String());
    }
    if (type != null) {
      whereParts.add('type = ?');
      args.add(type);
    }
    if (accountId != null) {
      whereParts.add('account_id = ?');
      args.add(accountId);
    }
    if (categoryId != null) {
      whereParts.add('category_id = ?');
      args.add(categoryId);
    }

    final maps = await db.query(
      'transactions',
      where: whereParts.isEmpty ? null : whereParts.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, created_at DESC',
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<String> insertTransaction(TransactionModel tx) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('transactions', tx.toMap());

      final delta = tx.type == 'income' ? tx.amount : -tx.amount;
      await txn.rawUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        [delta, tx.accountId],
      );

      await _updateBudgetSpentInTxn(
        txn,
        tx.categoryId,
        tx.date.month,
        tx.date.year,
      );
    });
    return tx.id;
  }

  Future<void> updateTransaction(
    TransactionModel oldTx,
    TransactionModel newTx,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Reverse old balance
      final oldDelta = oldTx.type == 'income' ? -oldTx.amount : oldTx.amount;
      await txn.rawUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        [oldDelta, oldTx.accountId],
      );

      // Apply new balance
      final newDelta = newTx.type == 'income' ? newTx.amount : -newTx.amount;
      await txn.rawUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        [newDelta, newTx.accountId],
      );

      await txn.update(
        'transactions',
        newTx.toMap(),
        where: 'id = ?',
        whereArgs: [newTx.id],
      );

      await _updateBudgetSpentInTxn(
        txn,
        oldTx.categoryId,
        oldTx.date.month,
        oldTx.date.year,
      );
      if (oldTx.categoryId != newTx.categoryId ||
          oldTx.date.month != newTx.date.month ||
          oldTx.date.year != newTx.date.year) {
        await _updateBudgetSpentInTxn(
          txn,
          newTx.categoryId,
          newTx.date.month,
          newTx.date.year,
        );
      }
    });
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    final db = await database;
    await db.transaction((txn) async {
      final delta = tx.type == 'income' ? -tx.amount : tx.amount;
      await txn.rawUpdate(
        'UPDATE accounts SET balance = balance + ? WHERE id = ?',
        [delta, tx.accountId],
      );

      await txn.delete('transactions', where: 'id = ?', whereArgs: [tx.id]);
      await _updateBudgetSpentInTxn(
        txn,
        tx.categoryId,
        tx.date.month,
        tx.date.year,
      );
    });
  }

  Future<Map<String, double>> getMonthlySummary(int month, int year) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final incomeResult = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as val FROM transactions WHERE type = ? AND date >= ? AND date < ?',
      ['income', start, end],
    );
    final expenseResult = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as val FROM transactions WHERE type = ? AND date >= ? AND date < ?',
      ['expense', start, end],
    );

    return {
      'income': (incomeResult.first['val'] as num).toDouble(),
      'expense': (expenseResult.first['val'] as num).toDouble(),
    };
  }

  Future<List<Map<String, dynamic>>> getCategorySpending(
    int month,
    int year,
  ) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    return db.rawQuery(
      '''
      SELECT c.id, c.name, c.icon, c.color, COALESCE(SUM(t.amount), 0) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = ? AND t.date >= ? AND t.date < ?
      GROUP BY c.id
      ORDER BY total DESC
    ''',
      ['expense', start, end],
    );
  }

  Future<List<Map<String, dynamic>>> getLast6MonthsSummary() async {
    final db = await database;
    final results = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final start = date.toIso8601String();
      final end = DateTime(date.year, date.month + 1, 1).toIso8601String();

      final income = (await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0.0) as val FROM transactions WHERE type = ? AND date >= ? AND date < ?',
        ['income', start, end],
      )).first['val'];

      final expense = (await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0.0) as val FROM transactions WHERE type = ? AND date >= ? AND date < ?',
        ['expense', start, end],
      )).first['val'];

      results.add({
        'month': date.month,
        'year': date.year,
        'income': (income as num).toDouble(),
        'expense': (expense as num).toDouble(),
      });
    }

    return results;
  }

  // ─── ACCOUNTS ────────────────────────────────────────────────────────────

  Future<List<AccountModel>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts', orderBy: 'created_at ASC');
    return maps.map((m) => AccountModel.fromMap(m)).toList();
  }

  Future<void> insertAccount(AccountModel account) async {
    final db = await database;
    await db.insert('accounts', account.toMap());
  }

  Future<void> updateAccount(AccountModel account) async {
    final db = await database;
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────────

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await database;
    String? where;
    List<dynamic>? args;
    if (type != null) {
      where = 'type = ? OR type = ?';
      args = [type, 'both'];
    }
    final maps = await db.query(
      'categories',
      where: where,
      whereArgs: args,
      orderBy: 'is_default DESC, name ASC',
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<void> insertCategory(CategoryModel category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ─── BUDGETS ─────────────────────────────────────────────────────────────

  Future<List<BudgetModel>> getBudgets(int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  Future<void> insertBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap());
    await _updateBudgetSpent(db, budget.categoryId, budget.month, budget.year);
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final db = await database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Future<void> _updateBudgetSpent(
    Database db,
    String categoryId,
    int month,
    int year,
  ) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE category_id = ? AND type = ? AND date >= ? AND date < ?',
      [categoryId, 'expense', start, end],
    );

    final total = (result.first['total'] as num).toDouble();
    await db.rawUpdate(
      'UPDATE budgets SET spent = ? WHERE category_id = ? AND month = ? AND year = ?',
      [total, categoryId, month, year],
    );
  }

  Future<void> _updateBudgetSpentInTxn(
    Transaction txn,
    String categoryId,
    int month,
    int year,
  ) async {
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();

    final result = await txn.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE category_id = ? AND type = ? AND date >= ? AND date < ?',
      [categoryId, 'expense', start, end],
    );

    final total = (result.first['total'] as num).toDouble();
    await txn.rawUpdate(
      'UPDATE budgets SET spent = ? WHERE category_id = ? AND month = ? AND year = ?',
      [total, categoryId, month, year],
    );
  }

  // ─── LOANS ───────────────────────────────────────────────────────────────

  Future<List<LoanModel>> getLoans() async {
    final db = await database;
    final maps = await db.query('loans', orderBy: 'created_at DESC');
    return maps.map((m) => LoanModel.fromMap(m)).toList();
  }

  Future<void> insertLoan(LoanModel loan) async {
    final db = await database;
    await db.insert('loans', loan.toMap());
  }

  Future<void> updateLoan(LoanModel loan) async {
    final db = await database;
    await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  Future<void> deleteLoan(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('emi_log', where: 'loan_id = ?', whereArgs: [id]);
      await txn.delete('loans', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ─── INVESTMENTS ─────────────────────────────────────────────────────────

  Future<List<InvestmentModel>> getInvestments() async {
    final db = await database;
    final maps = await db.query('investments', orderBy: 'created_at DESC');
    return maps.map((m) => InvestmentModel.fromMap(m)).toList();
  }

  Future<void> insertInvestment(InvestmentModel inv) async {
    final db = await database;
    await db.insert('investments', inv.toMap());
  }

  Future<void> updateInvestment(InvestmentModel inv) async {
    final db = await database;
    await db.update(
      'investments',
      inv.toMap(),
      where: 'id = ?',
      whereArgs: [inv.id],
    );
  }

  Future<void> deleteInvestment(String id) async {
    final db = await database;
    await db.delete('investments', where: 'id = ?', whereArgs: [id]);
  }

  // ─── SETTINGS ────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── AUTO EMI ────────────────────────────────────────────────────────────

  Future<bool> hasEmiForMonth(String loanId, int month, int year) async {
    final db = await database;
    final result = await db.query(
      'emi_log',
      where: 'loan_id = ? AND month = ? AND year = ?',
      whereArgs: [loanId, month, year],
    );
    return result.isNotEmpty;
  }

  Future<void> processAutoEmis() async {
    final db = await database;
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    final loans = await getLoans();
    const uuid = Uuid();

    for (final loan in loans) {
      if (!loan.autoEmi) continue;
      if (loan.outstandingAmount <= 0) continue;
      if (loan.accountId == null) continue;
      if (now.day < loan.emiDay) continue;

      final already = await hasEmiForMonth(loan.id, month, year);
      if (already) continue;

      final txId = uuid.v4();
      final tx = TransactionModel(
        id: txId,
        title: 'EMI - ${loan.name}',
        amount: loan.emiAmount,
        type: 'expense',
        categoryId: 'cat_bills',
        accountId: loan.accountId!,
        date: DateTime(year, month, loan.emiDay),
        note: 'Auto EMI for ${loan.type.label}',
        createdAt: now,
      );

      await db.transaction((txn) async {
        await txn.insert('transactions', tx.toMap());

        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance - ? WHERE id = ?',
          [loan.emiAmount, loan.accountId],
        );

        final newOutstanding = (loan.outstandingAmount - loan.emiAmount).clamp(
          0.0,
          double.infinity,
        );
        await txn.rawUpdate(
          'UPDATE loans SET outstanding_amount = ? WHERE id = ?',
          [newOutstanding, loan.id],
        );

        await txn.insert('emi_log', {
          'id': uuid.v4(),
          'loan_id': loan.id,
          'transaction_id': txId,
          'month': month,
          'year': year,
        });

        await _updateBudgetSpentInTxn(txn, 'cat_bills', month, year);
      });
    }
  }

  // ─── CREDIT CARDS ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCreditCards() async {
    final db = await database;
    return db.query('credit_cards', orderBy: 'created_at DESC');
  }

  Future<void> insertCreditCard(Map<String, dynamic> card) async {
    final db = await database;
    await db.insert('credit_cards', card);
  }

  Future<void> updateCreditCard(Map<String, dynamic> card) async {
    final db = await database;
    await db.update(
      'credit_cards',
      card,
      where: 'id = ?',
      whereArgs: [card['id']],
    );
  }

  Future<void> deleteCreditCard(String id) async {
    final db = await database;
    await db.delete('credit_cards', where: 'id = ?', whereArgs: [id]);
  }
}
