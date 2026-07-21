import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:pdf_read/screen/lead/model/lead_model.dart';
import '../../../data/modifiednetwork/ApiConfig.dart';
import '../../../data/modifiednetwork/ApiService.dart';
import '../../../data/network/ConnectivityService.dart';
import '../../../data/sharedpreferences/PreferenceManager.dart';
import '../model/lead_detail_model.dart';


class LeadProvider extends ChangeNotifier {
  // Services
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  // Data
  List<Lead> _allLeads = [];
  List<Lead> _filteredLeads = [];

  // Master data
  List<Map<String, dynamic>> _leadStatuses = [];
  List<Map<String, dynamic>> _lobs = [];
  List<Map<String, dynamic>> _leadReferences = [];
  List<Map<String, dynamic>> _documentTypes = [];



  // Getters
  List<Map<String, dynamic>> get leadStatuses => _leadStatuses;
  List<Map<String, dynamic>> get lobs => _lobs;
  List<Map<String, dynamic>> get leadReferences => _leadReferences;
  List<Map<String, dynamic>> get documentTypes => _documentTypes;

  // Filters & sort
  String _searchQuery = '';
  String _statusFilter = 'All Status';
  String _typeFilter = 'All Types';
  String _sortOrder = 'Latest';

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // UI states
  bool _isLoading = false;
  String _error = '';

  // Stats
  int _totalLeads = 0;
  int _totalFollowup = 0;
  int _totalLost = 0;
  int _totalPending = 0;

  // --- Getters ---
  List<Lead> get leads => _filteredLeads;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get error => _error;

  int get totalLeads => _totalLeads;
  int get totalFollowup => _totalFollowup;
  int get totalLost => _totalLost;
  int get pending => _totalPending;

  List<String> get statusOptions =>
      ['All Status', ..._leadStatuses.map((e) => e['name'] as String)];
  List<String> get typeOptions =>
      ['All Types', ..._lobs.map((e) => e['name'] as String)];

  String get currentStatusFilter => _statusFilter;
  String get currentTypeFilter => _typeFilter;
  String get currentSortOrder => _sortOrder;

  // --- Constants for Complete status ---
  static const int docTypeIdForPolicy = 50;
  static const int followupTypeForComplete = 1;

  // --- Constructor ---
  LeadProvider() {
    init();
  }

  // ---------- Initialization ----------
  Future<void> init() async {
    await fetchMasterData();
    _currentPage = 1;
    _allLeads.clear();
    await fetchLeads(page: _currentPage);
  }

