# AbsensiKu Admin — Dashboard Absensi Karyawan

Front-end dashboard admin absensi karyawan (Flutter 3, Dart 3, Material 3).
**UI-only dengan data dummy lokal deterministik** — arsitektur feature-first
siap disambungkan ke API.

## Menjalankan

```sh
flutter pub get
flutter gen-l10n        # hasil di lib/l10n/gen (jangan edit manual)
flutter run             # Android/iOS/Web/Windows/macOS
flutter test            # 15 test: unit + notifier + widget
flutter analyze         # harus: No issues found
dart format .           # harus: tidak ada perubahan
```

Alur buka aplikasi: Splash (0,3 dtk) → Login admin (UI saja:
email valid + sandi ≥ 6 karakter) → Beranda. Guard login murni
berbasis provider (`authProvider` + `refreshListenable`).

## Struktur folder

```text
lib/
  main.dart            tipis: ensureInitialized + bootstrap()
  bootstrap.dart       composition root: FlutterError/PlatformDispatcher
                       handlers + ProviderScope overrides (dummy world)
  app.dart             MaterialApp.router + tema + locale
  core/                Dart murni: Result/Failure (sealed), clock, extensions,
                       AttendanceMath, messageForFailure (tanpa BuildContext)
  data/                models immutable, DummyData (seed tetap), repository
                       (interface + implementasi in-memory + provider)
  routing/             satu GoRouter: shell 5 tab, rute detail pakai path
                       param (:id), guard redirect, CustomTransitionPage yang
                       menghormati reduce-motion, errorBuilder 404
  theme/               SATU-SATUNYA tempat hex/Colors/Duration/fontSize:
                       tokens + AppTheme (light & dark manual) + AppTokens
  l10n/                app_id.arb (template) + app_en.arb (+ hasil gen/)
  features/{shell,dashboard,attendance,employees,leave,reports,settings,auth}/
    presentation/      screen (ConsumerWidget) + notifier + widgets/
  shared/widgets/      StatusChip/LeaveChip, InitialAvatar, SectionHeader,
                       LoadingList/SkeletonBlock, EmptyView, ErrorView
test/                  core_test, notifier_test (fake repo tangan),
                       quick_access_test (skala teks 1.0 & 2.0)
```

Aturan yang ditegakkan: View hanya `watch` + kirim intent
(`ref.read(notifier)`); total/persen/filter diturunkan, tidak disimpan;
`Result` dikonsumsi dengan `switch` exhaustive; navigasi antar-fitur
lewat rute + ID; waktu lewat `clockProvider`; tanpa `DateTime.now()`,
`late`/`!`/`dynamic` untuk menghindari penanganan yang benar di `lib/`.

## Daftar asumsi

1. **Mulai dalam keadaan logout** agar alur Login + guard terlihat.
2. **Favorit Quick Access & tema/bahasa tersimpan in-memory** (bukan
   SharedPreferences) — cukup untuk demo; lihat “Mengganti …” di bawah.
3. Shortcut tanpa layar khusus (Lembur, Shift & Jadwal, Lokasi Kantor)
   membuka halaman `/soon/:key` yang jujur (“segera hadir”), bukan fitur palsu.
4. Ekspor PDF/Excel mensimulasikan `menyiapkan → siap` selama ±2 detik.
5. Data dummy: 40 karyawan, absensi 30 hari, 9 pengajuan izin; LCG dengan
   seed tetap (bit tinggi) agar konsisten tiap run; 1 karyawan nonaktif.
6. `analysis_options.yaml` berbasis `very_good_analysis` + `strict-casts` +
   `strict-raw-types`; hanya 5 aturan stilistik yang dilonggarkan
   (`public_member_api_docs`, `omit_local_variable_types`,
   `avoid_types_on_closure_parameters`,
   `always_put_required_named_parameters_first`,
   `prefer_constructors_over_static_methods`) — didokumentasikan di file itu.
7. Font Plus Jakarta Sans dibundel sebagai variable font lokal
   (`assets/fonts/`); tanpa `google_fonts`; tanpa `get_it`/`provider`.
8. Unit test memanggil `initializeDateFormatting('id'/'en')` di `setUpAll`
   (di aplikasi nyata ini dikerjakan `flutter_localizations`).
9. Target sentuh ≥ 44dp; status selalu warna + ikon + teks; label Quick Access
   boleh wrap (layout `Wrap`, bukan grid kaku) agar lolos skala teks 2.0.

## Mengganti repository dummy dengan API

1. Buat `ApiAttendanceRepository implements AttendanceRepository`
   (dan dua lainnya) memakai `http`/`dio` + DTO→model mapper di `data/`.
2. Daftarkan di SATU tempat — `DummyWorld`/`bootstrap.dart`:
   ganti `overrideWithValue(world.*)` dengan instance API
   (tambahkan token/baseURL lewat override provider juga).
3. Kontrak tidak berubah (`Future<Result<…>>`), jadi **tidak ada perubahan
   di notifier maupun widget**. `Failure(FailureCode.network)` sudah
   dipetakan ke pesan lokal + tombol Coba Lagi (`ref.invalidate`).
4. Untuk persistensi lokal (favorit, tema, bahasa): bungkus
   `QuickAccessNotifier`/`SettingsNotifier` dengan repository
   `PreferencesRepository` (SharedPreferences) — pola yang sama.

## Yang sengaja belum dikerjakan

- Backend/autentikasi nyata, foto/peta asli (placeholder statis).
- Notifikasi push, ekspor file biner, manajemen shift/lembur/lokasi.
- Persistensi preferensi (lihat asumsi 2) dan paginasi server.
