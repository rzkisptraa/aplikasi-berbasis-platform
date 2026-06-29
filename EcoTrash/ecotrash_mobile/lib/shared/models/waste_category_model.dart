class WasteCategoryModel {
  final int id;
  final String name;
  final String slug;
  final double pricePerKg;
  final String? description;
  final String unit;

  WasteCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.pricePerKg,
    this.description,
    this.unit = 'kg',
  });

  factory WasteCategoryModel.fromJson(Map<String, dynamic> json) {
    return WasteCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      pricePerKg: double.tryParse(json['price_per_kg']?.toString() ?? '0') ?? 0.0,
      description: json['description'],
      unit: json['unit'] ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price_per_kg': pricePerKg,
      'description': description,
      'unit': unit,
    };
  }
}
