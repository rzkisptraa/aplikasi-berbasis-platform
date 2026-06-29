class SellerAddressModel {
  final int id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  SellerAddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory SellerAddressModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SellerAddressModel(
      id: json['id'],
      label: json['label'] ?? '',
      address:
          json['address'] ?? '',
      latitude: double.parse(
        json['latitude']
            .toString(),
      ),
      longitude: double.parse(
        json['longitude']
            .toString(),
      ),
      isDefault:
          json['is_default'] ??
              false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerAddressModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}