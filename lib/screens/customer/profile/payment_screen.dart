import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/app_state.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_input.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod; // 'cash', 'card', 'quick_payment'
  String? _selectedQuickPayment; // 'apple_pay', 'paypal', 'google_pay'
  bool _isCardExpanded = false;
  bool _isQuickPaymentExpanded = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      name: 'Visa ending in 4242',
      details: 'Expires 12/25',
      lastFour: '4242',
      expiryDate: '12/25',
      cardType: 'visa',
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
  String? _editingCardId;
  String? _selectedCardType; // 'visa', 'mastercard', 'discover'
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  Map<String, bool> _billingSettings = {
    'savePaymentInfo': true,
    'emailReceipts': true,
  };

  void _addCard() {
    if (_cardNumberController.text.isNotEmpty &&
        _expiryMonthController.text.isNotEmpty &&
        _expiryYearController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _selectedCardType != null) {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final lastFour =
          cardNumber.length >= 4
              ? cardNumber.substring(cardNumber.length - 4)
              : cardNumber;
      final expiryDate =
          '${_expiryMonthController.text}/${_expiryYearController.text}';

      final newCard = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'card',
        name: '${_nameController.text} ending in $lastFour',
        details: 'Expires $expiryDate',
        lastFour: lastFour,
        expiryDate: expiryDate,
        cardType: _selectedCardType,
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
    _expiryMonthController.clear();
    _expiryYearController.clear();
    _cvvController.clear();
    _nameController.clear();
    _selectedCardType = null;
  }

  void _editPayment(String id) {
    final method = _paymentMethods.firstWhere((m) => m.id == id);
    setState(() {
      _editingCardId = id;
      _isAddingCard = false;
      // Extract cardholder name (remove " ending in XXXX" part)
      String cardholderName = method.name;
      if (method.lastFour != null && cardholderName.contains(' ending in ')) {
        cardholderName = cardholderName.split(' ending in ')[0];
      }
      _nameController.text = cardholderName;
      // For card number, show the last 4 digits (we don't store full number for security)
      // In a real app, you'd decrypt or retrieve the full number from secure storage
      _cardNumberController.text = method.lastFour ?? '';
      // Parse expiry date into month and year
      if (method.expiryDate != null && method.expiryDate!.contains('/')) {
        final parts = method.expiryDate!.split('/');
        if (parts.length == 2) {
          _expiryMonthController.text = parts[0];
          _expiryYearController.text = parts[1];
        }
      }
      _selectedCardType = method.cardType;
      _cvvController.text = '';
    });
  }

  void _updateCard() {
    if (_editingCardId != null &&
        _cardNumberController.text.isNotEmpty &&
        _expiryMonthController.text.isNotEmpty &&
        _expiryYearController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _selectedCardType != null) {
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final lastFour =
          cardNumber.length >= 4
              ? cardNumber.substring(cardNumber.length - 4)
              : cardNumber;
      final expiryDate =
          '${_expiryMonthController.text}/${_expiryYearController.text}';

      setState(() {
        final index = _paymentMethods.indexWhere((m) => m.id == _editingCardId);
        if (index != -1) {
          _paymentMethods[index] = PaymentMethod(
            id: _editingCardId!,
            type: 'card',
            name: '${_nameController.text} ending in $lastFour',
            details: 'Expires $expiryDate',
            lastFour: lastFour,
            expiryDate: expiryDate,
            cardType: _selectedCardType,
            isDefault: _paymentMethods[index].isDefault,
          );
        }
        _editingCardId = null;
        _clearCardForm();
      });
    }
  }

  void _deletePayment(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Card'),
            content: const Text('Are you sure you want to delete this card?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _paymentMethods.removeWhere((method) => method.id == id);
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _setDefaultPayment(String id) {
    setState(() {
      _paymentMethods.forEach((method) {
        method.isDefault = method.id == id;
      });
    });
  }

  bool _isFromCheckout(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    return navigationProvider.pageData['fromCheckout'] == true;
  }

  Future<void> _placeOrder(BuildContext context) async {
    // Validate payment method is selected
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate card selection if card payment is selected
    if (_selectedPaymentMethod == 'card') {
      final hasCard = _paymentMethods.any((m) => m.type == 'card');
      if (!hasCard) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add a card or select another payment method'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate quick payment selection if quick payment is selected
    if (_selectedPaymentMethod == 'quick_payment' &&
        _selectedQuickPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a quick payment option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    // Clear cart and navigate to order confirmation
    final cartProvider = context.read<CartProvider>();
    final appState = context.read<AppState>();

    cartProvider.clearCart();
    appState.clearCart();

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      context.read<NavigationProvider>().navigateTo(AppPage.orderConfirmation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFromCheckout = _isFromCheckout(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: isFromCheckout ? 'Select Payment Method' : 'Payment Methods',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Cash on Delivery Option
            _PaymentMethodSelector(
              icon: Icons.money,
              iconColor: Colors.green,
              title: 'Cash on Delivery',
              isSelected: _selectedPaymentMethod == 'cash',
              onTap:
                  () => setState(() {
                    _selectedPaymentMethod = 'cash';
                    _isCardExpanded = false;
                    _isQuickPaymentExpanded = false;
                  }),
            ),

            const SizedBox(height: 16),

            // Card Option
            _PaymentMethodSelector(
              icon: Icons.credit_card,
              iconColor: Colors.blue,
              title: 'Credit/Debit Card',
              isSelected: _selectedPaymentMethod == 'card',
              onTap:
                  () => setState(() {
                    _selectedPaymentMethod = 'card';
                    _isCardExpanded = !_isCardExpanded;
                    _isQuickPaymentExpanded = false;
                  }),
              isExpanded: _isCardExpanded,
              expandedContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saved Cards',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        onPressed:
                            () =>
                                setState(() => _isAddingCard = !_isAddingCard),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Card'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Payment Methods List
                  if (!_isAddingCard && _editingCardId == null)
                    ..._paymentMethods
                        .where((m) => m.type == 'card')
                        .map(
                          (method) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PaymentMethodCard(
                              method: method,
                              onSetDefault: _setDefaultPayment,
                              onEdit: _editPayment,
                              onDelete: _deletePayment,
                            ),
                          ),
                        ),

                  // Add Card Form
                  if (_isAddingCard)
                    _AddCardForm(
                      cardNumberController: _cardNumberController,
                      expiryMonthController: _expiryMonthController,
                      expiryYearController: _expiryYearController,
                      cvvController: _cvvController,
                      nameController: _nameController,
                      selectedCardType: _selectedCardType,
                      onCardTypeSelected:
                          (type) => setState(() => _selectedCardType = type),
                      onAdd: _addCard,
                      onCancel:
                          () => setState(() {
                            _isAddingCard = false;
                            _clearCardForm();
                          }),
                    ),

                  // Edit Card Form
                  if (_editingCardId != null)
                    _AddCardForm(
                      cardNumberController: _cardNumberController,
                      expiryMonthController: _expiryMonthController,
                      expiryYearController: _expiryYearController,
                      cvvController: _cvvController,
                      nameController: _nameController,
                      selectedCardType: _selectedCardType,
                      onCardTypeSelected:
                          (type) => setState(() => _selectedCardType = type),
                      onAdd: _updateCard,
                      onCancel:
                          () => setState(() {
                            _editingCardId = null;
                            _clearCardForm();
                          }),
                      isEditing: true,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Payment Options
            _PaymentMethodSelector(
              icon: Icons.flash_on,
              iconColor: Colors.orange,
              title: 'Quick Payment Options',
              isSelected: _selectedPaymentMethod == 'quick_payment',
              onTap:
                  () => setState(() {
                    _selectedPaymentMethod = 'quick_payment';
                    _isQuickPaymentExpanded = !_isQuickPaymentExpanded;
                    _isCardExpanded = false;
                  }),
              isExpanded: _isQuickPaymentExpanded,
              expandedContent: Column(
                children: [
                  const SizedBox(height: 16),
                  _QuickPaymentOption(
                    imagePath: 'images/applepay.png',
                    title: 'Apple Pay',
                    subtitle: 'Pay with Touch ID or Face ID',
                    isSelected: _selectedQuickPayment == 'apple_pay',
                    onTap:
                        () =>
                            setState(() => _selectedQuickPayment = 'apple_pay'),
                  ),
                  const SizedBox(height: 12),
                  _QuickPaymentOption(
                    imagePath: 'images/paypal.png',
                    title: 'PayPal',
                    subtitle: 'Pay with your PayPal account',
                    isSelected: _selectedQuickPayment == 'paypal',
                    onTap:
                        () => setState(() => _selectedQuickPayment = 'paypal'),
                  ),
                  const SizedBox(height: 12),
                  _QuickPaymentOption(
                    imagePath: 'images/googlepay.png',
                    title: 'Google Pay',
                    subtitle: 'Pay with your Google account',
                    isSelected: _selectedQuickPayment == 'google_pay',
                    onTap:
                        () => setState(
                          () => _selectedQuickPayment = 'google_pay',
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Billing Settings Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                      Icon(
                        Icons.attach_money,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Billing Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _BillingSetting(
                    title: 'Save payment information',
                    subtitle: 'Securely store cards for faster checkout',
                    value: _billingSettings['savePaymentInfo']!,
                    onChanged:
                        (value) => setState(
                          () => _billingSettings['savePaymentInfo'] = value,
                        ),
                  ),
                  const Divider(height: 32),
                  _BillingSetting(
                    title: 'Email receipts',
                    subtitle: 'Get email confirmations for all orders',
                    value: _billingSettings['emailReceipts']!,
                    onChanged:
                        (value) => setState(
                          () => _billingSettings['emailReceipts'] = value,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Security Notification Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.security, color: Colors.green[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your payments are secure',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All payment information is encrypted and processed securely through industry-standard protocols.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
      bottomNavigationBar:
          _isFromCheckout(context)
              ? Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final subtotal = cartProvider.total;
                  final deliveryFee = subtotal >= 25 ? 0 : 3.99;
                  final tax = subtotal * 0.08;
                  final finalTotal = subtotal + deliveryFee + tax;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Order Summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '\$${finalTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Complete Order Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _placeOrder(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Complete Order',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.check_circle, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : null,
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
  final String? cardType; // 'visa', 'mastercard', 'discover'
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    this.lastFour,
    this.expiryDate,
    this.cardType,
    required this.isDefault,
  });
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final Function(String) onSetDefault;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const _PaymentMethodCard({
    required this.method,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Card Logo or Icon
              if (method.cardType != null)
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      method.cardType == 'visa'
                          ? 'images/visa.png'
                          : method.cardType == 'mastercard'
                          ? 'images/mastercard.png'
                          : 'images/Discover.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading saved card image: $error');
                        return Icon(
                          Icons.credit_card,
                          size: 24,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        method.type == 'card'
                            ? Colors.blue[50]
                            : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method.type == 'card'
                        ? Icons.credit_card
                        : Icons.account_balance_wallet,
                    color:
                        method.type == 'card'
                            ? Colors.blue[700]
                            : Colors.orange[700],
                    size: 24,
                  ),
                ),
              const SizedBox(width: 16),
              // Card Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cardholder Name
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            method.name.contains(' ending in ')
                                ? method.name.split(' ending in ')[0]
                                : method.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (method.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
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
                    const SizedBox(height: 6),
                    // Card Number (last 4 digits)
                    if (method.lastFour != null)
                      Text(
                        '**** **** **** ${method.lastFour}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Expiry Date
                    Text(
                      method.expiryDate != null
                          ? 'Expires ${method.expiryDate}'
                          : method.details,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Edit and Delete Icons
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
                onPressed: () => onEdit(method.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red[400],
                ),
                onPressed: () => onDelete(method.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Delete',
              ),
            ],
          ),
          // Set as Default Button (for non-default methods)
          if (!method.isDefault) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => onSetDefault(method.id),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Set as Default',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddCardForm extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryMonthController;
  final TextEditingController expiryYearController;
  final TextEditingController cvvController;
  final TextEditingController nameController;
  final String? selectedCardType;
  final Function(String) onCardTypeSelected;
  final VoidCallback onAdd;
  final VoidCallback onCancel;
  final bool isEditing;

  const _AddCardForm({
    required this.cardNumberController,
    required this.expiryMonthController,
    required this.expiryYearController,
    required this.cvvController,
    required this.nameController,
    required this.selectedCardType,
    required this.onCardTypeSelected,
    required this.onAdd,
    required this.onCancel,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            isEditing ? 'Edit Card' : 'Add New Card',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          CustomInput(
            controller: nameController,
            label: 'Cardholder Name',
            hintText: 'Enter cardholder name',
          ),
          const SizedBox(height: 20),
          // Card Type Selection
          const Text(
            'Card Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CardTypeOption(
                  type: 'visa',
                  imagePath: 'images/visa.png',
                  isSelected: selectedCardType == 'visa',
                  onTap: () => onCardTypeSelected('visa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardTypeOption(
                  type: 'mastercard',
                  imagePath: 'images/mastercard.png',
                  isSelected: selectedCardType == 'mastercard',
                  onTap: () => onCardTypeSelected('mastercard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardTypeOption(
                  type: 'discover',
                  imagePath: 'images/Discover.png',
                  isSelected: selectedCardType == 'discover',
                  onTap: () => onCardTypeSelected('discover'),
                ),
              ),
            ],
          ),
          // Show selected card logo
          if (selectedCardType != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  height: 50,
                  width: 120,
                  child: Image.asset(
                    selectedCardType == 'visa'
                        ? 'images/visa.png'
                        : selectedCardType == 'mastercard'
                        ? 'images/mastercard.png'
                        : 'images/Discover.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading selected card image: $error');
                      return Icon(
                        Icons.credit_card,
                        size: 40,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
                  CardNumberFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  controller: expiryMonthController,
                  label: 'Expiry Month',
                  hintText: 'MM',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomInput(
                  controller: expiryYearController,
                  label: 'Expiry Year',
                  hintText: 'YY',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CVV',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        hintText: '...',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isEditing ? 'Update Card' : 'Add Card'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to Cards'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final Widget? expandedContent;

  const _PaymentMethodSelector({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isExpanded = false,
    this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? iconColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
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
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: iconColor, size: 24),
                  if (expandedContent != null)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded && expandedContent != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: expandedContent!,
            ),
        ],
      ),
    );
  }
}

class _QuickPaymentOption extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickPaymentOption({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.payment, size: 24, color: Colors.grey);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue, size: 24),
          ],
        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: value ? Colors.black87 : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value ? 'On' : 'Off',
              style: TextStyle(
                color: value ? Colors.white : Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Card Type Selection Option
class _CardTypeOption extends StatelessWidget {
  final String type;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardTypeOption({
    required this.type,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: SizedBox(
          height: 35,
          width: double.infinity,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $imagePath - $error');
              return Icon(Icons.credit_card, size: 30, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}

// Card Number Formatter to add spaces every 4 digits
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
