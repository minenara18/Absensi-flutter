import 'package:absensi_dashboard/bootstrap.dart';
import 'package:flutter/material.dart';

/// Thin entry point: everything lives in [bootstrap].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
}
