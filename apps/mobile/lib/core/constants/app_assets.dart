/// Bundled asset paths. Product photos live in the app while the catalog is
/// mocked; once the backend exists they become remote URLs.
abstract final class AppAssets {
  static const String _brand = 'assets/brand';
  static const String _icons = 'assets/icons';
  static const String _products = 'assets/images/products';
  static const String _demo = 'assets/images/demo';

  // Brand.
  static const String logoTag = '$_brand/logo_tag.png';
  static const String logoFull = '$_brand/logo_full.png';
  static const String googleIcon = '$_icons/google_icon.svg';

  // Catalog seed photos. The color variants (blue/black sneakers, red print,
  // gray tee, brown/black bag) are recolored copies of the originals.
  static const String sneakersRed = '$_products/sneakers_red.jpg';
  static const String sneakersBlue = '$_products/sneakers_blue.jpg';
  static const String sneakersBlack = '$_products/sneakers_black.jpg';
  static const String sneakersWhite = '$_products/sneakers_white.jpg';
  static const String runningShoes = '$_products/running_shoes.jpg';
  static const String tshirtPrint = '$_products/tshirt_print.jpg';
  static const String tshirtPrintRed = '$_products/tshirt_print_red.jpg';
  static const String tshirtBlack = '$_products/tshirt_black.jpg';
  static const String tshirtGray = '$_products/tshirt_gray.jpg';
  static const String denimJacket = '$_products/denim_jacket.jpg';
  static const String leatherJacket = '$_products/leather_jacket.jpg';
  static const String bomberJacket = '$_products/bomber_jacket.jpg';
  static const String woolSweater = '$_products/wool_sweater.jpg';
  static const String capWhite = '$_products/cap_white.jpg';
  static const String sunglasses = '$_products/sunglasses.jpg';
  static const String leatherBag = '$_products/leather_bag.jpg';
  static const String leatherBagBrown = '$_products/leather_bag_brown.jpg';
  static const String leatherBagBlack = '$_products/leather_bag_black.jpg';
  static const String backpack = '$_products/backpack.jpg';
  static const String wallet = '$_products/wallet.jpg';

  // Background-removal demo (camera output is faked while there is no backend).
  static const String demoPhotoOriginal = '$_demo/product_photo_original.jpg';
  static const String demoPhotoWhite = '$_demo/product_photo_white.jpg';
  static const String demoPhotoTransparent =
      '$_demo/product_photo_transparent.png';
}
