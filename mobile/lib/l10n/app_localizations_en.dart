// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Manager';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get balance => 'Balance';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String greeting(String timeOfDay, String name) {
    return 'Good $timeOfDay, $name!';
  }

  @override
  String get morning => 'morning';

  @override
  String get afternoon => 'afternoon';

  @override
  String get evening => 'evening';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get note => 'Note';

  @override
  String get date => 'Date';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get custom => 'Custom';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsHint => 'Tap + to add your first transaction';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalSaved => 'Total Saved';

  @override
  String get averagePerDay => 'Average/Day';

  @override
  String get largestExpense => 'Largest Expense';

  @override
  String get byCategory => 'By Category';

  @override
  String get byTime => 'By Time';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get currency => 'Currency';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataConfirm =>
      'Are you sure you want to delete all data? This action cannot be undone.';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get undo => 'Undo';

  @override
  String get offline => 'Offline — data will sync when connected';

  @override
  String get categoryFood => 'Food & Drink';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryBills => 'Bills & Utilities';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryGift => 'Gift';

  @override
  String get categoryInvestment => 'Investment';

  @override
  String get categoryOtherIncome => 'Other Income';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get enterNote => 'Enter note (optional)';

  @override
  String get selectCategory => 'Select category';

  @override
  String get selectDate => 'Select date';

  @override
  String get amountRequired => 'Please enter an amount';

  @override
  String get categoryRequired => 'Please select a category';

  @override
  String get welcome => 'Smart Expense Manager';

  @override
  String get welcomeSubtitle => 'Track spending, save effectively';

  @override
  String get categoryManagement => 'Category Management';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get debts => 'Debts';

  @override
  String get paymentReminders => 'Payment Reminders';

  @override
  String get budget => 'Budget';

  @override
  String get noBudgets => 'No budgets yet';

  @override
  String get noBudgetsHint => 'Tap + to add a category budget';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get budgetLimit => 'Limit (VND)';

  @override
  String get newBudgetLimit => 'New limit';

  @override
  String get overBudget => 'Over!';

  @override
  String get pinToHome => 'Pin to home';

  @override
  String get unpin => 'Unpin';

  @override
  String get editLimit => 'Edit limit';

  @override
  String get savingsGoalSearch => 'Search goals…';

  @override
  String get noSavingsGoals => 'No goals yet';

  @override
  String get noSavingsGoalsHint => 'Tap + to add a savings goal';

  @override
  String get notFound => 'Not found';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHint => 'E.g. Beach vacation';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get createGoal => 'Create Goal';

  @override
  String depositTo(String name) {
    return 'Deposit to \"$name\"';
  }

  @override
  String get depositAmount => 'Deposit amount';

  @override
  String get deposit => 'Deposit';

  @override
  String remainingAmount(String amount) {
    return '$amount remaining';
  }

  @override
  String get goalReached => '🎉 Goal reached!';

  @override
  String get debtLedger => 'Debt Ledger';

  @override
  String get searchByName => 'Search by name…';

  @override
  String get nobodyOwesYou => 'Nobody owes you';

  @override
  String get youDontOweAnyone => 'You don\'t owe anyone';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get editDebt => 'Edit Debt';

  @override
  String get lend => 'Lend';

  @override
  String get borrow => 'Borrow';

  @override
  String get personName => 'Person name';

  @override
  String get personNameHint => 'E.g. John Smith';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get selectDueDate => 'Select due date';

  @override
  String dueDate(String date) {
    return 'Due: $date';
  }

  @override
  String get markPaid => 'Mark as paid';

  @override
  String get add => 'Add';

  @override
  String get paymentReminderSearch => 'Search reminders…';

  @override
  String get noReminders => 'No reminders yet';

  @override
  String get noRemindersHint => 'Add monthly bills so you never forget';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get billName => 'Bill name';

  @override
  String get billNameHint => 'E.g. Electricity, Internet';

  @override
  String get paymentDay => 'Payment day (1-31)';

  @override
  String get paymentDayHint => 'E.g. 15';

  @override
  String monthlyOnDay(int day) {
    return 'Monthly on day $day';
  }

  @override
  String get overdueLabel => 'Overdue!';

  @override
  String get dueSoonLabel => 'Due soon';

  @override
  String get categoryManagementTitle => 'Category Management';

  @override
  String get expenseSection => 'Expense';

  @override
  String get incomeSection => 'Income';

  @override
  String get defaultCategory => 'Default';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get addCategoryTitle => 'Add Category';

  @override
  String get categoryNameHint => 'Category name';

  @override
  String get selectIcon => 'Select icon';

  @override
  String get selectColor => 'Select color';

  @override
  String get noBudgetForCategory => 'No budget set for this category';

  @override
  String jarOver(String amount) {
    return 'Over $amount';
  }

  @override
  String jarRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String get about => 'About';

  @override
  String get aboutDeveloper => 'Developer Info';

  @override
  String get aboutUniversity => 'University';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldStudentId => 'Student ID';

  @override
  String get fieldClass => 'Class';

  @override
  String get fieldUniversityName => 'University';

  @override
  String get fieldMajor => 'Major';

  @override
  String get fieldBatch => 'Batch';

  @override
  String get appVersion => 'Version 1.0.0';
}
