import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/bolivian_phone_number.dart';
import '../error/failure.dart';
import '../utils/result.dart';

/// Hands work to other apps: WhatsApp, the dialer, the browser and the
/// share sheet.
abstract interface class ExternalLauncher {
  /// Opens the chat with [phone] (national number) and [message] typed.
  Future<Result<void>> openWhatsApp({
    required String phone,
    required String message,
  });

  Future<Result<void>> callPhone(String phone);

  Future<Result<void>> openLink(String url);

  Future<Result<void>> shareText(String text, {String? subject});
}

/// The real launcher, with `url_launcher` and `share_plus`.
final class DeviceExternalLauncher implements ExternalLauncher {
  const DeviceExternalLauncher();

  @override
  Future<Result<void>> openWhatsApp({
    required String phone,
    required String message,
  }) => _launch(
    Uri.https(
      'wa.me',
      '/${BolivianPhoneNumber.toInternational(phone)}',
      <String, String>{'text': message},
    ),
    unavailable: FailureCode.whatsAppUnavailable,
  );

  @override
  Future<Result<void>> callPhone(String phone) => _launch(
    Uri(scheme: 'tel', path: '+${BolivianPhoneNumber.toInternational(phone)}'),
    unavailable: FailureCode.phoneAppUnavailable,
  );

  @override
  Future<Result<void>> openLink(String url) =>
      _launch(Uri.parse(url), unavailable: FailureCode.linkUnavailable);

  @override
  Future<Result<void>> shareText(String text, {String? subject}) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: subject));
      return const Success<void>(null);
    } on Object catch (error) {
      debugPrint('Sharing failed: $error');
      return const Failed<void>(UnexpectedFailure(FailureCode.shareFailed));
    }
  }

  Future<Result<void>> _launch(
    Uri uri, {
    required FailureCode unavailable,
  }) async {
    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return opened
          ? const Success<void>(null)
          : Failed<void>(ConflictFailure(unavailable));
    } on Object catch (error) {
      debugPrint('Opening $uri failed: $error');
      return Failed<void>(ConflictFailure(unavailable));
    }
  }
}

/// Stand-in for tests, desktop and web: remembers what it was asked to open.
final class DemoExternalLauncher implements ExternalLauncher {
  DemoExternalLauncher();

  /// Every request, as `whatsapp:<phone>:<message>`, `tel:<phone>`,
  /// `link:<url>` or `share:<text>`.
  final List<String> requests = <String>[];

  @override
  Future<Result<void>> openWhatsApp({
    required String phone,
    required String message,
  }) async => _record('whatsapp:$phone:$message');

  @override
  Future<Result<void>> callPhone(String phone) async => _record('tel:$phone');

  @override
  Future<Result<void>> openLink(String url) async => _record('link:$url');

  @override
  Future<Result<void>> shareText(String text, {String? subject}) async =>
      _record('share:$text');

  Result<void> _record(String request) {
    requests.add(request);
    return const Success<void>(null);
  }
}
