import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/bottom_navigation.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final List<DeliveryAddress> _addresses = [];
  bool _isAddingAddress = false;
  final _typeController = TextEditingController(text: 'home');
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.user;

    if (user != null) {
      _addresses.add(DeliveryAddress(
        id: '1',
        type: 'home',
        label: 'Home',
        address: user.address,
        city: user.city,
        zipCode: user.zipCode,
        isDefault: true,
      ));
    }
  }

  void _addAddress() {
    if (_addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _zipCodeController.text.isNotEmpty) {

      final newAddress = DeliveryAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _typeController.text,
        label: _labelController.text.isNotEmpty
            ? _labelController.text
            : '${_typeController.text} Address',
        address: _addressController.text,
        city: _cityController.text,
        zipCode: _zipCodeController.text,
        instructions: _instructionsController.text,
        isDefault: _addresses.isEmpty,
      );

      setState(() {
        _addresses.add(newAddress);
        _isAddingAddress = false;
        _clearForm();
      });
    }
  }

  void _clearForm() {
    _typeController.text = 'home';
    _labelController.clear();
    _addressController.clear();
    _cityController.clear();
    _zipCodeController.clear();
    _instructionsController.clear();
  }

  void _setDefaultAddress(String id) {
    setState(() {
      _addresses.forEach((addr) {
        addr.isDefault = addr.id == id;
      });
    });
  }

  void _deleteAddress(String id) {
    setState(() => _addresses.removeWhere((addr) => addr.id == id));
  }

  IconData _getAddressIcon(String type) {
    switch (type) {
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      default: return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.user == null) {
      return Scaffold(
        body: Center(
          child: Text('Please log in to manage delivery settings'),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Custom header
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Delivery Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // Foodo Logo
                  Image.asset(
                    'images/logo-removebg.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Address list
                  Column(
                    children: _addresses.map((address) => _AddressCard(
                      address: address,
                      onSetDefault: _setDefaultAddress,
                      onDelete: _deleteAddress,
                    )).toList(),
                  ),

                  // Add address form
                  if (_isAddingAddress) _AddAddressForm(
                    typeController: _typeController,
                    labelController: _labelController,
                    addressController: _addressController,
                    cityController: _cityController,
                    zipCodeController: _zipCodeController,
                    instructionsController: _instructionsController,
                    onAdd: _addAddress,
                    onCancel: () => setState(() => _isAddingAddress = false),
                  ),

                  // Add address button
                  if (!_isAddingAddress)
                    CustomButton(
                      text: 'Add New Address',
                      variant: ButtonVariant.outline,
                      icon: Icon(Icons.add),
                      onPressed: () => setState(() => _isAddingAddress = true),
                    ),

                  SizedBox(height: 32),
                  Text('Delivery Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Delivery preferences
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _PreferenceRow(
                            label: 'Preferred Delivery Time',
                            value: 'Anytime',
                            onTap: () => _showTimePicker(),
                          ),
                          Divider(),
                          _PreferenceRow(
                            label: 'Contact Method',
                            value: 'Call when arriving',
                            onTap: () => _showContactMethodPicker(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Delivery zone info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('You\'re in our delivery zone!', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Free delivery on orders over \$25 • Delivery time: 30-45 minutes'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  void _showTimePicker() {
    // Implement time picker
  }

  void _showContactMethodPicker() {
    // Implement contact method picker
  }
}

class DeliveryAddress {
  final String id;
  final String type;
  final String label;
  final String address;
  final String city;
  final String zipCode;
  final String? instructions;
  bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.type,
    required this.label,
    required this.address,
    required this.city,
    required this.zipCode,
    this.instructions,
    required this.isDefault,
  });
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final Function(String) onSetDefault;
  final Function(String) onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getAddressIcon(address.type), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(address.label, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (address.isDefault)
                  Chip(
                    label: Text('Default'),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(address.address),
            Text('${address.city}, ${address.zipCode}'),
            if (address.instructions != null) ...[
              SizedBox(height: 4),
              Text('Instructions: ${address.instructions}', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            SizedBox(height: 16),
            Row(
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => onSetDefault(address.id),
                    child: Text('Set as Default'),
                  ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => onDelete(address.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAddressIcon(String type) {
    switch (type) {
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      default: return Icons.location_on;
    }
  }
}

class _AddAddressForm extends StatelessWidget {
  final TextEditingController typeController;
  final TextEditingController labelController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController zipCodeController;
  final TextEditingController instructionsController;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _AddAddressForm({
    required this.typeController,
    required this.labelController,
    required this.addressController,
    required this.cityController,
    required this.zipCodeController,
    required this.instructionsController,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    controller: typeController,
                    label: 'Address Type',
                    readOnly: true,
                    onTap: () => _showTypePicker(context),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomInput(
                    controller: labelController,
                    label: 'Label (Optional)',
                    hintText: 'e.g., Mom\'s House',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CustomInput(
              controller: addressController,
              label: 'Street Address',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    controller: cityController,
                    label: 'City',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomInput(
                    controller: zipCodeController,
                    label: 'ZIP Code',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CustomInput(
              controller: instructionsController,
              label: 'Delivery Instructions (Optional)',
              hintText: 'e.g., Ring doorbell, Leave at door',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CustomButton(text: 'Add Address', onPressed: onAdd),
                SizedBox(width: 8),
                CustomButton(
                  text: 'Cancel',
                  variant: ButtonVariant.outline,
                  onPressed: onCancel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Home'),
            onTap: () {
              typeController.text = 'home';
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Work'),
            onTap: () {
              typeController.text = 'work';
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Other'),
            onTap: () {
              typeController.text = 'other';
              Navigator.pop(context);
            },
          ),
        ],
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}