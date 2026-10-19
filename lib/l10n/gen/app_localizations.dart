import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'AbsensiKu Admin'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navAttendance.
  ///
  /// In id, this message translates to:
  /// **'Absensi'**
  String get navAttendance;

  /// No description provided for @navEmployees.
  ///
  /// In id, this message translates to:
  /// **'Karyawan'**
  String get navEmployees;

  /// No description provided for @navReports.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navSettings;

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get greetingNight;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari karyawan, laporan, menu…'**
  String get searchHint;

  /// No description provided for @quickAccess.
  ///
  /// In id, this message translates to:
  /// **'Akses Cepat'**
  String get quickAccess;

  /// No description provided for @quickAccessEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get quickAccessEdit;

  /// No description provided for @quickAccessDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get quickAccessDone;

  /// No description provided for @quickAccessAll.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get quickAccessAll;

  /// No description provided for @quickAccessSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Semua Layanan'**
  String get quickAccessSheetTitle;

  /// No description provided for @qaToday.
  ///
  /// In id, this message translates to:
  /// **'Absensi Hari Ini'**
  String get qaToday;

  /// No description provided for @qaAddEmployee.
  ///
  /// In id, this message translates to:
  /// **'Tambah Karyawan'**
  String get qaAddEmployee;

  /// No description provided for @qaApprovals.
  ///
  /// In id, this message translates to:
  /// **'Setujui Izin'**
  String get qaApprovals;

  /// No description provided for @qaOvertime.
  ///
  /// In id, this message translates to:
  /// **'Lembur'**
  String get qaOvertime;

  /// No description provided for @qaSchedule.
  ///
  /// In id, this message translates to:
  /// **'Shift & Jadwal'**
  String get qaSchedule;

  /// No description provided for @qaMonthly.
  ///
  /// In id, this message translates to:
  /// **'Laporan Bulanan'**
  String get qaMonthly;

  /// No description provided for @qaExport.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Data'**
  String get qaExport;

  /// No description provided for @qaLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Kantor'**
  String get qaLocation;

  /// No description provided for @qaCategoryAttendance.
  ///
  /// In id, this message translates to:
  /// **'Absensi'**
  String get qaCategoryAttendance;

  /// No description provided for @qaCategoryEmployee.
  ///
  /// In id, this message translates to:
  /// **'Karyawan'**
  String get qaCategoryEmployee;

  /// No description provided for @qaCategoryReport.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get qaCategoryReport;

  /// No description provided for @qaCategorySystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get qaCategorySystem;

  /// No description provided for @qaEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih shortcut favorit'**
  String get qaEditTitle;

  /// No description provided for @summaryToday.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Hari Ini'**
  String get summaryToday;

  /// No description provided for @statTotal.
  ///
  /// In id, this message translates to:
  /// **'Total Karyawan'**
  String get statTotal;

  /// No description provided for @statPresent.
  ///
  /// In id, this message translates to:
  /// **'Hadir'**
  String get statPresent;

  /// No description provided for @statLate.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get statLate;

  /// No description provided for @statLeave.
  ///
  /// In id, this message translates to:
  /// **'Izin/Cuti'**
  String get statLeave;

  /// No description provided for @statAbsent.
  ///
  /// In id, this message translates to:
  /// **'Belum Absen'**
  String get statAbsent;

  /// No description provided for @trendUp.
  ///
  /// In id, this message translates to:
  /// **'Naik'**
  String get trendUp;

  /// No description provided for @trendDown.
  ///
  /// In id, this message translates to:
  /// **'Turun'**
  String get trendDown;

  /// No description provided for @trendFlat.
  ///
  /// In id, this message translates to:
  /// **'Stabil'**
  String get trendFlat;

  /// No description provided for @attendance7d.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran 7 Hari Terakhir'**
  String get attendance7d;

  /// No description provided for @filterWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get filterWeek;

  /// No description provided for @filterMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get filterMonth;

  /// No description provided for @recentActivity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Terbaru'**
  String get recentActivity;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get seeAll;

  /// No description provided for @pendingBanner.
  ///
  /// In id, this message translates to:
  /// **'{count} permintaan izin menunggu persetujuan'**
  String pendingBanner(int count);

  /// No description provided for @reviewNow.
  ///
  /// In id, this message translates to:
  /// **'Tinjau Sekarang'**
  String get reviewNow;

  /// No description provided for @promoTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan bulan lalu sudah siap diunduh'**
  String get promoTitle;

  /// No description provided for @promoAction.
  ///
  /// In id, this message translates to:
  /// **'Unduh'**
  String get promoAction;

  /// No description provided for @checkIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In id, this message translates to:
  /// **'Pulang'**
  String get checkOut;

  /// No description provided for @statusPresent.
  ///
  /// In id, this message translates to:
  /// **'Hadir'**
  String get statusPresent;

  /// No description provided for @statusLate.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get statusLate;

  /// No description provided for @statusLeave.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get statusLeave;

  /// No description provided for @statusAlpha.
  ///
  /// In id, this message translates to:
  /// **'Alfa'**
  String get statusAlpha;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get filterAll;

  /// No description provided for @filterDepartment.
  ///
  /// In id, this message translates to:
  /// **'Departemen'**
  String get filterDepartment;

  /// No description provided for @emptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In id, this message translates to:
  /// **'Data akan muncul di sini setelah tersedia.'**
  String get emptyBody;

  /// No description provided for @noResultTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil'**
  String get noResultTitle;

  /// No description provided for @noResultBody.
  ///
  /// In id, this message translates to:
  /// **'Coba ubah kata kunci atau filter.'**
  String get noResultBody;

  /// No description provided for @resetFilter.
  ///
  /// In id, this message translates to:
  /// **'Atur Ulang Filter'**
  String get resetFilter;

  /// No description provided for @errorTitle.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala'**
  String get errorTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Koneksi bermasalah. Periksa internet lalu coba lagi.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get errorNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan tak terduga.'**
  String get errorUnknown;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @attendanceDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Absensi'**
  String get attendanceDetail;

  /// No description provided for @workDuration.
  ///
  /// In id, this message translates to:
  /// **'Durasi kerja'**
  String get workDuration;

  /// No description provided for @workLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi kerja'**
  String get workLocation;

  /// No description provided for @office.
  ///
  /// In id, this message translates to:
  /// **'Kantor'**
  String get office;

  /// No description provided for @wfh.
  ///
  /// In id, this message translates to:
  /// **'WFH'**
  String get wfh;

  /// No description provided for @timeline.
  ///
  /// In id, this message translates to:
  /// **'Linimasa'**
  String get timeline;

  /// No description provided for @timelineBreak.
  ///
  /// In id, this message translates to:
  /// **'Istirahat'**
  String get timelineBreak;

  /// No description provided for @notes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get notes;

  /// No description provided for @manualCorrection.
  ///
  /// In id, this message translates to:
  /// **'Koreksi Manual'**
  String get manualCorrection;

  /// No description provided for @proofPhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto Bukti'**
  String get proofPhoto;

  /// No description provided for @locationMap.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get locationMap;

  /// No description provided for @employeeDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Karyawan'**
  String get employeeDetail;

  /// No description provided for @attendanceThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran bulan ini'**
  String get attendanceThisMonth;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get history;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @addEmployee.
  ///
  /// In id, this message translates to:
  /// **'Tambah Karyawan'**
  String get addEmployee;

  /// No description provided for @editEmployee.
  ///
  /// In id, this message translates to:
  /// **'Ubah Karyawan'**
  String get editEmployee;

  /// No description provided for @fieldName.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get fieldName;

  /// No description provided for @fieldPosition.
  ///
  /// In id, this message translates to:
  /// **'Jabatan'**
  String get fieldPosition;

  /// No description provided for @fieldDepartment.
  ///
  /// In id, this message translates to:
  /// **'Departemen'**
  String get fieldDepartment;

  /// No description provided for @fieldEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get fieldPhone;

  /// No description provided for @requiredField.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In id, this message translates to:
  /// **'Nomor telepon tidak valid'**
  String get invalidPhone;

  /// No description provided for @unsavedTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan perubahan?'**
  String get unsavedTitle;

  /// No description provided for @unsavedBody.
  ///
  /// In id, this message translates to:
  /// **'Perubahan yang belum disimpan akan hilang.'**
  String get unsavedBody;

  /// No description provided for @discard.
  ///
  /// In id, this message translates to:
  /// **'Buang'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Mengubah'**
  String get keepEditing;

  /// No description provided for @saved.
  ///
  /// In id, this message translates to:
  /// **'Data tersimpan'**
  String get saved;

  /// No description provided for @leaveTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin & Cuti'**
  String get leaveTitle;

  /// No description provided for @tabPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get tabPending;

  /// No description provided for @tabApproved.
  ///
  /// In id, this message translates to:
  /// **'Disetujui'**
  String get tabApproved;

  /// No description provided for @tabRejected.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get tabRejected;

  /// No description provided for @approve.
  ///
  /// In id, this message translates to:
  /// **'Setujui'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get reject;

  /// No description provided for @approveConfirm.
  ///
  /// In id, this message translates to:
  /// **'Setujui pengajuan ini?'**
  String get approveConfirm;

  /// No description provided for @rejectConfirm.
  ///
  /// In id, this message translates to:
  /// **'Tolak pengajuan ini?'**
  String get rejectConfirm;

  /// No description provided for @undone.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get undone;

  /// No description provided for @reportsTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get reportsTitle;

  /// No description provided for @monthlySummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Bulanan'**
  String get monthlySummary;

  /// No description provided for @exportPdf.
  ///
  /// In id, this message translates to:
  /// **'Ekspor PDF'**
  String get exportPdf;

  /// No description provided for @exportExcel.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Excel'**
  String get exportExcel;

  /// No description provided for @exportPreparing.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan berkas…'**
  String get exportPreparing;

  /// No description provided for @exportReady.
  ///
  /// In id, this message translates to:
  /// **'Berkas siap diunduh'**
  String get exportReady;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @profileAdmin.
  ///
  /// In id, this message translates to:
  /// **'Profil Admin'**
  String get profileAdmin;

  /// No description provided for @themeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @languageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get languageLabel;

  /// No description provided for @workHours.
  ///
  /// In id, this message translates to:
  /// **'Jam kerja & toleransi'**
  String get workHours;

  /// No description provided for @workHoursValue.
  ///
  /// In id, this message translates to:
  /// **'08.00–17.00, toleransi 15 mnt'**
  String get workHoursValue;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang aplikasi'**
  String get aboutApp;

  /// No description provided for @aboutBody.
  ///
  /// In id, this message translates to:
  /// **'AbsensiKu Admin v1.0.0 — dasbor front-end dengan data dummy lokal.'**
  String get aboutBody;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari akun admin?'**
  String get logoutConfirm;

  /// No description provided for @loginTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk Admin'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola kehadiran tim dalam satu dasbor'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In id, this message translates to:
  /// **'Email kerja'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginButton;

  /// No description provided for @loginHint.
  ///
  /// In id, this message translates to:
  /// **'UI saja — gunakan email valid & sandi ≥ 6 karakter.'**
  String get loginHint;

  /// No description provided for @passwordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 6 karakter'**
  String get passwordTooShort;

  /// No description provided for @notFoundTitle.
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak ditemukan'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In id, this message translates to:
  /// **'Alamat yang dituju tidak tersedia.'**
  String get notFoundBody;

  /// No description provided for @backHome.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Beranda'**
  String get backHome;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @active.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get inactive;

  /// No description provided for @moveUp.
  ///
  /// In id, this message translates to:
  /// **'Pindah ke atas'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In id, this message translates to:
  /// **'Pindah ke bawah'**
  String get moveDown;

  /// No description provided for @toggleFavorite.
  ///
  /// In id, this message translates to:
  /// **'Jadikan favorit'**
  String get toggleFavorite;

  /// No description provided for @chartWeekTitle.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran 7 Hari Terakhir'**
  String get chartWeekTitle;

  /// No description provided for @chartSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Jumlah karyawan hadir per hari'**
  String get chartSubtitle;

  /// No description provided for @chartMonthSummary.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran Bulan Ini'**
  String get chartMonthSummary;

  /// No description provided for @chartAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata: {value} orang/hari'**
  String chartAverage(Object value);

  /// No description provided for @chartPeak.
  ///
  /// In id, this message translates to:
  /// **'Hari tertinggi: {day} ({value})'**
  String chartPeak(Object day, Object value);

  /// No description provided for @chartLow.
  ///
  /// In id, this message translates to:
  /// **'Hari terendah: {day} ({value})'**
  String chartLow(Object day, Object value);

  /// No description provided for @chartLegend.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran (Hadir + Terlambat)'**
  String get chartLegend;

  /// No description provided for @themeDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih tampilan terang, gelap, atau ikuti sistem.'**
  String get themeDescription;

  /// No description provided for @languageDescription.
  ///
  /// In id, this message translates to:
  /// **'Bahasa antarmuka aplikasi.'**
  String get languageDescription;

  /// No description provided for @monthlyChartTitle.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran Bulan Ini'**
  String get monthlyChartTitle;

  /// No description provided for @chartMonthlyTitle.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran {month}'**
  String chartMonthlyTitle(String month);
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
