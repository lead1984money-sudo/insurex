import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf_read/screen/businessDetail/provider/MyBusinessProvider.dart';
import 'package:provider/provider.dart';
import '../../app_utils/ColorsPicks.dart';
import '../../app_utils/app_images.dart';
import '../../data/sharedpreferences/PreferenceManager.dart';

class MyBusinessDetails extends StatefulWidget {
  final int srMasterId;
  const MyBusinessDetails({super.key, required this.srMasterId});

  @override
  State<MyBusinessDetails> createState() => _MyBusinessDetailsState();
}

class _MyBusinessDetailsState extends State<MyBusinessDetails> {
  late MyBusinessProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MyBusinessProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        await _provider.fetchBusinessDetails(
          token: token,
          srMasterId: widget.srMasterId,
        );
      }
    });
  }

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = Colors.white.withOpacity(0.3);
    final headingColor = black;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MyBusinessProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(AppImages.background, fit: BoxFit.cover),
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.errorMessage),
                    ElevatedButton(
                      onPressed: () {
                        provider.reset();
                        _getToken().then((token) {
                          if (token != null && token.isNotEmpty) {
                            provider.fetchBusinessDetails(
                              token: token,
                              srMasterId: widget.srMasterId,
                            );
                          }
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final log = provider.logData;
          final response = provider.responseJson;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Policy Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              centerTitle: true,
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.background),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(color: overlayColor),
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Header Card ──────────────────────────────
                          if (!_shouldSkip(provider.lobName) ||
                              !_shouldSkip(provider.proposerName) ||
                              !_shouldSkip(provider.policyNo) ||
                              !_shouldSkip(provider.insurerName) ||
                              !_shouldSkip(provider.vehicleNo) ||
                              !_shouldSkip(provider.startDate) ||
                              !_shouldSkip(provider.endDate))
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          provider.lobName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: headingColor,
                                          ),
                                        ),
                                      ),
                                      _buildStatusChip(provider.isFailed, provider.reasonFail),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Only show non‑empty fields
                                  if (!_shouldSkip(provider.proposerName))
                                    _infoRow('Proposer', provider.proposerName),
                                  if (!_shouldSkip(provider.policyNo))
                                    _infoRow('Policy No', provider.policyNo),
                                  if (!_shouldSkip(provider.insurerName))
                                    _infoRow('Insurer', provider.insurerName),
                                  if (!_shouldSkip(provider.vehicleNo))
                                    _infoRow('Vehicle No', provider.vehicleNo!),
                                  if (!_shouldSkip(provider.startDate))
                                    _infoRow('Start Date', provider.startDate),
                                  if (!_shouldSkip(provider.endDate))
                                    _infoRow('End Date', provider.endDate),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),

                          // ─── Log Section ──────────────────────────────


                          // ─── Extracted Data – DYNAMIC ────────────────
                          if (response != null && response.isNotEmpty) ...[
                            Text(
                              'Extracted Policy Data',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: headingColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _glassCard(
                              child: _buildResponseJson(response),
                            ),
                          ],
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Helper: skip null, empty, or "N/A" ──────────────────────
  bool _shouldSkip(dynamic value) {
    if (value == null) return true;
    if (value is String) {
      return value.isEmpty ||
          value.trim().isEmpty ||
          value.trim().toUpperCase() == 'N/A' ||
          value.trim().toUpperCase() == 'NULL';
    }
    return false;
  }

  // ─── Recursive widget to render any JSON ──────────────────────
  Widget _buildResponseJson(Map<String, dynamic> json, {int depth = 0}) {
    List<Widget> children = [];

    json.forEach((key, value) {
      // Skip fields already shown elsewhere
      if (key == 'lob_name' || key == 'input_tokens' || key == 'output_tokens' ||
          key == 'input_usd_per_million_tokens' || key == 'output_usd_per_million_tokens' ||
          key == 'pricing_model_applied' || key == 'input_cost_usd' ||
          key == 'output_cost_usd' || key == 'total_cost_usd' ||
          key == 'total_cost_inr' || key == 'sync_time' || key == 'file_name') {
        return;
      }

      // Skip if value is null/empty/N/A
      if (_shouldSkip(value)) return;

      if (value is Map<String, dynamic>) {
        // Only show if nested map has any non‑empty values
        if (value.values.any((v) => !_shouldSkip(v))) {
          children.add(
            Padding(
              padding: EdgeInsets.only(left: depth * 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    key.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0B1A33),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildResponseJson(value, depth: depth + 1),
                ],
              ),
            ),
          );
        }
      } else if (value is List) {
        // Filter list items that are non‑empty
        final nonEmptyItems = value.where((item) => !_shouldSkip(item)).toList();
        if (nonEmptyItems.isNotEmpty) {
          children.add(
            Padding(
              padding: EdgeInsets.only(left: depth * 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    key.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0B1A33),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...nonEmptyItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    if (item is Map<String, dynamic>) {
                      // Filter empty fields inside map
                      final filteredMap = Map<String, dynamic>.from(item)
                        ..removeWhere((k, v) => _shouldSkip(v));
                      if (filteredMap.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            _buildResponseJson(filteredMap, depth: depth + 1),
                            const SizedBox(height: 6),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    } else {
                      return _infoRow('Item ${index + 1}', item.toString(), depth: depth + 1);
                    }
                  }).toList(),
                ],
              ),
            ),
          );
        }
      } else {
        // Primitive value – skip empty
        if (!_shouldSkip(value)) {
          children.add(_infoRow(key, value.toString(), depth: depth));
        }
      }
    });

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // ─── Glass Card ──────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ─── Info Row (with optional indent) ────────────────────────────
  Widget _infoRow(String label, String value, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0B1A33),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Chip ──────────────────────────────────────────────────
  Widget _buildStatusChip(bool isFailed, String? reason) {
    final color = isFailed ? Colors.red : Colors.green;
    final label = isFailed ? 'FAILED' : 'SUCCESS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}