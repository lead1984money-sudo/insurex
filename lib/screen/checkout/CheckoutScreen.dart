import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_read/screen/checkout/provider/CheckoutProvider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/razorpay/RazorpayService.dart';
import '../plan/SubscriptionScreen.dart';


class CheckoutScreen extends StatefulWidget {
  final String planName;
  final String planDescription;
  final int price;
  final bool isYearly;
  final int planId;
  final String billingCycle; // 'monthly' or 'yearly'
  final int discountAmount;
  final int yearlyAmount;

  const CheckoutScreen({
    super.key,
    required this.planName,
    required this.planDescription,
    required this.price,
    required this.isYearly,
    required this.planId,
    required this.billingCycle,
    required this.discountAmount,
    required this.yearlyAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late RazorpayService razorpayService;
  final TextEditingController couponController = TextEditingController();
  double discount = 0.0;
  bool couponApplied = false;

  @override
  void initState() {
    super.initState();
    razorpayService = RazorpayService(
      onSuccess: _onPaymentSuccess,
      onFailure: _onPaymentFailure,
      onExternalWallet: _onExternalWallet,
    );
  }

  @override
  void dispose() {
    razorpayService.dispose();
    couponController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent accidental close
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildSuccessContent(context, paymentId),
        );
      },
    ).then((_) {
      // After dialog closes, pop the checkout screen
      if (mounted) {
        Navigator.of(context).pop(); // returns to previous screen
      }
    });
  }

  // ---- Payment Callbacks ----
  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    print("=== Payment Success ===");
    print("Payment ID: ${response.paymentId}");
    print("Order ID: ${response.orderId}");
    print("Signature: ${response.signature}");
    print("Data: ${response.data}");
    print("Raw response: $response");

    // If data is a Map, extract extra fields
    if (response.data is Map) {
      final dataMap = response.data as Map;
      print("Extra data: $dataMap");
    }

    final provider = context.read<PaymentProvider>();
    final success = await provider.completePayment(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
      status: 1,
      planId: widget.planId,
      billingCycle: widget.billingCycle,
      amount: widget.price.toDouble(),
    );

    if (success && mounted) {
      //Navigator.pop(context);
      _showSuccessDialog(response.paymentId ?? 'N/A');

    } else if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  Widget _buildSuccessContent(BuildContext context, String paymentId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          const Text(
            'Your payment has been processed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),

          // Payment ID Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paymentId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Copy button
                IconButton (
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: paymentId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment ID copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white70,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // OK button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF203A43),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPaymentFailure(PaymentFailureResponse response) async {
    print("=== Payment Failure ===");
    print("Code: ${response.code}");
    print("Message: ${response.message}");

    final provider = context.read<PaymentProvider>();
    await provider.completePayment(
      orderId: '',
      paymentId: '',
      signature: '',
      status: 0,
      planId: widget.planId,
      billingCycle: widget.billingCycle,
      amount: widget.price.toDouble(),
      reasonFail: response.message ?? 'Payment failed',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.message}')),
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  // ---- Coupon Logic ----
  double get subtotal => widget.price.toDouble();
  double get discountAmount => discount;
  double get gst => (subtotal - discountAmount) * 0.18;
  double get total => (subtotal - discountAmount) + gst;

  void applyCoupon() {
    final code = couponController.text.trim().toUpperCase();
    setState(() {
      if (code == 'SAVE100') {
        discount = 100.0;
        couponApplied = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon applied!')),
        );
      } else {
        discount = 0.0;
        couponApplied = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coupon code')),
        );
      }
    });
  }

  // ---- Build ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isProcessing) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanDetails(),
                const SizedBox(height: 24),
                _buildCouponSection(),
                const SizedBox(height: 24),
                _buildBillDetails(),
                const SizedBox(height: 24),
                _buildPayButton(),
                const SizedBox(height: 16),
                _buildSecurityBadges(),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms & Conditions',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- UI Components ----
  Widget _buildPlanDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Plan', widget.planName),
          _buildDetailRow('Policies', widget.planDescription),
          _buildDetailRow(
            'Price',
            '₹${widget.price} / ${widget.isYearly ? 'Year' : 'Month'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have a coupon code?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                    enabled: !couponApplied,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: couponApplied ? null : applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4FC3F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: Text(
                  couponApplied ? 'Applied' : 'Apply',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          if (couponApplied)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Coupon applied! ₹${discount.toStringAsFixed(2)} off',
                style: TextStyle(color: Colors.green[700], fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          _buildBillRow('Discount', '- ₹${discountAmount.toStringAsFixed(2)}',
              color: Colors.green),
          _buildBillRow('GST (18%)', 'Included'),
          const Divider(),
          _buildBillRow(
            'Total',
            '₹${subtotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: color ?? (isTotal ? Colors.black87 : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return InkWell(
      onTap: () async {
        final provider = context.read<PaymentProvider>();
        print("LINE548====>>>"+widget.isYearly.toString());
        print("LINE548====>>>"+widget.billingCycle.toString());
        // Show loader while creating order
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );


        final orderId = await provider.createOrder(
            amount: widget.isYearly
              ? widget.yearlyAmount.toDouble()
              : widget.price.toDouble(),
            planId:widget.planId.toString(),
          discountAmount: widget.isYearly
              ? widget.discountAmount.toString()
              : "0",
          billingCycle: widget.billingCycle,
        );

        if (!mounted) return;
        Navigator.of(context).pop(); // dismiss loader

        print("OrderID====>>>"+orderId.toString());

        if (orderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage)),
          );
          return;
        }

        final amountInPaise = (total * 100).toDouble();
        razorpayService.openCheckout(
          amount: amountInPaise,
          name: 'InsureX',
          description: 'Subscription Payment',
          contact: '9876543210',
          email: 'test@example.com',
          orderId: orderId,
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xff4FC3F7), Color(0xff0288D1)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 25,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Pay Securely',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBadge(Icons.lock, '256-bit SSL Secured'),
        const SizedBox(width: 24),
        _buildBadge(Icons.receipt, 'GST Invoice Available'),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}