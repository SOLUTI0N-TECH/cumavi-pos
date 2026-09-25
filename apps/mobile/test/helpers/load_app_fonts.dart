import 'dart:io';

import 'package:cumavi_pos_mobile/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';

/// Loads the bundled Outfit files so widget tests measure text with the real
/// font instead of the square-glyph test font, which is much wider and would
/// report overflows that never happen on a device.
Future<void> loadAppFonts() async {
  final FontLoader loader = FontLoader(AppFonts.family);
  for (final String path in AppFonts.files.values) {
    final Uint8List bytes = File(path).readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
