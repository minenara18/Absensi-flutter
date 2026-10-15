// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AbsensiKu Admin';

  @override
  String get navHome => 'Home';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navEmployees => 'Employees';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get searchHint => 'Search employees, reports, menus…';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get quickAccessEdit => 'Edit';

  @override
  String get quickAccessDone => 'Done';

  @override
  String get quickAccessAll => 'More';

  @override
  String get quickAccessSheetTitle => 'All Services';

  @override
  String get qaToday => 'Today\'s Attendance';

  @override
  String get qaAddEmployee => 'Add Employee';

  @override
  String get qaApprovals => 'Leave Approvals';

  @override
  String get qaOvertime => 'Overtime';

  @override
  String get qaSchedule => 'Shifts & Schedule';

  @override
  String get qaMonthly => 'Monthly Report';

  @override
  String get qaExport => 'Export Data';

  @override
  String get qaLocation => 'Office Location';

  @override
  String get qaCategoryAttendance => 'Attendance';

  @override
  String get qaCategoryEmployee => 'Employees';

  @override
  String get qaCategoryReport => 'Reports';

  @override
  String get qaCategorySystem => 'System';

  @override
  String get qaEditTitle => 'Pick favorite shortcuts';

  @override
  String get summaryToday => 'Today\'s Summary';

  @override
  String get statTotal => 'Total Employees';

  @override
  String get statPresent => 'Present';

  @override
  String get statLate => 'Late';

  @override
  String get statLeave => 'On Leave';

  @override
  String get statAbsent => 'Not Checked In';

  @override
  String get trendUp => 'Up';

  @override
  String get trendDown => 'Down';

  @override
  String get trendFlat => 'Steady';

  @override
  String get attendance7d => 'Last 7 Days Attendance';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get seeAll => 'See All';

  @override
  String pendingBanner(int count) {
    return '$count leave requests awaiting approval';
  }

  @override
  String get reviewNow => 'Review Now';

  @override
  String get promoTitle => 'Last month\'s report is ready to download';

  @override
  String get promoAction => 'Download';

  @override
  String get checkIn => 'In';

  @override
  String get checkOut => 'Out';

  @override
  String get statusPresent => 'Present';

  @override
  String get statusLate => 'Late';

  @override
  String get statusLeave => 'Leave';

  @override
  String get statusAlpha => 'Absent';

  @override
  String get filterAll => 'All';

  @override
  String get filterDepartment => 'Department';

  @override
  String get emptyTitle => 'No data yet';

  @override
  String get emptyBody => 'Data will appear here once available.';

  @override
  String get noResultTitle => 'No results';

  @override
  String get noResultBody => 'Try a different keyword or filter.';

  @override
  String get resetFilter => 'Reset Filter';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorNetwork =>
      'Connection issue. Check the internet and try again.';

  @override
  String get errorNotFound => 'Data not found.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get retry => 'Try Again';

  @override
  String get attendanceDetail => 'Attendance Detail';

  @override
  String get workDuration => 'Work duration';

  @override
  String get workLocation => 'Work location';

  @override
  String get office => 'Office';

  @override
  String get wfh => 'WFH';

  @override
  String get timeline => 'Timeline';

  @override
  String get timelineBreak => 'Break';

  @override
  String get notes => 'Notes';

  @override
  String get manualCorrection => 'Manual Correction';

  @override
  String get proofPhoto => 'Proof Photo';

  @override
  String get locationMap => 'Location';

  @override
  String get employeeDetail => 'Employee Detail';

  @override
  String get attendanceThisMonth => 'Attendance this month';

  @override
  String get history => 'History';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get addEmployee => 'Add Employee';

  @override
  String get editEmployee => 'Edit Employee';

  @override
  String get fieldName => 'Full name';

  @override
  String get fieldPosition => 'Position';

  @override
  String get fieldDepartment => 'Department';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get unsavedTitle => 'Discard changes?';

  @override
  String get unsavedBody => 'Unsaved changes will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get saved => 'Saved';

  @override
  String get leaveTitle => 'Leave & Time Off';

  @override
  String get tabPending => 'Pending';

  @override
  String get tabApproved => 'Approved';

  @override
  String get tabRejected => 'Rejected';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get approveConfirm => 'Approve this request?';

  @override
  String get rejectConfirm => 'Reject this request?';

  @override
  String get undone => 'Undone';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportPreparing => 'Preparing file…';

  @override
  String get exportReady => 'File ready to download';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileAdmin => 'Admin Profile';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageLabel => 'Language';

  @override
  String get workHours => 'Work hours & tolerance';

  @override
  String get workHoursValue => '08.00–17.00, 15 min tolerance';

  @override
  String get aboutApp => 'About the app';

  @override
  String get aboutBody =>
      'AbsensiKu Admin v1.0.0 — front-end dashboard with local dummy data.';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Log out of the admin account?';

  @override
  String get loginTitle => 'Admin Sign In';

  @override
  String get loginSubtitle => 'Manage team attendance in one dashboard';

  @override
  String get loginEmail => 'Work email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginHint =>
      'UI only — use a valid email & a password of 6+ characters.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'The address you opened is unavailable.';

  @override
  String get backHome => 'Back to Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get toggleFavorite => 'Toggle favorite';
}
