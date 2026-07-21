import 'package:flutter/material.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/PolicyItem.dart';



class EarningAddProvider extends ChangeNotifier {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  // Form fields
  int? selectedPolicyId;
  int? selectedPartnerId;
  String status = "Active";
  bool isLoading = false;
  String? errorMessage;

  // Lists
  List<PolicyItem> _policies = [];
  List<PartnerItem> _partners = [];

  // Loading states for data fetch
  bool _isLoadingPolicies = false;
  bool _isLoadingPartners = false;

  bool get isLoadingPolicies => _isLoadingPolicies;
  bool get isLoadingPartners => _isLoadingPartners;

  // Getters for dropdown items (list of labels)
  List<String> get policyLabels => _policies.map((p) => p.label).toList();
  List<String> get partnerLabels => _partners.map((p) => p.name).toList();

  // Get selected display texts
  String? get selectedPolicyLabel {
    if (selectedPolicyId == null) return null;
    return _policies.firstWhere((p) => p.id == selectedPolicyId).label;
  }


  String? get selectedPartnerName {
    if (selectedPartnerId == null) return null;
    return _partners.firstWhere((p) => p.id == selectedPartnerId).name;
  }

  // Controllers
  final grossController = TextEditingController();
  final cashbackController = TextEditingController();
  final netEarningController = TextEditingController();
  final remarksController = TextEditingController();

  void setPolicyById(int? id) {
    if (id != selectedPolicyId) {
      selectedPolicyId = id;
      notifyListeners();
    }
  }

  // When dropdown selection changes, we get the label, we need to find id.
  void setPolicyByLabel(String? label) {
    if (label == null) {
      selectedPolicyId = null;
      notifyListeners();
      return;
    }
    final policy = _policies.firstWhere((p) => p.label == label);
    setPolicyById(policy.id);
  }

  void setPartnerById(int? id) {
    if (id != selectedPartnerId) {
      selectedPartnerId = id;
      notifyListeners();
    }
  }

  void setPartnerByName(String? name) {
    if (name == null) {
      selectedPartnerId = null;
      notifyListeners();
      return;
    }
    final partner = _partners.firstWhere((p) => p.name == name);
    setPartnerById(partner.id);
  }

  void setStatus(String value) {
    status = value;
    notifyListeners();
  }

  void calculateNetEarning() {
    double gross = double.tryParse(grossController.text) ?? 0;
    double cashback = double.tryParse(cashbackController.text) ?? 0;
    double net = gross - cashback;
    netEarningController.text = net.toStringAsFixed(2);
    notifyListeners();
  }

  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }

  // Fetch policies
  Future<void> fetchPolicies({String search = ''}) async {
    if (!await _connectivity.hasInternet()) {
      errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoadingPolicies = true;
    errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        errorMessage = 'Authentication token not found.';
        _isLoadingPolicies = false;
        notifyListeners();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = {
        'source': 'app-android',
        'search': search,
      };

      final response = await _api.postWithProgress(
        ApiConfig.searchPoliciesUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List data = json['data'] ?? [];

          print("LINE149"+data.length.toString());
          _policies = data.map((item) => PolicyItem.fromJson(item)).toList();

          print("LINE152"+_policies.toString());
          errorMessage = '';
        } else {
          errorMessage = json['message'] ?? 'Failed to load policies';
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    _isLoadingPolicies = false;
    notifyListeners();
  }

  // Fetch partners
  Future<void> fetchPartners({
    int page = 1,
    int limit = 100,
    String search = '',
    List<int> statusFilter = const [1],
    String dateFrom = '',
    String dateTo = '',
    List<int> userIds = const [],
  }) async {
    if (!await _connectivity.hasInternet()) {
      errorMessage = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoadingPartners = true;
    errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        errorMessage = 'Authentication token not found.';
        _isLoadingPartners = false;
        notifyListeners();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final body = {
        'source': 'app-android',
        'page': page,
        'limit': limit,
        'search': search,
        'status': statusFilter,
        'date_from': dateFrom,
        'date_to': dateTo,
        'user_ids': userIds,
      };

      final response = await _api.postWithProgress(
        ApiConfig.partnerListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List data = json['data'] ?? [];
          _partners = data.map((item) => PartnerItem.fromJson(item)).toList();
          errorMessage = '';
        } else {
          errorMessage = json['message'] ?? 'Failed to load partners';
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    _isLoadingPartners = false;
    notifyListeners();
  }

  Future<bool> submit() async {
    // Validate required fields
    if (selectedPolicyId == null) {
      errorMessage = 'Please select a policy.';
      notifyListeners();
      return false;
    }
    if (selectedPartnerId == null) {
      errorMessage = 'Please select a partner.';
      notifyListeners();
      return false;
    }
    double gross = double.tryParse(grossController.text) ?? 0;
    if (gross <= 0) {
      errorMessage = 'Gross amount must be greater than 0.';
      notifyListeners();
      return false;
    }

    if (!await _connectivity.hasInternet()) {
      errorMessage = 'No internet connection.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'sr_masters_id': selectedPolicyId!,
        'partner_id': selectedPartnerId!,
        'pay_in_amount': double.tryParse(grossController.text) ?? 0,
        'cashback_customer_amount': double.tryParse(cashbackController.text) ?? 0,
        'remarks': remarksController.text.trim(),
        'status': status == "Active" ? 1 : 0,
      };

      final response = await _api.postWithProgress(
        ApiConfig.earningCreateUrl,
        data: body,
        headers: headers,
      );

      isLoading = false;

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          errorMessage = '';
          notifyListeners();
          return true;
        } else {
          errorMessage = json['message'] ?? 'Failed to create earning';
          notifyListeners();
          return false;
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    grossController.dispose();
    cashbackController.dispose();
    netEarningController.dispose();
    remarksController.dispose();
    super.dispose();
  }
}