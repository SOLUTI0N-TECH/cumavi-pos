import 'package:equatable/equatable.dart';

/// Kind of business, asked during registration to preset categories.
enum BusinessType {
  clothingAndFootwear,
  neighborhoodStore,
  foodAndDrinks,
  beautyAndCare,
  technology,
  other;

  /// Categories proposed for this kind of business on the setup step.
  List<String> get suggestedCategories => switch (this) {
    BusinessType.clothingAndFootwear => const <String>[
      'Ropa',
      'Calzado',
      'Accesorios',
      'Deportivo',
      'Niños',
    ],
    BusinessType.neighborhoodStore => const <String>[
      'Abarrotes',
      'Bebidas',
      'Limpieza',
      'Snacks',
    ],
    BusinessType.foodAndDrinks => const <String>[
      'Platos',
      'Bebidas',
      'Postres',
      'Combos',
    ],
    BusinessType.beautyAndCare => const <String>[
      'Cuidado facial',
      'Cabello',
      'Maquillaje',
      'Perfumes',
    ],
    BusinessType.technology => const <String>[
      'Celulares',
      'Accesorios',
      'Audio',
      'Computación',
    ],
    BusinessType.other => const <String>['General'],
  };
}

/// Bolivian departments, used for the business location.
enum BoliviaDepartment {
  beni('Beni'),
  chuquisaca('Chuquisaca'),
  cochabamba('Cochabamba'),
  laPaz('La Paz'),
  oruro('Oruro'),
  pando('Pando'),
  potosi('Potosí'),
  santaCruz('Santa Cruz'),
  tarija('Tarija');

  const BoliviaDepartment(this.displayName);

  /// Official name, printed on receipts.
  final String displayName;
}

/// The store the POS belongs to.
final class BusinessProfile extends Equatable {
  const BusinessProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.department,
    this.logoPath,
    this.taxId,
  });

  final String id;
  final String name;
  final BusinessType type;
  final BoliviaDepartment department;

  /// Local path of the uploaded logo, `null` while it has none.
  final String? logoPath;

  /// NIT printed on receipts, optional.
  final String? taxId;

  /// `IS` for "Illimani Store" — used by the receipt and the dashboard.
  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  BusinessProfile copyWith({
    String? name,
    BusinessType? type,
    BoliviaDepartment? department,
    String? logoPath,
    String? taxId,
  }) {
    return BusinessProfile(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      department: department ?? this.department,
      logoPath: logoPath ?? this.logoPath,
      taxId: taxId ?? this.taxId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    type,
    department,
    logoPath,
    taxId,
  ];
}
