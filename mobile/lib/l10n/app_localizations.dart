import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản Lý Chi Tiêu'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get transactions;

  /// No description provided for @reports.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @totalIncome.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thu'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chi'**
  String get totalExpense;

  /// No description provided for @balance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư'**
  String get balance;

  /// No description provided for @addTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Sửa giao dịch'**
  String get editTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giao dịch'**
  String get deleteTransaction;

  /// No description provided for @greeting.
  ///
  /// In vi, this message translates to:
  /// **'Chào {timeOfDay}, {name}!'**
  String greeting(String timeOfDay, String name);

  /// No description provided for @morning.
  ///
  /// In vi, this message translates to:
  /// **'buổi sáng'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In vi, this message translates to:
  /// **'buổi chiều'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In vi, this message translates to:
  /// **'buổi tối'**
  String get evening;

  /// No description provided for @amount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @note.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get note;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @income.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expense;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc'**
  String get filter;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm nay'**
  String get thisYear;

  /// No description provided for @custom.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn'**
  String get custom;

  /// No description provided for @noTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch nào'**
  String get noTransactions;

  /// No description provided for @noTransactionsHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn + để thêm giao dịch đầu tiên'**
  String get noTransactionsHint;

  /// No description provided for @recentTransactions.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch gần đây'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @statistics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statistics;

  /// No description provided for @totalSaved.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm'**
  String get totalSaved;

  /// No description provided for @averagePerDay.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình/ngày'**
  String get averagePerDay;

  /// No description provided for @largestExpense.
  ///
  /// In vi, this message translates to:
  /// **'Chi lớn nhất'**
  String get largestExpense;

  /// No description provided for @byCategory.
  ///
  /// In vi, this message translates to:
  /// **'Theo danh mục'**
  String get byCategory;

  /// No description provided for @byTime.
  ///
  /// In vi, this message translates to:
  /// **'Theo thời gian'**
  String get byTime;

  /// No description provided for @week.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get week;

  /// No description provided for @month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get month;

  /// No description provided for @year.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get year;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện tối'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện sáng'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get systemMode;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @currency.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị tiền tệ'**
  String get currency;

  /// No description provided for @account.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @signIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signIn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập với Google'**
  String get signInWithGoogle;

  /// No description provided for @signOutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn đăng xuất?'**
  String get signOutConfirm;

  /// No description provided for @deleteAllData.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả dữ liệu'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa tất cả dữ liệu? Hành động này không thể hoàn tác.'**
  String get deleteAllDataConfirm;

  /// No description provided for @transactionAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm giao dịch'**
  String get transactionAdded;

  /// No description provided for @transactionUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật giao dịch'**
  String get transactionUpdated;

  /// No description provided for @transactionDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa giao dịch'**
  String get transactionDeleted;

  /// No description provided for @undo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// No description provided for @offline.
  ///
  /// In vi, this message translates to:
  /// **'Đang offline — dữ liệu sẽ đồng bộ khi có mạng'**
  String get offline;

  /// No description provided for @categoryFood.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In vi, this message translates to:
  /// **'Đi lại'**
  String get categoryTransport;

  /// No description provided for @categoryHousing.
  ///
  /// In vi, this message translates to:
  /// **'Nhà cửa'**
  String get categoryHousing;

  /// No description provided for @categoryShopping.
  ///
  /// In vi, this message translates to:
  /// **'Mua sắm'**
  String get categoryShopping;

  /// No description provided for @categoryEntertainment.
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In vi, this message translates to:
  /// **'Giáo dục'**
  String get categoryEducation;

  /// No description provided for @categoryBills.
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn & Tiện ích'**
  String get categoryBills;

  /// No description provided for @categorySalary.
  ///
  /// In vi, this message translates to:
  /// **'Lương'**
  String get categorySalary;

  /// No description provided for @categoryGift.
  ///
  /// In vi, this message translates to:
  /// **'Quà tặng'**
  String get categoryGift;

  /// No description provided for @categoryInvestment.
  ///
  /// In vi, this message translates to:
  /// **'Đầu tư'**
  String get categoryInvestment;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập khác'**
  String get categoryOtherIncome;

  /// No description provided for @enterAmount.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền'**
  String get enterAmount;

  /// No description provided for @enterNote.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú (tùy chọn)'**
  String get enterNote;

  /// No description provided for @selectCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get selectCategory;

  /// No description provided for @selectDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get selectDate;

  /// No description provided for @amountRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số tiền'**
  String get amountRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn danh mục'**
  String get categoryRequired;

  /// No description provided for @welcome.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý chi tiêu thông minh'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi thu chi, tiết kiệm hiệu quả'**
  String get welcomeSubtitle;

  /// No description provided for @categoryManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý danh mục'**
  String get categoryManagement;

  /// No description provided for @savingsGoals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu tiết kiệm'**
  String get savingsGoals;

  /// No description provided for @debts.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ'**
  String get debts;

  /// No description provided for @paymentReminders.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc thanh toán'**
  String get paymentReminders;

  /// No description provided for @budget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách'**
  String get budget;

  /// No description provided for @noBudgets.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ngân sách nào'**
  String get noBudgets;

  /// No description provided for @noBudgetsHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn + để thêm ngân sách cho danh mục'**
  String get noBudgetsHint;

  /// No description provided for @addBudget.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ngân sách'**
  String get addBudget;

  /// No description provided for @budgetLimit.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức (VND)'**
  String get budgetLimit;

  /// No description provided for @newBudgetLimit.
  ///
  /// In vi, this message translates to:
  /// **'Hạn mức mới'**
  String get newBudgetLimit;

  /// No description provided for @overBudget.
  ///
  /// In vi, this message translates to:
  /// **'Vượt!'**
  String get overBudget;

  /// No description provided for @pinToHome.
  ///
  /// In vi, this message translates to:
  /// **'Ghim ra trang chủ'**
  String get pinToHome;

  /// No description provided for @unpin.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ghim'**
  String get unpin;

  /// No description provided for @editLimit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa hạn mức'**
  String get editLimit;

  /// No description provided for @savingsGoalSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm mục tiêu...'**
  String get savingsGoalSearch;

  /// No description provided for @noSavingsGoals.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mục tiêu nào'**
  String get noSavingsGoals;

  /// No description provided for @noSavingsGoalsHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn + để thêm mục tiêu tiết kiệm'**
  String get noSavingsGoalsHint;

  /// No description provided for @notFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy'**
  String get notFound;

  /// No description provided for @addGoal.
  ///
  /// In vi, this message translates to:
  /// **'Thêm mục tiêu'**
  String get addGoal;

  /// No description provided for @editGoal.
  ///
  /// In vi, this message translates to:
  /// **'Sửa mục tiêu'**
  String get editGoal;

  /// No description provided for @goalName.
  ///
  /// In vi, this message translates to:
  /// **'Tên mục tiêu'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Du lịch Đà Nẵng'**
  String get goalNameHint;

  /// No description provided for @targetAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền mục tiêu'**
  String get targetAmount;

  /// No description provided for @createGoal.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mục tiêu'**
  String get createGoal;

  /// No description provided for @depositTo.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền vào \"{name}\"'**
  String depositTo(String name);

  /// No description provided for @depositAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền nạp'**
  String get depositAmount;

  /// No description provided for @deposit.
  ///
  /// In vi, this message translates to:
  /// **'Nạp tiền'**
  String get deposit;

  /// No description provided for @remainingAmount.
  ///
  /// In vi, this message translates to:
  /// **'Còn thiếu {amount}'**
  String remainingAmount(String amount);

  /// No description provided for @goalReached.
  ///
  /// In vi, this message translates to:
  /// **'🎉 Đã đạt mục tiêu!'**
  String get goalReached;

  /// No description provided for @debtLedger.
  ///
  /// In vi, this message translates to:
  /// **'Sổ nợ'**
  String get debtLedger;

  /// No description provided for @searchByName.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên người...'**
  String get searchByName;

  /// No description provided for @nobodyOwesYou.
  ///
  /// In vi, this message translates to:
  /// **'Không ai nợ bạn'**
  String get nobodyOwesYou;

  /// No description provided for @youDontOweAnyone.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không nợ ai'**
  String get youDontOweAnyone;

  /// No description provided for @addDebt.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khoản nợ'**
  String get addDebt;

  /// No description provided for @editDebt.
  ///
  /// In vi, this message translates to:
  /// **'Sửa khoản nợ'**
  String get editDebt;

  /// No description provided for @lend.
  ///
  /// In vi, this message translates to:
  /// **'Cho vay'**
  String get lend;

  /// No description provided for @borrow.
  ///
  /// In vi, this message translates to:
  /// **'Đi vay'**
  String get borrow;

  /// No description provided for @personName.
  ///
  /// In vi, this message translates to:
  /// **'Tên người'**
  String get personName;

  /// No description provided for @personNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Nguyễn Văn A'**
  String get personNameHint;

  /// No description provided for @noteOptional.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú (tùy chọn)'**
  String get noteOptional;

  /// No description provided for @selectDueDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày hạn'**
  String get selectDueDate;

  /// No description provided for @dueDate.
  ///
  /// In vi, this message translates to:
  /// **'Hạn: {date}'**
  String dueDate(String date);

  /// No description provided for @markPaid.
  ///
  /// In vi, this message translates to:
  /// **'Đã trả'**
  String get markPaid;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get add;

  /// No description provided for @paymentReminderSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm nhắc nhở...'**
  String get paymentReminderSearch;

  /// No description provided for @noReminders.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhắc nhở nào'**
  String get noReminders;

  /// No description provided for @noRemindersHint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm bill hàng tháng để không quên'**
  String get noRemindersHint;

  /// No description provided for @addReminder.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhắc nhở'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In vi, this message translates to:
  /// **'Sửa nhắc nhở'**
  String get editReminder;

  /// No description provided for @billName.
  ///
  /// In vi, this message translates to:
  /// **'Tên bill'**
  String get billName;

  /// No description provided for @billNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Tiền điện, Internet'**
  String get billNameHint;

  /// No description provided for @paymentDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày thanh toán (1-31)'**
  String get paymentDay;

  /// No description provided for @paymentDayHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: 15'**
  String get paymentDayHint;

  /// No description provided for @monthlyOnDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày {day} hàng tháng'**
  String monthlyOnDay(int day);

  /// No description provided for @overdueLabel.
  ///
  /// In vi, this message translates to:
  /// **'Quá hạn!'**
  String get overdueLabel;

  /// No description provided for @dueSoonLabel.
  ///
  /// In vi, this message translates to:
  /// **'Sắp đến'**
  String get dueSoonLabel;

  /// No description provided for @categoryManagementTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý danh mục'**
  String get categoryManagementTitle;

  /// No description provided for @expenseSection.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get expenseSection;

  /// No description provided for @incomeSection.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get incomeSection;

  /// No description provided for @defaultCategory.
  ///
  /// In vi, this message translates to:
  /// **'Mặc định'**
  String get defaultCategory;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa danh mục?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa \"{name}\"?'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @editCategoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa danh mục'**
  String get editCategoryTitle;

  /// No description provided for @addCategoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm danh mục'**
  String get addCategoryTitle;

  /// No description provided for @categoryNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Tên danh mục'**
  String get categoryNameHint;

  /// No description provided for @selectIcon.
  ///
  /// In vi, this message translates to:
  /// **'Chọn icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In vi, this message translates to:
  /// **'Chọn màu'**
  String get selectColor;

  /// No description provided for @noBudgetForCategory.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thiết lập hũ cho danh mục này'**
  String get noBudgetForCategory;

  /// No description provided for @jarOver.
  ///
  /// In vi, this message translates to:
  /// **'Vượt {amount}'**
  String jarOver(String amount);

  /// No description provided for @jarRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {amount}'**
  String jarRemaining(String amount);

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get about;

  /// No description provided for @aboutDeveloper.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin người làm'**
  String get aboutDeveloper;

  /// No description provided for @aboutUniversity.
  ///
  /// In vi, this message translates to:
  /// **'Trường đại học'**
  String get aboutUniversity;

  /// No description provided for @fieldFullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fieldFullName;

  /// No description provided for @fieldStudentId.
  ///
  /// In vi, this message translates to:
  /// **'Mã sinh viên'**
  String get fieldStudentId;

  /// No description provided for @fieldClass.
  ///
  /// In vi, this message translates to:
  /// **'Lớp'**
  String get fieldClass;

  /// No description provided for @fieldUniversityName.
  ///
  /// In vi, this message translates to:
  /// **'Trường'**
  String get fieldUniversityName;

  /// No description provided for @fieldMajor.
  ///
  /// In vi, this message translates to:
  /// **'Ngành'**
  String get fieldMajor;

  /// No description provided for @fieldBatch.
  ///
  /// In vi, this message translates to:
  /// **'Khóa'**
  String get fieldBatch;

  /// No description provided for @appVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản 1.0.0'**
  String get appVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
