/// Font families bundled with the app (declared in `pubspec.yaml`).
///
/// Outfit is shipped as an asset instead of being downloaded at runtime so
/// the POS renders correctly without a connection.
abstract final class AppFonts {
  static const String family = 'Outfit';

  /// Asset files per weight, used by tests to load the real font metrics.
  static const Map<int, String> files = <int, String>{
    400: 'assets/fonts/Outfit-Regular.ttf',
    500: 'assets/fonts/Outfit-Medium.ttf',
    600: 'assets/fonts/Outfit-SemiBold.ttf',
    700: 'assets/fonts/Outfit-Bold.ttf',
  };
}
