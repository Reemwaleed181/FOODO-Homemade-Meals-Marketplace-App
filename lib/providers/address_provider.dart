import 'package:flutter/foundation.dart';
import '../models/address.dart';
import '../services/storage_service.dart';

class AddressProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Address> _addresses = [];

  List<Address> get addresses => List.unmodifiable(_addresses);
  Address? get defaultAddress {
    if (_addresses.isEmpty) return null;
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return _addresses.first;
    }
  }

  AddressProvider({required StorageService storageService})
      : _storageService = storageService;

  Future<void> loadAddresses() async {
    try {
      final addressesData = await _storageService.getAddresses();
      _addresses = addressesData
          .map((data) => Address.fromJson(data))
          .toList();
      
      // If no addresses, create one from user data if available
      if (_addresses.isEmpty) {
        final userData = await _storageService.getUserData();
        if (userData != null && userData['address'] != null) {
          _addresses.add(Address(
            id: '1',
            type: 'home',
            label: 'Home',
            fullName: userData['name'] ?? '',
            streetAddress: userData['address'] ?? '',
            city: userData['city'] ?? '',
            zipCode: userData['zipCode'] ?? userData['zip_code'] ?? '',
            phone: userData['phone'] ?? '',
            isDefault: true,
          ));
          await saveAddresses();
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading addresses: $e');
      }
    }
  }

  Future<void> addAddress(Address address) async {
    // If this is the first address or marked as default, set it as default
    if (_addresses.isEmpty || address.isDefault) {
      _addresses.forEach((addr) => addr.isDefault = false);
      address.isDefault = true;
    }

    _addresses.add(address);
    await saveAddresses();
    notifyListeners();
  }

  Future<void> updateAddress(String id, Address updatedAddress) async {
    final index = _addresses.indexWhere((addr) => addr.id == id);
    if (index != -1) {
      // If setting as default, unset others
      if (updatedAddress.isDefault) {
        _addresses.forEach((addr) {
          if (addr.id != id) addr.isDefault = false;
        });
      }
      
      _addresses[index] = updatedAddress;
      await saveAddresses();
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    final address = _addresses.firstWhere(
      (addr) => addr.id == id,
      orElse: () => Address(
        id: '',
        type: 'home',
        label: 'Home',
        fullName: '',
        streetAddress: '',
        city: '',
        zipCode: '',
        phone: '',
        isDefault: false,
      ),
    );

    // If deleting default address, set first remaining as default
    if (address.isDefault && _addresses.length > 1) {
      _addresses.removeWhere((addr) => addr.id == id);
      if (_addresses.isNotEmpty) {
        _addresses.first.isDefault = true;
      }
    } else {
      _addresses.removeWhere((addr) => addr.id == id);
    }

    await saveAddresses();
    notifyListeners();
  }

  Future<void> setDefaultAddress(String id) async {
    _addresses.forEach((addr) {
      addr.isDefault = addr.id == id;
    });
    await saveAddresses();
    notifyListeners();
  }

  Future<void> saveAddresses() async {
    try {
      final addressesJson = _addresses.map((addr) => addr.toJson()).toList();
      await _storageService.saveAddresses(addressesJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving addresses: $e');
      }
    }
  }
}

