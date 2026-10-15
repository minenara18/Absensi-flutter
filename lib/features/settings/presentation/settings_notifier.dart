import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persisted UI preferences. Storage is in-memory for the dummy build;
/// bootstrap restores platform brightness as the default before frame one.
enum AppThemeMode { system, light, dark }

/// Immutable settings state.
@immutable
final class SettingsState {
  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.locale = const Locale('id'),
  });

  final AppThemeMode themeMode;
  final Locale locale;

  SettingsState copyWith({AppThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsState &&
          other.themeMode == themeMode &&
          other.locale == locale);

  @override
  int get hashCode => Object.hash(themeMode, locale);
}

final class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}

final NotifierProvider<SettingsNotifier, SettingsState> settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Minimal admin session (UI only). Starts logged out so the login
/// screen + guard path is exercised; guard is purely provider-driven.
@immutable
final class AuthState {
  const AuthState({this.loggedIn = false, this.name = 'Rina Wijaya'});

  final bool loggedIn;
  final String name;

  AuthState copyWith({bool? loggedIn, String? name}) {
    return AuthState(
      loggedIn: loggedIn ?? this.loggedIn,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthState && other.loggedIn == loggedIn && other.name == name);

  @override
  int get hashCode => Object.hash(loggedIn, name);
}

final class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void login(String name) {
    state = state.copyWith(loggedIn: true, name: name);
  }

  void logout() {
    state = state.copyWith(loggedIn: false);
  }
}

final NotifierProvider<AuthNotifier, AuthState> authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