  // ---------- Fetch Master Data (includes document types) ----------
  Future<void> fetchMasterData() async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      // 1. LOBs
      final lobBody = {'type': 'lob', 'source': 'app-android'};
      final lobResponse = await _api.postWithProgress(
        ApiConfig.mastersListUrl,
        data: lobBody,
        headers: headers,
      );
      if (lobResponse.statusCode != null &&
          lobResponse.statusCode! >= 200 &&
          lobResponse.statusCode! < 300) {
        final json = lobResponse.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _lobs = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
          }).toList();
        } else {
          _error = json['message'] ?? 'Failed to load LOBs';
        }
      } else {
        _error = 'Server error: ${lobResponse.statusCode}';
      }

      // 2. Lead Statuses
      final statusBody = {'type': 'leads_status', 'source': 'app-android'};
      final statusResponse = await _api.postWithProgress(
        ApiConfig.mastersListUrl,
        data: statusBody,
        headers: headers,
      );
      if (statusResponse.statusCode != null &&
          statusResponse.statusCode! >= 200 &&
          statusResponse.statusCode! < 300) {
        final json = statusResponse.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _leadStatuses = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
          }).toList();
        } else {
          _error = json['message'] ?? 'Failed to load lead statuses';
        }
      } else {
        _error = 'Server error: ${statusResponse.statusCode}';
      }

      // 3. Lead References
      final refBody = {'type': 'lead_referance', 'source': 'app-android'};
      final refResponse = await _api.postWithProgress(
        ApiConfig.mastersListUrl,
        data: refBody,
        headers: headers,
      );
      if (refResponse.statusCode != null &&
          refResponse.statusCode! >= 200 &&
          refResponse.statusCode! < 300) {
        final json = refResponse.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _leadReferences = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
          }).toList();
        } else {
          if (_error.isEmpty) {
            _error = json['message'] ?? 'Failed to load references';
          }
        }
      } else {
        if (_error.isEmpty) {
          _error = 'Server error: ${refResponse.statusCode}';
        }
      }

      // 4. Document Types (NEW)
      final docBody = {'type': 'leads_documents', 'source': 'app-android'};
      final docResponse = await _api.postWithProgress(
        ApiConfig.mastersListUrl,
        data: docBody,
        headers: headers,
      );
      if (docResponse.statusCode != null &&
          docResponse.statusCode! >= 200 &&
          docResponse.statusCode! < 300) {
        final json = docResponse.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          _documentTypes = data.map((item) => {
            'id': item['id'].toString(),
            'name': item['name'] ?? '',
          }).toList();
        } else {
          if (_error.isEmpty) {
            _error = json['message'] ?? 'Failed to load document types';
          }
        }
      } else {
        if (_error.isEmpty) {
          _error = 'Server error: ${docResponse.statusCode}';
        }
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------- Update Lead Status (unchanged) ----------
  Future<bool> updateLeadStatus({
    required String leadId,
    required int statusId,
    required DateTime? followupDateTime,
    required String? remarks,
    File? policyFile,
  }) async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return false;
    }

    try {
      final token = await _getToken();
      if (token == null) {
        _error = 'Authentication token not found.';
        notifyListeners();
        return false;
      }

      final statusName = _leadStatuses.firstWhere(
            (s) => int.parse(s['id'].toString()) == statusId,
        orElse: () => {'name': ''},
      )['name']?.toString().toLowerCase() ?? '';

      // ---------- 1. COMPLETE (multipart with file) ----------
      if (statusName == 'complete') {
        if (policyFile == null) {
          _error = 'Please attach a PDF file for Complete status.';
          notifyListeners();
          return false;
        }

        final uri = Uri.parse(ApiConfig.baseUrl + '' + ApiConfig.followupCreateUrl);
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token';

        request.fields['id'] = leadId;
        request.fields['lead_status_id'] = statusId.toString();
        request.fields['doc_type_id'] = docTypeIdForPolicy.toString();
        request.fields['source'] = 'app-android';
        request.fields['remarks'] = remarks ?? '';

        final now = DateTime.now();
        final dt = followupDateTime ?? now;
        request.fields['followup_date'] =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        request.fields['followup_time'] =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
        request.fields['followup_type'] = followupTypeForComplete.toString();

        final loginData = await PreferenceManager.getLoginData();
        request.fields['user_id'] = loginData?.user.id?.toString() ?? '0';

        final fileBytes = await policyFile.readAsBytes();
        final fileName = path.basename(policyFile.path);
        final multipartFile = http.MultipartFile.fromBytes(
          'policy_file',
          fileBytes,
          filename: fileName,
        );
        request.files.add(multipartFile);

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final json = jsonDecode(response.body);
          if (json is Map<String, dynamic> && json['status'] == true) {
            await refreshLeads();
            return true;
          } else {
            _error = json['message'] ?? 'Failed to update to Complete';
            notifyListeners();
            return false;
          }
        } else {
          _error = 'Server error: ${response.statusCode}';
          notifyListeners();
          return false;
        }
      }

      // ---------- 2. FOLLOW-UP & LOST (JSON) ----------
      final Map<String, dynamic> body = {
        'source': 'app-android',
        'id': int.parse(leadId),
        'lead_status_id': statusId.toString(),
        'remarks': remarks ?? '',
      };

      if (statusName == 'followup' && followupDateTime != null) {
        body['date_time'] = followupDateTime.toLocal().toString().substring(0, 19);
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _api.postWithProgress(
        ApiConfig.followupCreateUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          await refreshLeads();
          return true;
        } else {
          _error = json['message'] ?? 'Failed to update status';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  // ---------- Fetch Lead Detail ----------
  Future<LeadDetail?> fetchLeadDetail(int leadId) async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return null;
    }

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'id': leadId,
      };

      final response = await _api.postWithProgress(
        ApiConfig.followupDetailsUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          return LeadDetail.fromJson(json['data']);
        } else {
          _error = json['message'] ?? 'Failed to fetch lead detail';
          notifyListeners();
          return null;
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return null;
    }
  }

  // ---------- Fetch Leads ----------
  Future<void> fetchLeads({int? page}) async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return;
    }

    if (page != null && page > 1) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
    }
    _error = '';
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'page': page ?? _currentPage,
        'limit': 20,
        'source': 'app-android',
      };

      final response = await _api.postWithProgress(
        ApiConfig.leadListUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          final List<dynamic> data = json['data'] ?? [];

          print("LINE447");
          print(json['data']);

          final newLeads = data.map((item) {
            return Lead(
              id: int.tryParse(item['id']?.toString() ?? '0') ?? 0,
              userId: int.tryParse(item['user_id']?.toString() ?? '0') ?? 0,
              parentId: int.tryParse(item['parent_id']?.toString() ?? '0') ?? 0,
              parentType: item['parent_type']?.toString(),
              srMasterId: int.tryParse(item['sr_master_id']?.toString() ?? '0') ?? 0,
              leadStatusId: int.tryParse(item['lead_status_id']?.toString() ?? '0') ?? 0,
              leadStatus: int.tryParse(item['lead_status']?.toString() ?? '0') ?? 0,
              status: item['lead_status_name'] ?? 'Pending',
              statusAlias: item['lead_status_alias']?.toString(),
              leadReferenceMasterId: int.tryParse(item['lead_reference_master_id']?.toString() ?? '0') ?? 0,
              leadReferenceName: item['lead_reference_name']?.toString(),
              name: item['customer_name'] ?? 'Unknown',
              mobile: item['mobile'] ?? '',
              email: item['email'] ?? '',
              pincode: item['pincode'] ?? '',
              lobId: int.tryParse(item['lob_id']?.toString() ?? '0') ?? 0,
              type: item['lob_name'] ?? 'Other',
              lobAlias: item['lob_alias']?.toString(),
              leadDetails: item['lead_details']?.toString(),
              vehicleNo: item['vehicle_no']?.toString(),
              policyNo: item['policy_no']?.toString(),
              address: item['address']?.toString(),
              notes: item['notes']?.toString(),
             // remarks: item['remarks']?.toString(),
              reference: item['reference']?.toString(),
              source: item['source'] ?? '',
              createdAt: item['created_at'] ?? '',
              updatedAt: item['updated_at'] ?? '',
              documents: item['documents'] ?? [],
            );
          }).toList();

          final stats = json['stats'] ?? {};
          _totalLeads = stats['total'] ?? 0;
          _totalFollowup = stats['followup'] ?? 0;
          _totalLost = stats['lost'] ?? 0;
          _totalPending = stats['pending'] ?? 0;

          final pagination = json['pagination'] ?? {};
          _totalPages = pagination['total_pages'] ?? 1;
          _currentPage = pagination['page'] ?? 1;
          _hasMore = _currentPage < _totalPages;

          if (page == null || page == 1) {
            _allLeads = newLeads;
          } else {
            _allLeads.addAll(newLeads);
          }
        } else {
          _error = json['message'] ?? 'Failed to load leads';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    _isLoadingMore = false;
    _applyFiltersAndSort();
  }

  // ---------- Delete Lead ----------
  Future<bool> deleteLead(int leadId) async {
    if (!await _connectivity.hasInternet()) {
      _error = 'No internet connection.';
      notifyListeners();
      return false;
    }

    try {
      final token = await _getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final body = {
        'source': 'app-android',
        'id': leadId,
      };

      final response = await _api.postWithProgress(
        ApiConfig.leadDeleteUrl,
        data: body,
        headers: headers,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final json = response.data;
        if (json is Map<String, dynamic> && json['status'] == true) {
          _allLeads.removeWhere((lead) => lead.id == leadId);
          _applyFiltersAndSort();
          _totalLeads = _totalLeads - 1;
          return true;
        } else {
          _error = json['message'] ?? 'Failed to delete lead';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  // ---------- Load More ----------
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    final nextPage = _currentPage + 1;
    if (nextPage <= _totalPages) {
      await fetchLeads(page: nextPage);
    }
  }

  // ---------- Refresh ----------
  Future<void> refreshLeads() async {
    _currentPage = 1;
    _allLeads.clear();
    await fetchLeads(page: 1);
  }

  // ---------- Filter & Sort ----------
  void updateSearch(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void updateStatusFilter(String status) {
    _statusFilter = status;
    _applyFiltersAndSort();
  }

  void updateTypeFilter(String type) {
    _typeFilter = type;
    _applyFiltersAndSort();
  }

  void updateSortOrder(String order) {
    _sortOrder = order;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    var result = _allLeads.where((lead) {
      final searchLower = _searchQuery.toLowerCase();
      final nameMatch = lead.name.toLowerCase().contains(searchLower);
      final mobileMatch = lead.mobile.contains(_searchQuery);
      final emailMatch = lead.email.toLowerCase().contains(searchLower);
      final searchMatch = nameMatch || mobileMatch || emailMatch;

      final statusMatch = _statusFilter == 'All Status' ||
          lead.status.toLowerCase() == _statusFilter.toLowerCase();

      final typeMatch = _typeFilter == 'All Types' ||
          lead.type.toLowerCase() == _typeFilter.toLowerCase();

      return searchMatch && statusMatch && typeMatch;
    }).toList();

    if (_sortOrder == 'Latest') {
      result.sort((a, b) => b.id.compareTo(a.id));
    } else {
      result.sort((a, b) => a.id.compareTo(b.id));
    }

    _filteredLeads = result;
    notifyListeners();
  }

  // ---------- Helper to get token ----------
  Future<String?> _getToken() async {
    final loginData = await PreferenceManager.getLoginData();
    return loginData?.token;
  }
}