import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Displays an image from a bundled asset, a local file (camera, cutouts) or
/// a URL (future backend), chosen from the shape of [path].
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    super.key,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  bool get _isAsset => path.startsWith('assets/');

  bool get _isRemote =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isAsset) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: _placeholder,
      );
    }
    if (_isRemote) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: _placeholder,
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: _placeholder,
    );
  }

  Widget _placeholder(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}
