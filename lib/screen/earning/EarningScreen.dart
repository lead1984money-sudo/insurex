import 'package:flutter/material.dart';
import 'package:pdf_read/screen/earning/model/PolicyItem.dart';
import 'package:pdf_read/screen/earning/provider/EarningAddProvider.dart';
import 'package:pdf_read/screen/earning/provider/EarningProvider.dart';
import 'package:provider/provider.dart';
import 'EarningAddScreen.dart';
import 'EarningEditPopup.dart';
import 'EarningViewPopup.dart';
import 'model/EarningItem.dart';


class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EarningsProvider(),
      child: const EarningsView(), // now a StatefulWidget
    );
  }
}

// ---------- EarningsView is now Stateful ----------
class EarningsView extends StatefulWidget {
  const EarningsView({super.key});

  @override
  State<EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<EarningsView> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Fetch data after the first frame to ensure provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        final provider = context.read<EarningsProvider>();

        provider.init();
        _initialized = true;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EarningsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Earnings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true, // <-- This centers the title
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xff6C3EF4),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EarningAddScreen(
                        onEarningCreated: () => provider.init(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER


              // SUMMARY CARDS
              if (provider.isLoading && provider.earnings.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: [
                    infoCard(
                      title: "Gross Amount",
                      value: "₹ ${provider.grossAmount.toStringAsFixed(2)}",
                      color: Colors.deepPurple,
                      icon: Icons.currency_rupee,
                    ),
                    infoCard(
                      title: "Cashback",
                      value: "₹ ${provider.cashback.toStringAsFixed(2)}",
                      color: Colors.orange,
                      icon: Icons.account_balance_wallet,
                    ),
                    infoCard(
                      title: "Net Earning",
                      value: "₹ ${provider.netEarning.toStringAsFixed(2)}",
                      color: Colors.green,
                      icon: Icons.trending_up,
                    ),
                    infoCard(
                      title: "Active Records",
                      value: provider.activeRecords.toString(),
                      color: Colors.blue,
                      icon: Icons.verified_user_outlined,
                    ),
                  ],
                ),

              const SizedBox(height: 25),

              // FILTER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: dropdownWidget(
                            value: provider.selectedStatus,
                            items: const [
                              "All Status",
                              "Active",
                              "Inactive"
                            ],
                            onChanged: (v) {
                              provider.updateStatus(v!);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: dropdownWidget(
                            value: provider.selectedPartner,
                            items: [
                              "All Partners",
                              ...provider.partners.map((p) => p.name).toList(),
                            ],
                            onChanged: (v) {
                              provider.updatePartner(v!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: provider.searchController,
                      onChanged: (value) {
                        provider.onSearchChanged(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search vehicle no, proposer name...",
                        filled: true,
                        fillColor: const Color(0xffF7F8FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            provider.resetFilter();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Reset Filter"),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            provider.onSearchChanged(provider.searchController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6C3EF4),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Apply"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // EARNINGS LIST
              if (provider.isLoading && provider.earnings.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (provider.errorMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(provider.errorMessage),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => provider.init(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (provider.earnings.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No earnings found'),
                    ),
                  )
                else
                  Column(
                    children: [
                      ...provider.earnings.map((item) => _buildEarningCard(context, item,provider.partners)),
                      const SizedBox(height: 16),
                      // Pagination
                      if (provider.totalPages > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: provider.currentPage > 1
                                  ? () => provider.goToPage(provider.currentPage - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            ...List.generate(
                              provider.totalPages,
                                  (index) => GestureDetector(
                                onTap: () => provider.goToPage(index + 1),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: provider.currentPage == index + 1
                                        ? const Color(0xff6C3EF4)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: provider.currentPage == index + 1
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: provider.currentPage == index + 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: provider.currentPage < provider.totalPages
                                  ? () => provider.goToPage(provider.currentPage + 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      // Rows per page selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Rows per page:'),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: provider.limit,
                            items: const [
                              DropdownMenuItem(value: 10, child: Text('10')),
                              DropdownMenuItem(value: 25, child: Text('25')),
                              DropdownMenuItem(value: 50, child: Text('50')),
                            ],
                            onChanged: (val) {
                              if (val != null) provider.changeLimit(val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Helper Widgets ----

  Widget infoCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              Icon(icon, color: color),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget dropdownWidget({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xffF7F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEarningCard(BuildContext context, EarningItem item,List<PartnerItem> partners) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "#${item.id}",
                style: const TextStyle(
                  fontSize: 26,
                  color: Color(0xff6C3EF4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.srMasterProposerName.isNotEmpty
                          ? item.srMasterProposerName
                          : 'No Proposer',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      item.srMasterPolicyNo.isNotEmpty
                          ? item.srMasterPolicyNo
                          : 'No Policy',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item.status == 1
                      ? Colors.green.withOpacity(.15)
                      : Colors.red.withOpacity(.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  item.statusLabel.toUpperCase(),
                  style: TextStyle(
                    color: item.status == 1 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountColumn('Gross Amount', item.payInAmount, Colors.deepPurple),
              _amountColumn('Cashback', item.cashbackCustomerAmount, Colors.orange),
              _amountColumn('Net Earning', item.earningAmount, Colors.green),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.createdAt),
              ),
              IconButton (
                onPressed: () {
                  // View details
                  showDialog(
                    context: context,
                    builder: (_) => EarningViewPopup(
                      earning: item,
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, color: Colors.blue),
              ),
              IconButton(
                onPressed: () async {

                    final provider = context.read<EarningsProvider>();
                    if (provider.policies.isEmpty) {
                      await provider.fetchPolicies(id: item.srMastersId); // fetch all
                    }

                  showDialog(
                    context: context,
                    builder: (_) => EarningEditPopup(
                      earning: item,
                      partners: partners,
                      policies: context.read<EarningsProvider>().policies,
                      onUpdated: () {
                        // Refresh the list after update
                        context.read<EarningsProvider>().init();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountColumn(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        Text(
          "₹ ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}