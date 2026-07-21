import 'package:flutter/material.dart';
import 'package:pdf_read/screen/checkout/CheckoutScreen.dart';
import 'package:pdf_read/screen/plan/provider/PlanListProvider.dart';
import 'package:provider/provider.dart';
import 'model/plan_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int selectedIndex = 0;
  bool isYearly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanProvider>().fetchPlans();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Plan> get _filteredPlans => context.read<PlanProvider>().plans;

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
          "Choose Your Plan",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PlanProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.fetchPlans();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = _filteredPlans;
          if (plans.isEmpty) {
            return const Center(
              child: Text('No plans available.'),
            );
          }

          if (selectedIndex >= plans.length) {
            selectedIndex = 0;
          }

          return Column(
            children: [
              const SizedBox(height: 10),
              _buildToggle(),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: plans.length,
                  onPageChanged: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isSelected = selectedIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: isSelected ? 10 : 40,
                      ),
                      transform: Matrix4.identity()
                        ..scale(isSelected ? 1.0 : 0.88),
                      child: _buildPlanCard(plan, isSelected,provider),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  plans.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: selectedIndex == index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? const Color(0xff0288D1)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      width: 280,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                isYearly = false;
                selectedIndex = 0;
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: !isYearly ? const Color(0xff0288D1) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    "Monthly",
                    style: TextStyle(
                      color: !isYearly ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                isYearly = true;
                selectedIndex = 0;
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }),
              child: Container (
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isYearly
                      ? const LinearGradient(
                    colors: [Color(0xff4FC3F7), Color(0xff0288D1)],
                  )
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Yearly",
                    style: TextStyle(
                      color: isYearly ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPlanCard(Plan plan, bool isSelected,provider) {

    final features = plan.planMasters.map((pm) {
      final name = pm.master.name;
      if (pm.count > 0) {
        return '${pm.count} $name';
      } else {
        return name;
      }
    }).toList();


    final displayPrice = isYearly ? plan.yearlyAmount : plan.price;
    final discountPrice = isYearly ? plan.discountAmount +displayPrice:0;
    final displayCurrency = isYearly ? 'year' : 'month';

    String? discountText;
    if (isYearly && plan.discountPercentage > 0) {
      discountText = 'Save ₹${plan.discountPercentage}%';
    }

    // Determine if this is a free/default plan
    final isFreePlan = plan.planTypes.toLowerCase() == 'default';
    final isSubscribed = plan.subscribed == true;
    final isBuyNow = plan.buyNow == true;

    // Determine button text and behavior
    String buttonText;
    VoidCallback? onPressed;

    if (isSubscribed) {
      buttonText = 'Subscribed';
      onPressed = null; // disabled
    } else if (isFreePlan) {
      buttonText = 'Free 1 Month';
      onPressed = null;
    } else {
      buttonText = 'BUY NOW';
      onPressed = () {

        if(!isBuyNow){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.strbuyNowFalseMessage ?? 'can not purchase lower plan..!',
              ),
              backgroundColor: Colors.red,
            ),
          );

        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                billingCycle: isYearly ? 'yearly' : 'monthly',
                planId: plan.id,
                planName: plan.planName,
                planDescription: isYearly ? 'Yearly Plan' : 'Monthly Plan',
                price: displayPrice,
                isYearly: isYearly,
                discountAmount: plan.discountAmount,
                yearlyAmount: plan.yearlyAmount,
              ),
            ),
          );
        }


      };
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSelected ? const Color(0xff0288D1) : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.blue.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Row: Image + Title/Description + Badge ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Plan Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: plan.planImage.isNotEmpty
                      ? Image.network(
                    plan.planImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                // Plan name and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.planName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFreePlan ? 'Free Plan' : 'Premium Plan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFreePlan
                            ? 'Get started with essential features'
                            : 'Get access to all premium features',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge (Free or Subscribed)
                if (isFreePlan || isSubscribed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFreePlan ? Colors.green[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFreePlan ? 'FREE' : 'SUBSCRIBED',
                      style: TextStyle(
                        color: isFreePlan ? Colors.green[800] : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ─── Price Row ──────────────────────────────────────────────
            // For free plan, show "Free" instead of price
            if (!isFreePlan) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  if ( isYearly && plan.price > 0) ...[
                    const SizedBox(width: 12),
                    Text(
                      "₹${discountPrice}", // monthly price with strikethrough
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "/ month",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                  Text(
                    "₹$displayPrice",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "/ $displayCurrency",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                ],
              ),
            ] else ...[
              Row(
                children: [
                  const Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ forever',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            if (discountText != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  discountText,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // ─── Features ──────────────────────────────────────────────
            ...features.map(
                  (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xff0288D1),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Action Button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSubscribed
                      ? Colors.grey[400]
                      : (isFreePlan ? Colors.green : const Color(0xff0288D1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: isSubscribed ? Colors.white : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}