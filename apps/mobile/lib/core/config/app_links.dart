/// Public addresses the app links to.
abstract final class AppLinks {
  /// The web catalog (`apps/web`), deployed on Netlify while there is no
  /// own domain.
  static const String catalogBaseUrl =
      'https://cumavi-pos-catalogo.netlify.app';

  /// `https://…/illimani-store`
  static String storeUrl(String slug) => '$catalogBaseUrl/$slug';
}
