import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../models/address.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/address_provider.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/image_with_fallback.dart';
import '../../../theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  bool _showAddressSelection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  void _startAddingNewAddress() {
    _showAddAddressDialog(context);
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
      builder: (context) => Dialog(
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
                              onTap: () => _showTypePickerForDialog(
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

                        final label = labelController.text.isNotEmpty
                            ? labelController.text
                            : '${typeController.text[0].toUpperCase()}${typeController.text.substring(1)} Address';

                        final newAddress = Address(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          type: typeController.text,
                          label: label,
                          fullName: nameController.text,
                          streetAddress: addressController.text,
                          city: cityController.text,
                          zipCode: zipCodeController.text,
                          phone: phoneController.text,
                          instructions: instructionsController.text.isEmpty
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
    setState(() {
                            _selectedAddressId = newAddress.id;
                          });
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


  void _showAddressManagementDialog(
    BuildContext context,
    List<Address> addresses,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Manage Addresses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (addresses.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No addresses saved',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...addresses.map(
                              (address) =>
                                  _buildAddressItemInDialog(context, address),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[300]!,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _showAddAddressDialog(context);
                              },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add New Address',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAddressItemInDialog(BuildContext context, Address address) {
    final addressProvider = context.read<AddressProvider>();
    final authProvider = context.read<AuthProvider>();

    IconData addressIcon;
    Color iconColor;
    switch (address.type) {
      case 'home':
        addressIcon = Icons.home;
        iconColor = Colors.blue;
        break;
      case 'work':
        addressIcon = Icons.work;
        iconColor = Colors.orange;
        break;
      default:
        addressIcon = Icons.location_on;
        iconColor = Colors.grey;
  }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: address.isDefault ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? Colors.blue[400]! : Colors.grey[300]!,
          width: address.isDefault ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(addressIcon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
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
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(6),
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
                    ],
                  ),
                ),
                // Action buttons
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showEditAddressDialog(
                              context,
                              address,
                              addressProvider,
                              authProvider,
                            );
                          },
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.grey[300]),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete Address'),
                                      ],
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this address? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirmed == true && context.mounted) {
                              await addressProvider.deleteAddress(address.id);
                              if (context.mounted) {
                                Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
                                    content: Text(
                                      'Address deleted successfully',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Address details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressDetailRow(Icons.person_outline, address.fullName),
                const SizedBox(height: 8),
                _buildAddressDetailRow(
                  Icons.location_city_outlined,
                  address.streetAddress,
                ),
                const SizedBox(height: 8),
                _buildAddressDetailRow(
                  Icons.map_outlined,
                  '${address.city}, ${address.zipCode}',
                ),
                if (address.phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildAddressDetailRow(Icons.phone_outlined, address.phone),
                ],
              ],
            ),
          ),
          // Set as default button
          if (!address.isDefault)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await addressProvider.setDefaultAddress(address.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Default address updated'),
                        backgroundColor: Colors.green,
        ),
      );
                  }
                },
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Set as Default'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[300]!),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    }

  Widget _buildAddressDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
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
                                  onTap: () => _showTypePickerForDialog(
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
                              instructions: address.instructions,
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
                              }
                            }

                            nameController.dispose();
                            addressController.dispose();
                            cityController.dispose();
                            zipCodeController.dispose();
                            phoneController.dispose();
                            labelController.dispose();
                            typeController.dispose();

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
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
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
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: readOnly
                  ? Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[600],
                    )
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


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final appState = Provider.of<AppState>(context, listen: false);

        // Sync AppState with AuthProvider user
        if (user != null && appState.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appState.login(user);
          });
        }

        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Please log in to checkout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You need to be logged in to proceed with checkout',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(title: 'Checkout', showBackButton: true),
          body: SafeArea(
            child: Column(
              children: [
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Address Section
                        Consumer<AddressProvider>(
                          builder: (context, addressProvider, child) {
                            final addresses = addressProvider.addresses;
                            final defaultAddr = addressProvider.defaultAddress;

                            // Set selected address to default if not set
                            if (_selectedAddressId == null &&
                                defaultAddr != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _selectedAddressId = defaultAddr.id;
                                });
                              });
                            }

                            Address? selectedAddress;
                            if (_selectedAddressId != null) {
                              try {
                                selectedAddress = addresses.firstWhere(
                                  (addr) => addr.id == _selectedAddressId,
                                );
                              } catch (e) {
                                selectedAddress = defaultAddr;
                                _selectedAddressId = defaultAddr?.id;
                              }
                            } else {
                              selectedAddress = defaultAddr;
                              _selectedAddressId = defaultAddr?.id;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.blue.shade700,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Delivery Address',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed:
                                          () => _showAddressManagementDialog(
                                            context,
                                            addresses,
                                          ),
                                      icon: Icon(Icons.edit, size: 16),
                                      label: Text('Manage'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),

                                // Show address selection or selected address based on state
                                if (addresses.isNotEmpty) ...[
                                  if (_showAddressSelection) ...[
                                  // Address Selection Dropdown
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Select Delivery Address',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        ...addresses.map(
                                          (address) => Container(
                                            margin: EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    _selectedAddressId ==
                                                            address.id
                                                        ? Colors.blue
                                                        : Colors.grey[300]!,
                                                width:
                                                    _selectedAddressId ==
                                                            address.id
                                                        ? 2
                                                        : 1,
                                              ),
                                            ),
                                            child: RadioListTile<String>(
                                              value: address.id,
                                              groupValue: _selectedAddressId,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedAddressId = value;
                                                    _showAddressSelection = false;
                                                });
                                              },
                                              title: Row(
                                                children: [
                                                  Text(
                                                    address.label,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (address.isDefault) ...[
                                                    SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'Default',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 4),
                                                  Text(
                                                    address.fullName,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    address.streetAddress,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${address.city}, ${address.zipCode}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  if (address.phone.isNotEmpty)
                                                    Text(
                                                      address.phone,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              dense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          onPressed: _startAddingNewAddress,
                                          icon: Icon(Icons.add, size: 18),
                                          label: Text('Add New Address'),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: Size(
                                              double.infinity,
                                              40,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ] else if (selectedAddress != null) ...[
                                    // Display Selected Address
                                  Container(
                                      padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.blue.shade200,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.blue.shade700,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                        Text(
                                                    'Selected Address',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                                      color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _showAddressSelection = true;
                                                  });
                                                },
                                                child: Text(
                                                  'Change',
                                                  style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              ),
                                            ),
                                          ],
                                        ),
                                          SizedBox(height: 12),
                                          Text(
                                            selectedAddress.fullName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                        ),
                                          SizedBox(height: 4),
                                          Text(selectedAddress.streetAddress),
                                          Text(
                                            '${selectedAddress.city}, ${selectedAddress.zipCode}',
                                          ),
                                          if (selectedAddress
                                              .phone
                                              .isNotEmpty) ...[
                                            SizedBox(height: 4),
                                        Row(
                                          children: [
                                                Icon(
                                                  Icons.phone,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                            ),
                                                SizedBox(width: 4),
                                                Text(selectedAddress.phone),
                                          ],
                                        ),
                                          ],
                                      ],
                                    ),
                                  ),
                                  ],
                                ] else ...[
                                  // No addresses - show add form
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.location_off,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No addresses saved',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add a delivery address to continue',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () => _showAddAddressDialog(context),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Address'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black87,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 16),

                        // Order Summary Section
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            final cartItems = cartProvider.items;
                            final subtotal = cartProvider.total;
                            final deliveryFee = subtotal >= 25 ? 0 : 3.99;
                            final tax = subtotal * 0.08;
                            final finalTotal = subtotal + deliveryFee + tax;

                            return Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.receipt_long,
                                          color: Colors.green.shade700,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Order Summary',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Cart Items
                                  ...cartItems
                                      .map(
                                        (item) => Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: ImageWithFallback(
                                                  imageUrl: item.image,
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors
                                                                .textPrimary,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade100,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            'Qty: ${item.quantity}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  AppColors
                                                                      .textSecondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          '\$${item.price.toStringAsFixed(2)} each',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                AppColors
                                                                    .textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      cartProvider.removeItem(
                                                        item.id,
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '${item.name} removed from cart',
                                                          ),
                                                          duration: Duration(
                                                            seconds: 2,
                                                          ),
                                                          backgroundColor:
                                                              Colors.orange,
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                      color:
                                                          Colors.red.shade400,
                                                      size: 22,
                                                    ),
                                                    tooltip: 'Remove item',
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),

                                  SizedBox(height: 16),
                                  Divider(color: Colors.grey.shade300),
                                  SizedBox(height: 12),

                                  // Totals
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '\$${subtotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Delivery Fee',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '\$${deliveryFee.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tax',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '\$${tax.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Divider(color: Colors.grey.shade300),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '\$${finalTotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 24),

                        // Continue to Payment Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, Colors.black],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.read<NavigationProvider>().navigateTo(
                                  AppPage.payment,
                                  data: {'fromCheckout': true},
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue to Payment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),
                      ],
                    ),
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
