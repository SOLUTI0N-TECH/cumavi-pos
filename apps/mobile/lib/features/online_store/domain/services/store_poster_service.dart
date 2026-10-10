import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';

/// The printable "Escanea y pide" poster: the store's name and a QR code
/// with its catalog link.
final class StorePoster extends Equatable {
  const StorePoster({
    required this.businessName,
    required this.url,
    this.tagline = '',
  });

  final String businessName;
  final String url;
  final String tagline;

  @override
  List<Object?> get props => <Object?>[businessName, url, tagline];
}

/// Shares the poster as a PDF or sends it to a printer.
abstract interface class StorePosterService {
  Future<Result<void>> share(StorePoster poster);

  Future<Result<void>> print(StorePoster poster);
}
