import 'package:absensi_dashboard/core/result.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';

/// Maps a typed [Failure] to a localized human message.
/// Pure function (no BuildContext), tested indirectly via widget tests.
String messageForFailure(Failure failure, AppLocalizations strings) {
  switch (failure.code) {
    case FailureCode.network:
      return strings.errorNetwork;
    case FailureCode.notFound:
      return strings.errorNotFound;
    case FailureCode.validation:
    case FailureCode.unknown:
      return strings.errorUnknown;
  }
}
