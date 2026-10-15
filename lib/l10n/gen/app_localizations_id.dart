// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'AbsensiKu Admin';

  @override
  String get navHome => 'Beranda';

  @override
  String get navAttendance => 'Absensi';

  @override
  String get navEmployees => 'Karyawan';

  @override
  String get navReports => 'Laporan';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingAfternoon => 'Selamat siang';

  @override
  String get greetingEvening => 'Selamat sore';

  @override
  String get greetingNight => 'Selamat malam';

  @override
  String get searchHint => 'Cari karyawan, laporan, menu…';

  @override
  String get quickAccess => 'Akses Cepat';

  @override
  String get quickAccessEdit => 'Ubah';

  @override
  String get quickAccessDone => 'Selesai';

  @override
  String get quickAccessAll => 'Lainnya';

  @override
  String get quickAccessSheetTitle => 'Semua Layanan';

  @override
  String get qaToday => 'Absensi Hari Ini';

  @override
  String get qaAddEmployee => 'Tambah Karyawan';

  @override
  String get qaApprovals => 'Persetujuan Izin';

  @override
  String get qaOvertime => 'Lembur';

  @override
  String get qaSchedule => 'Shift & Jadwal';

  @override
  String get qaMonthly => 'Laporan Bulanan';

  @override
  String get qaExport => 'Ekspor Data';

  @override
  String get qaLocation => 'Lokasi Kantor';

  @override
  String get qaCategoryAttendance => 'Absensi';

  @override
  String get qaCategoryEmployee => 'Karyawan';

  @override
  String get qaCategoryReport => 'Laporan';

  @override
  String get qaCategorySystem => 'Sistem';

  @override
  String get qaEditTitle => 'Pilih shortcut favorit';

  @override
  String get summaryToday => 'Ringkasan Hari Ini';

  @override
  String get statTotal => 'Total Karyawan';

  @override
  String get statPresent => 'Hadir';

  @override
  String get statLate => 'Terlambat';

  @override
  String get statLeave => 'Izin/Cuti';

  @override
  String get statAbsent => 'Belum Absen';

  @override
  String get trendUp => 'Naik';

  @override
  String get trendDown => 'Turun';

  @override
  String get trendFlat => 'Stabil';

  @override
  String get attendance7d => 'Kehadiran 7 Hari Terakhir';

  @override
  String get filterWeek => 'Minggu';

  @override
  String get filterMonth => 'Bulan';

  @override
  String get recentActivity => 'Aktivitas Terbaru';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String pendingBanner(int count) {
    return '$count permintaan izin menunggu persetujuan';
  }

  @override
  String get reviewNow => 'Tinjau Sekarang';

  @override
  String get promoTitle => 'Laporan bulan lalu sudah siap diunduh';

  @override
  String get promoAction => 'Unduh';

  @override
  String get checkIn => 'Masuk';

  @override
  String get checkOut => 'Pulang';

  @override
  String get statusPresent => 'Hadir';

  @override
  String get statusLate => 'Terlambat';

  @override
  String get statusLeave => 'Izin';

  @override
  String get statusAlpha => 'Alfa';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterDepartment => 'Departemen';

  @override
  String get emptyTitle => 'Belum ada data';

  @override
  String get emptyBody => 'Data akan muncul di sini setelah tersedia.';

  @override
  String get noResultTitle => 'Tidak ada hasil';

  @override
  String get noResultBody => 'Coba ubah kata kunci atau filter.';

  @override
  String get resetFilter => 'Atur Ulang Filter';

  @override
  String get errorTitle => 'Terjadi kendala';

  @override
  String get errorNetwork =>
      'Koneksi bermasalah. Periksa internet lalu coba lagi.';

  @override
  String get errorNotFound => 'Data tidak ditemukan.';

  @override
  String get errorUnknown => 'Terjadi kesalahan tak terduga.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get attendanceDetail => 'Detail Absensi';

  @override
  String get workDuration => 'Durasi kerja';

  @override
  String get workLocation => 'Lokasi kerja';

  @override
  String get office => 'Kantor';

  @override
  String get wfh => 'WFH';

  @override
  String get timeline => 'Linimasa';

  @override
  String get timelineBreak => 'Istirahat';

  @override
  String get notes => 'Catatan';

  @override
  String get manualCorrection => 'Koreksi Manual';

  @override
  String get proofPhoto => 'Foto Bukti';

  @override
  String get locationMap => 'Lokasi';

  @override
  String get employeeDetail => 'Detail Karyawan';

  @override
  String get attendanceThisMonth => 'Kehadiran bulan ini';

  @override
  String get history => 'Riwayat';

  @override
  String get edit => 'Ubah';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get addEmployee => 'Tambah Karyawan';

  @override
  String get editEmployee => 'Ubah Karyawan';

  @override
  String get fieldName => 'Nama lengkap';

  @override
  String get fieldPosition => 'Jabatan';

  @override
  String get fieldDepartment => 'Departemen';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Telepon';

  @override
  String get requiredField => 'Wajib diisi';

  @override
  String get invalidEmail => 'Format email tidak valid';

  @override
  String get invalidPhone => 'Nomor telepon tidak valid';

  @override
  String get unsavedTitle => 'Batalkan perubahan?';

  @override
  String get unsavedBody => 'Perubahan yang belum disimpan akan hilang.';

  @override
  String get discard => 'Buang';

  @override
  String get keepEditing => 'Lanjut Mengubah';

  @override
  String get saved => 'Data tersimpan';

  @override
  String get leaveTitle => 'Izin & Cuti';

  @override
  String get tabPending => 'Menunggu';

  @override
  String get tabApproved => 'Disetujui';

  @override
  String get tabRejected => 'Ditolak';

  @override
  String get approve => 'Setujui';

  @override
  String get reject => 'Tolak';

  @override
  String get approveConfirm => 'Setujui pengajuan ini?';

  @override
  String get rejectConfirm => 'Tolak pengajuan ini?';

  @override
  String get undone => 'Dibatalkan';

  @override
  String get reportsTitle => 'Laporan';

  @override
  String get monthlySummary => 'Ringkasan Bulanan';

  @override
  String get exportPdf => 'Ekspor PDF';

  @override
  String get exportExcel => 'Ekspor Excel';

  @override
  String get exportPreparing => 'Menyiapkan berkas…';

  @override
  String get exportReady => 'Berkas siap diunduh';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get profileAdmin => 'Profil Admin';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get workHours => 'Jam kerja & toleransi';

  @override
  String get workHoursValue => '08.00–17.00, toleransi 15 mnt';

  @override
  String get aboutApp => 'Tentang aplikasi';

  @override
  String get aboutBody =>
      'AbsensiKu Admin v1.0.0 — dasbor front-end dengan data dummy lokal.';

  @override
  String get logout => 'Keluar';

  @override
  String get logoutConfirm => 'Keluar dari akun admin?';

  @override
  String get loginTitle => 'Masuk Admin';

  @override
  String get loginSubtitle => 'Kelola kehadiran tim dalam satu dasbor';

  @override
  String get loginEmail => 'Email kerja';

  @override
  String get loginPassword => 'Kata sandi';

  @override
  String get loginButton => 'Masuk';

  @override
  String get loginHint => 'UI saja — gunakan email valid & sandi ≥ 6 karakter.';

  @override
  String get passwordTooShort => 'Kata sandi minimal 6 karakter';

  @override
  String get notFoundTitle => 'Halaman tidak ditemukan';

  @override
  String get notFoundBody => 'Alamat yang dituju tidak tersedia.';

  @override
  String get backHome => 'Kembali ke Beranda';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Nonaktif';

  @override
  String get moveUp => 'Pindah ke atas';

  @override
  String get moveDown => 'Pindah ke bawah';

  @override
  String get toggleFavorite => 'Jadikan favorit';
}
