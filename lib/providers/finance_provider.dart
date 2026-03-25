import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/loan_model.dart';
import '../models/investment_model.dart';
import '../models/currency_model.dart';
import '../models/credit_card_model.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';

class FinanceProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;

  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  List<CategoryModel> _categories = [];
  List<BudgetModel> _budgets = [];
  List<LoanModel> _loans = [];
  List<InvestmentModel> _investments = [];
  List<CreditCardModel> _creditCards = [];
  List<Map<String, dynamic>> _last6Months = [];
  List<Map<String, dynamic>> _categorySpending = [];

  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();
  CurrencyModel _currency = CurrencyModel.supported.first;
  String _userName = '';

  // ─── GETTERS ─────────────────────────────────────────────────────────────

  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  List<CategoryModel> get categories => _categories;
  List<BudgetModel> get budgets => _budgets;
  List<LoanModel> get loans => _loans;
  List<InvestmentModel> get investments => _investments;
  List<CreditCardModel> get creditCards => _creditCards;
  List<Map<String, dynamic>> get last6Months => _last6Months;
  List<Map<String, dynamic>> get categorySpending => _categorySpending;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;
  CurrencyModel get currency => _currency;
  String get userName => _userName;

  double get totalBalance => _accounts.fold(0.0, (sum, a) => sum + a.balance);

  double get totalLoanOutstanding =>
      _loans.fold(0.0, (sum, l) => sum + l.outstandingAmount);

  double get totalInvestedAmount =>
      _investments.fold(0.0, (sum, i) => sum + i.investedAmount);

  double get totalInvestmentValue =>
      _investments.fold(0.0, (sum, i) => sum + i.currentValue);

  double get netWorth =>
      totalBalance + totalInvestmentValue - totalLoanOutstanding;

  double get monthlyIncome => _transactions
      .where(
        (t) =>
            t.type == 'income' &&
            t.date.month == _selectedMonth.month &&
            t.date.year == _selectedMonth.year,
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyExpense => _transactions
      .where(
        (t) =>
            t.type == 'expense' &&
            t.date.month == _selectedMonth.month &&
            t.date.year == _selectedMonth.year,
      )
      .fold(0.0, (sum, t) => sum + t.amount);

  List<TransactionModel> get recentTransactions =>
      _transactions.take(20).toList();

  List<TransactionModel> get currentMonthTransactions => _transactions
      .where(
        (t) =>
            t.date.month == _selectedMonth.month &&
            t.date.year == _selectedMonth.year,
      )
      .toList();

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  AccountModel? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── INIT ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await _loadCurrency();
    await _loadUserName();
    await _loadAll();
    await _db.processAutoEmis();
    await _loadAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserName() async {
    _userName = (await _db.getSetting('user_name')) ?? '';
  }

  Future<void> setUserName(String name) async {
    await _db.setSetting('user_name', name);
    _userName = name;
    notifyListeners();
  }

  Future<void> _loadCurrency() async {
    final code = await _db.getSetting('currency');
    if (code != null) {
      _currency = CurrencyModel.fromCode(code);
    }
    Formatters.setCurrency(_currency);
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadAccounts(),
      _loadCategories(),
      _loadTransactions(),
      _loadBudgets(),
      _loadAnalytics(),
      _loadLoans(),
      _loadInvestments(),
      _loadCreditCards(),
    ]);
  }

  Future<void> _loadTransactions() async {
    _transactions = await _db.getTransactions();
  }

  Future<void> _loadAccounts() async {
    _accounts = await _db.getAccounts();
  }

  Future<void> _loadCategories() async {
    _categories = await _db.getCategories();
  }

  Future<void> _loadBudgets() async {
    _budgets = await _db.getBudgets(_selectedMonth.month, _selectedMonth.year);
  }

  Future<void> _loadAnalytics() async {
    _last6Months = await _db.getLast6MonthsSummary();
    _categorySpending = await _db.getCategorySpending(
      _selectedMonth.month,
      _selectedMonth.year,
    );
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    _loadBudgets();
    _loadAnalytics();
    notifyListeners();
  }

  // ─── TRANSACTIONS ────────────────────────────────────────────────────────

  Future<void> addTransaction(TransactionModel tx) async {
    await _db.insertTransaction(tx);
    await _loadAll();
    notifyListeners();
  }

  Future<void> editTransaction(
    TransactionModel oldTx,
    TransactionModel newTx,
  ) async {
    await _db.updateTransaction(oldTx, newTx);
    await _loadAll();
    notifyListeners();
  }

  Future<void> removeTransaction(TransactionModel tx) async {
    await _db.deleteTransaction(tx);
    await _loadAll();
    notifyListeners();
  }

  // ─── ACCOUNTS ────────────────────────────────────────────────────────────

  Future<void> addAccount(AccountModel account) async {
    await _db.insertAccount(account);
    await _loadAccounts();
    notifyListeners();
  }

  Future<void> editAccount(AccountModel account) async {
    await _db.updateAccount(account);
    await _loadAccounts();
    notifyListeners();
  }

  Future<void> removeAccount(String id) async {
    await _db.deleteAccount(id);
    await _loadAccounts();
    notifyListeners();
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────────

  Future<void> addCategory(CategoryModel category) async {
    await _db.insertCategory(category);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> removeCategory(String id) async {
    await _db.deleteCategory(id);
    await _loadCategories();
    notifyListeners();
  }

  // ─── BUDGETS ─────────────────────────────────────────────────────────────

  Future<void> addBudget(BudgetModel budget) async {
    await _db.insertBudget(budget);
    await _loadBudgets();
    notifyListeners();
  }

  Future<void> editBudget(BudgetModel budget) async {
    await _db.updateBudget(budget);
    await _loadBudgets();
    notifyListeners();
  }

  Future<void> removeBudget(String id) async {
    await _db.deleteBudget(id);
    await _loadBudgets();
    notifyListeners();
  }

  List<CategoryModel> getCategoriesForType(String type) {
    return _categories
        .where((c) => c.type == type || c.type == 'both')
        .toList();
  }

  // ─── LOANS ───────────────────────────────────────────────────────────────

  Future<void> _loadLoans() async {
    _loans = await _db.getLoans();
  }

  Future<void> addLoan(LoanModel loan) async {
    await _db.insertLoan(loan);
    await _loadLoans();
    notifyListeners();
  }

  Future<void> editLoan(LoanModel loan) async {
    await _db.updateLoan(loan);
    await _loadLoans();
    notifyListeners();
  }

  Future<void> removeLoan(String id) async {
    await _db.deleteLoan(id);
    await _loadLoans();
    notifyListeners();
  }

  // ─── INVESTMENTS ─────────────────────────────────────────────────────────

  Future<void> _loadInvestments() async {
    _investments = await _db.getInvestments();
  }

  Future<void> addInvestment(InvestmentModel inv) async {
    await _db.insertInvestment(inv);
    await _loadInvestments();
    notifyListeners();
  }

  Future<void> editInvestment(InvestmentModel inv) async {
    await _db.updateInvestment(inv);
    await _loadInvestments();
    notifyListeners();
  }

  Future<void> removeInvestment(String id) async {
    await _db.deleteInvestment(id);
    await _loadInvestments();
    notifyListeners();
  }

  // ─── CREDIT CARDS ────────────────────────────────────────────────────────

  Future<void> _loadCreditCards() async {
    final maps = await _db.getCreditCards();
    _creditCards = maps.map((m) => CreditCardModel.fromMap(m)).toList();
  }

  Future<void> addCreditCard(CreditCardModel card) async {
    await _db.insertCreditCard(card.toMap());
    await _loadCreditCards();
    notifyListeners();
  }

  Future<void> editCreditCard(CreditCardModel card) async {
    await _db.updateCreditCard(card.toMap());
    await _loadCreditCards();
    notifyListeners();
  }

  Future<void> removeCreditCard(String id) async {
    await _db.deleteCreditCard(id);
    await _loadCreditCards();
    notifyListeners();
  }

  // ─── SETTINGS / CURRENCY ─────────────────────────────────────────────────

  Future<void> setCurrency(CurrencyModel cur) async {
    await _db.setSetting('currency', cur.code);
    _currency = cur;
    Formatters.setCurrency(cur);
    notifyListeners();
  }
}
