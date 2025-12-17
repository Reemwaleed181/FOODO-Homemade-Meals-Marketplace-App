import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../models/address.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../widgets/custom_app_bar.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  void _showAddAddressDialog(BuildContext context) {
    final addressProvider = context.read<AddressProvider>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final zipCodeController = TextEditingController();
    final phoneController = TextEditingController();
    final labelController = TextEditingController();
    final typeController = TextEditingController(text: 'home');
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_location_alt,
                            color: Colors.blue[700],
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Address',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Enter your delivery information',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              nameController.dispose();
                              addressController.dispose();
                              cityController.dispose();
                              zipCodeController.dispose();
                              phoneController.dispose();
                              labelController.dispose();
                              typeController.dispose();
                              instructionsController.dispose();
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type and Label Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: typeController,
                                  label: 'Address Type',
                                  icon: Icons.category_outlined,
                                  readOnly: true,
                                  onTap:
                                      () => _showTypePickerForDialog(
                                        context,
                                        typeController,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: labelController,
                                  label: 'Label (Optional)',
                                  icon: Icons.label_outline,
                                  hintText: 'e.g., Work',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Full Name
                          _buildEnhancedInputField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            hintText: 'Enter full name',
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          // Street Address
                          _buildEnhancedInputField(
                            controller: addressController,
                            label: 'Street Address',
                            icon: Icons.location_on_outlined,
                            hintText: 'Enter street address',
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          // City and ZIP Code Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: cityController,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                  hintText: 'Enter city',
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: zipCodeController,
                                  label: 'ZIP Code',
                                  icon: Icons.pin_outlined,
                                  hintText: 'Enter ZIP code',
                                  keyboardType: TextInputType.number,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Phone Number
                          _buildEnhancedInputField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            hintText: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          // Delivery Instructions (Optional)
                          _buildEnhancedInputField(
                            controller: instructionsController,
                            label: 'Delivery Instructions',
                            icon: Icons.note_outlined,
                            hintText: 'e.g., Ring doorbell, Leave at door',
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            nameController.dispose();
                            addressController.dispose();
                            cityController.dispose();
                            zipCodeController.dispose();
                            phoneController.dispose();
                            labelController.dispose();
                            typeController.dispose();
                            instructionsController.dispose();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                cityController.text.isEmpty ||
                                zipCodeController.text.isEmpty ||
                                phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill all required fields',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final label =
                                labelController.text.isNotEmpty
                                    ? labelController.text
                                    : '${typeController.text[0].toUpperCase()}${typeController.text.substring(1)} Address';

                            final newAddress = Address(
                              id:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              type: typeController.text,
                              label: label,
                              fullName: nameController.text,
                              streetAddress: addressController.text,
                              city: cityController.text,
                              zipCode: zipCodeController.text,
                              phone: phoneController.text,
                              instructions:
                                  instructionsController.text.isEmpty
                                      ? null
                                      : instructionsController.text,
                              isDefault: addressProvider.addresses.isEmpty,
                            );

                            await addressProvider.addAddress(newAddress);

                            nameController.dispose();
                            addressController.dispose();
                            cityController.dispose();
                            zipCodeController.dispose();
                            phoneController.dispose();
                            labelController.dispose();
                            typeController.dispose();
                            instructionsController.dispose();

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Add Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showEditAddressDialog(
    BuildContext context,
    Address address,
    AddressProvider addressProvider,
    AuthProvider authProvider,
  ) {
    final nameController = TextEditingController(text: address.fullName);
    final addressController = TextEditingController(
      text: address.streetAddress,
    );
    final cityController = TextEditingController(text: address.city);
    final zipCodeController = TextEditingController(text: address.zipCode);
    final phoneController = TextEditingController(text: address.phone);
    final labelController = TextEditingController(text: address.label);
    final typeController = TextEditingController(text: address.type);
    final instructionsController = TextEditingController(
      text: address.instructions ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit_location_alt,
                            color: Colors.blue[700],
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Address',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Update your delivery information',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              nameController.dispose();
                              addressController.dispose();
                              cityController.dispose();
                              zipCodeController.dispose();
                              phoneController.dispose();
                              labelController.dispose();
                              typeController.dispose();
                              instructionsController.dispose();
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type and Label Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: typeController,
                                  label: 'Address Type',
                                  icon: Icons.category_outlined,
                                  readOnly: true,
                                  onTap:
                                      () => _showTypePickerForDialog(
                                        context,
                                        typeController,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: labelController,
                                  label: 'Label (Optional)',
                                  icon: Icons.label_outline,
                                  hintText: 'e.g., Work',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Full Name
                          _buildEnhancedInputField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            hintText: 'Enter full name',
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          // Street Address
                          _buildEnhancedInputField(
                            controller: addressController,
                            label: 'Street Address',
                            icon: Icons.location_on_outlined,
                            hintText: 'Enter street address',
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          // City and ZIP Code Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: cityController,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                  hintText: 'Enter city',
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildEnhancedInputField(
                                  controller: zipCodeController,
                                  label: 'ZIP Code',
                                  icon: Icons.pin_outlined,
                                  hintText: 'Enter ZIP code',
                                  keyboardType: TextInputType.number,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Phone Number
                          _buildEnhancedInputField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            hintText: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          // Delivery Instructions (Optional)
                          _buildEnhancedInputField(
                            controller: instructionsController,
                            label: 'Delivery Instructions',
                            icon: Icons.note_outlined,
                            hintText: 'e.g., Ring doorbell, Leave at door',
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            nameController.dispose();
                            addressController.dispose();
                            cityController.dispose();
                            zipCodeController.dispose();
                            phoneController.dispose();
                            labelController.dispose();
                            typeController.dispose();
                            instructionsController.dispose();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                cityController.text.isEmpty ||
                                zipCodeController.text.isEmpty ||
                                phoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill all required fields',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final label =
                                labelController.text.isNotEmpty
                                    ? labelController.text
                                    : '${typeController.text[0].toUpperCase()}${typeController.text.substring(1)} Address';

                            final updatedAddress = Address(
                              id: address.id,
                              type: typeController.text,
                              label: label,
                              fullName: nameController.text,
                              streetAddress: addressController.text,
                              city: cityController.text,
                              zipCode: zipCodeController.text,
                              phone: phoneController.text,
                              instructions:
                                  instructionsController.text.isEmpty
                                      ? null
                                      : instructionsController.text,
                              isDefault: address.isDefault,
                            );

                            await addressProvider.updateAddress(
                              address.id,
                              updatedAddress,
                            );

                            // If this is the default address, also update user profile
                            if (updatedAddress.isDefault) {
                              final profileData = {
                                'name': updatedAddress.fullName,
                                'address': updatedAddress.streetAddress,
                                'city': updatedAddress.city,
                                'zipCode': updatedAddress.zipCode,
                                'phone': updatedAddress.phone,
                              };
                              try {
                                await authProvider.updateProfile(profileData);
                              } catch (e) {
                                // Log error but don't fail the address update
                                if (kDebugMode) {
                                  print('Error updating user profile: $e');
                                }
                              }
                            }

                            nameController.dispose();
                            addressController.dispose();
                            cityController.dispose();
                            zipCodeController.dispose();
                            phoneController.dispose();
                            labelController.dispose();
                            typeController.dispose();
                            instructionsController.dispose();

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEnhancedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool isRequired = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon:
                  readOnly
                      ? Icon(Icons.arrow_drop_down, color: Colors.grey[600])
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  void _showTypePickerForDialog(
    BuildContext context,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  controller.text = 'home';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Work'),
                onTap: () {
                  controller.text = 'work';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Other'),
                onTap: () {
                  controller.text = 'other';
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAddress(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Delete Address'),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this address? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await context.read<AddressProvider>().deleteAddress(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AddressProvider>(
      builder: (context, authProvider, addressProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return Scaffold(
            appBar: CustomAppBar(title: 'Delivery Settings'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to manage delivery settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => context.read<NavigationProvider>().navigateTo(
                          AppPage.login,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final addresses = addressProvider.addresses;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[300]),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Address list
                if (addresses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No addresses saved',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first delivery address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                ...addresses.map(
                  (address) => _AddressCard(
                    address: address,
                    onEdit:
                        () => _showEditAddressDialog(
                          context,
                          address,
                          addressProvider,
                          authProvider,
                        ),
                    onSetDefault:
                        () => addressProvider.setDefaultAddress(address.id),
                    onDelete: () => _deleteAddress(address.id),
                  ),
                ),

                // Add address button
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showAddAddressDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: Colors.blue[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  'Delivery Preferences',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery preferences
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _PreferenceRow(
                          label: 'Preferred Delivery Time',
                          value: 'Anytime',
                          onTap: () {},
                        ),
                        const Divider(),
                        _PreferenceRow(
                          label: 'Contact Method',
                          value: 'Call when arriving',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Delivery zone info
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green[700]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You\'re in our delivery zone!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Free delivery on orders over \$25 • Delivery time: 30-45 minutes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  IconData _getAddressIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? Colors.blue : Colors.grey[300]!,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio(
                  value: address.id,
                  groupValue: address.isDefault ? address.id : null,
                  onChanged: (value) => onSetDefault(),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconColor(address.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAddressIcon(address.type),
                    color: _getIconColor(address.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  color: Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              address.streetAddress,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            Text(
              '${address.city}, ${address.zipCode}',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            if (address.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    address.phone,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ],
            if (address.instructions != null &&
                address.instructions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.instructions!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!address.isDefault) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSetDefault,
                child: const Text('Set as Default'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PreferenceRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
