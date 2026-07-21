import 'package:flutter/material.dart';

class LeadAddProvider extends ChangeNotifier {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final pincodeController = TextEditingController();
  final policyController = TextEditingController();
  final VehicleNoController = TextEditingController();
  final referenceDetailsController = TextEditingController();

  String leadType = "Insurance";
  String leadStatus = "Follow-up";
  String reference = "None";

  void setLeadType(String value) {
    leadType = value;
    notifyListeners();
  }

  void setLeadStatus(String value) {
    leadStatus = value;
    notifyListeners();
  }

  void setReference(String value) {
    reference = value;
    notifyListeners();
  }

  Future<void> createLead() async {
    print(nameController.text);
    print(mobileController.text);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    pincodeController.dispose();
    policyController.dispose();
    referenceDetailsController.dispose();
    super.dispose();
  }
}