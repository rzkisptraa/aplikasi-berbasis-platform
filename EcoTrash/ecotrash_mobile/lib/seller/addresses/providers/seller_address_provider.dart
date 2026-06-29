import 'package:flutter/material.dart';

import '../models/seller_address_model.dart';
import '../services/seller_address_service.dart';

class SellerAddressProvider
    extends ChangeNotifier {

  final SellerAddressService
      _service =
      SellerAddressService();

  bool _isLoading = false;

  List<SellerAddressModel>
      _addresses = [];

  bool get isLoading =>
      _isLoading;

  List<SellerAddressModel>
      get addresses =>
          _addresses;

  Future<void>
      fetchAddresses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response =
          await _service
              .getAddresses();

      _addresses =
          response
              .map(
                (item) =>
                    SellerAddressModel
                        .fromJson(
                  item,
                ),
              )
              .toList();

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {

    await _service
        .addAddress(
      label: label,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );

    await fetchAddresses();
  }

  Future<void> deleteAddress(
    int id,
  ) async {

    await _service
        .deleteAddress(id);

    _addresses.removeWhere(
      (e) => e.id == id,
    );

    notifyListeners();
  }

  Future<void> updateAddress({
    required int id,
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    await _service.updateAddress(
      id: id,
      label: label,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    await fetchAddresses();
  }
}