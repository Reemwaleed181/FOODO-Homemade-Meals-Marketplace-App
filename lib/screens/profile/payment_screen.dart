import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/bottom_navigation.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      name: 'Visa ending in 4242',
      details: 'Expires 12/25',
      lastFour: '4242',
      expiryDate: '12/25',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      type: 'paypal',
      name: 'PayPal',
      details: 'jane.doe@email.com',
      isDefault: false,
    ),
  ];

  bool _isAddingCard = false;
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _zipCodeController = TextEditingController();

  Map<String, bool> _billingSettings = {
    'savePaymentInfo': true,
    'autoReorder': false,
    'emailReceipts': true,
  };

  void _addCard() {
    if (_cardNumberController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty &&
        _nameController.text.isNotEmpty) {

      final lastFour = _cardNumberController.text.length > 4
          ? _cardNumberController.text.substring(_cardNumberController.text.length - 4)
          : '';

      final newCard = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'card',
        name: 'Card ending in $lastFour',
        details: 'Expires ${_expiryDateController.text}',
        lastFour: lastFour,
        expiryDate: _expiryDateController.text,
        isDefault: _paymentMethods.isEmpty,
      );

      setState(() {
        _paymentMethods.add(newCard);
        _isAddingCard = false;
        _clearCardForm();
      });
    }
  }

  void _clearCardForm() {
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _nameController.clear();
    _zipCodeController.clear();
  }

  void _deletePayment(String id) {
    setState(() => _paymentMethods.removeWhere((method) => method.id == id));
  }

  void _setDefaultPayment(String id) {
    setState(() {
      _paymentMethods.forEach((method) {
        method.isDefault = method.id == id;
      });
    });
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card': return Icons.credit_card;
      case 'paypal': return Icons.payment;
      case 'apple-pay': return Icons.phone_iphone;
      case 'google-pay': return Icons.phone_android;
      default: return Icons.credit_card;
    }
  }

  String _formatCardNumber(String value) {
    // Implement card number formatting
    return value;
  }

  @override
  Widget build(BuildContext context) {
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
                    'Payment Methods',
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
                  // Payment methods
                  Text('Saved Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  Column(
                    children: _paymentMethods.map((method) => _PaymentMethodCard(
                      method: method,
                      onSetDefault: _setDefaultPayment,
                      onDelete: _deletePayment,
                    )).toList(),
                  ),

                  // Add card form
                  if (_isAddingCard) _AddCardForm(
                    cardNumberController: _cardNumberController,
                    expiryDateController: _expiryDateController,
                    cvvController: _cvvController,
                    nameController: _nameController,
                    zipCodeController: _zipCodeController,
                    onAdd: _addCard,
                    onCancel: () => setState(() => _isAddingCard = false),
                  ),

                  // Add card button
                  if (!_isAddingCard)
                    CustomButton(
                      text: 'Add Card',
                      variant: ButtonVariant.outline,
                      icon: Icon(Icons.add),
                      onPressed: () => setState(() => _isAddingCard = true),
                    ),

                  SizedBox(height: 32),
                  Text('Quick Payment Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Quick payment options
                  _QuickPaymentOption(
                    icon: Icons.phone_iphone,
                    title: 'Apple Pay',
                    subtitle: 'Pay with Touch ID or Face ID',
                    color: Colors.black,
                  ),
                  SizedBox(height: 8),
                  _QuickPaymentOption(
                    icon: Icons.payment,
                    title: 'PayPal',
                    subtitle: 'Pay with your PayPal account',
                    color: Colors.blue,
                  ),

                  SizedBox(height: 32),
                  Text('Billing Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  // Billing settings
                  _BillingSetting(
                    title: 'Save payment information',
                    subtitle: 'Securely store cards for faster checkout',
                    value: _billingSettings['savePaymentInfo']!,
                    onChanged: (value) => setState(() => _billingSettings['savePaymentInfo'] = value),
                  ),
                  Divider(),
                  _BillingSetting(
                    title: 'Email receipts',
                    subtitle: 'Get email confirmations for all orders',
                    value: _billingSettings['emailReceipts']!,
                    onChanged: (value) => setState(() => _billingSettings['emailReceipts'] = value),
                  ),

                  // Security info
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.green),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Secure & Encrypted', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('All payment information is encrypted and secure'),
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
}

class PaymentMethod {
  final String id;
  final String type;
  final String name;
  final String details;
  final String? lastFour;
  final String? expiryDate;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    this.lastFour,
    this.expiryDate,
    required this.isDefault,
  });
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final Function(String) onSetDefault;
  final Function(String) onDelete;

  const _PaymentMethodCard({
    required this.method,
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
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getPaymentIcon(method.type), size: 24, color: Colors.blue),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(method.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          if (method.isDefault) ...[
                            SizedBox(width: 8),
                            Chip(
                              label: Text('Default'),
                              backgroundColor: Colors.blue,
                              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      Text(method.details, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => onDelete(method.id),
                ),
              ],
            ),
            if (!method.isDefault)
              TextButton(
                onPressed: () => onSetDefault(method.id),
                child: Text('Set as Default'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card': return Icons.credit_card;
      case 'paypal': return Icons.payment;
      case 'apple-pay': return Icons.phone_iphone;
      case 'google-pay': return Icons.phone_android;
      default: return Icons.credit_card;
    }
  }
}

class _AddCardForm extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryDateController;
  final TextEditingController cvvController;
  final TextEditingController nameController;
  final TextEditingController zipCodeController;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _AddCardForm({
    required this.cardNumberController,
    required this.expiryDateController,
    required this.cvvController,
    required this.nameController,
    required this.zipCodeController,
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
            Text('Add New Card', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            CustomInput(
              controller: cardNumberController,
              label: 'Card Number',
              hintText: '1234 5678 9012 3456',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    controller: expiryDateController,
                    label: 'Expiry Date',
                    hintText: 'MM/YY',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomInput(
                    controller: cvvController,
                    label: 'CVV',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            CustomInput(
              controller: nameController,
              label: 'Cardholder Name',
            ),
            SizedBox(height: 16),
            CustomInput(
              controller: zipCodeController,
              label: 'Billing ZIP Code',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                CustomButton(text: 'Add Card', onPressed: onAdd),
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
}

class _QuickPaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _QuickPaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _BillingSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BillingSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}