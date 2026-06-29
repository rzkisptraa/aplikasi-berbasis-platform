class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final bool isOnline;
  final String? profilePhoto;
  final CourierProfileModel? courierProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.isOnline,
    this.profilePhoto,
    this.courierProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Determine role slug
    String roleSlug = 'seller';
    if (json['role'] != null) {
      if (json['role'] is Map) {
        roleSlug = json['role']['slug'] ?? 'seller';
      } else {
        roleSlug = json['role'].toString();
      }
    } else if (json['role_id'] != null) {
      final int roleId = int.tryParse(json['role_id'].toString()) ?? 3;
      if (roleId == 1) roleSlug = 'superadmin';
      if (roleId == 2) roleSlug = 'admin';
      if (roleId == 3) roleSlug = 'seller';
      if (roleId == 4) roleSlug = 'courier';
    }

    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: roleSlug,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      profilePhoto: json['profile_photo'],
      courierProfile: json['courier_profile'] != null
          ? CourierProfileModel.fromJson(json['courier_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'is_online': isOnline,
      'profile_photo': profilePhoto,
    };
  }
}

class CourierProfileModel {
  final int id;
  final String vehicleType;
  final String vehiclePlate;
  final String ktpNumber;
  final String? ktpPhoto;
  final String simNumber;
  final String? simPhoto;
  final double rating;
  final double performanceScore;
  final bool isVerified;
  final double? currentLatitude;
  final double? currentLongitude;

  CourierProfileModel({
    required this.id,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.ktpNumber,
    this.ktpPhoto,
    required this.simNumber,
    this.simPhoto,
    required this.rating,
    required this.performanceScore,
    required this.isVerified,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory CourierProfileModel.fromJson(Map<String, dynamic> json) {
    return CourierProfileModel(
      id: json['id'] ?? 0,
      vehicleType: json['vehicle_type'] ?? '',
      vehiclePlate: json['vehicle_plate'] ?? '',
      ktpNumber: json['ktp_number'] ?? '',
      ktpPhoto: json['ktp_photo'],
      simNumber: json['sim_number'] ?? '',
      simPhoto: json['sim_photo'],
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      performanceScore: double.tryParse(json['performance_score']?.toString() ?? '0') ?? 0.0,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      currentLatitude: double.tryParse(json['current_latitude']?.toString() ?? ''),
      currentLongitude: double.tryParse(json['current_longitude']?.toString() ?? ''),
    );
  }
}
