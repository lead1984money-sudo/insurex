import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_read/screen/editProfile/provider/EditProfileProvider.dart';
import 'package:provider/provider.dart';
import '../../app_utils/app_images.dart';
import '../../data/sharedpreferences/PreferenceManager.dart';
import '../../screen/login/model/VerifyOtpModel.dart';
import '../plan/SubscriptionScreen.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  // ─── Controllers ──────────────────────────────────────────────
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _accountTypeController = TextEditingController(text: 'Savings');

  String _phoneNumber = '';
  late TabController _tabController;
  File? _imageFile;

  VerifyOtpModel? _loginData;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _accountHolderNameController.dispose();
    _accountTypeController.dispose();
    super.dispose();
  }

  // ─── Load login data (for plan and pre‑fill) ──────────────────
  Future<void> _loadUserData() async {
    final data = await PreferenceManager.getLoginData();
    setState(() {
      _loginData = data;
      _isLoading = false;
      // Pre‑fill fields with user data from the login response
      final user = data?.user;
      if (user != null) {
        _firstNameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _phoneNumber = user.mobile ?? '';
        // You might also have address/bank data stored elsewhere – you can set them here.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B1A33),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0B1A33)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(AppImages.background, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Container (
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildTabSection(),
                    const SizedBox(height: 16),
                    _buildPlanSection(),
                    const SizedBox(height: 16),
                    _buildUpdateButton(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab Section ──────────────────────────────────────────────
  Widget _buildTabSection() {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF4F9CF7),
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF0B1A33),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Address'),
                Tab(text: 'Bank'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalTab(),
                _buildAddressTab(),
                _buildBankTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tabs ──────────────────────────────────────────────────────
  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Full Name', _firstNameController),
          const SizedBox(height: 14),
          _buildTextField('Email', _emailController,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _buildReadOnlyField(
            label: 'Phone Number',
            value: _phoneNumber,
            icon: Icons.lock_outline,
            hint: 'Phone number cannot be modified.',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Address', _addressController),
          const SizedBox(height: 14),
          _buildTextField('City', _cityController),
          const SizedBox(height: 14),
          _buildTextField('State', _stateController),
          const SizedBox(height: 14),
          _buildTextField('Pincode', _pincodeController,
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildBankTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Bank Name', _bankNameController),
          const SizedBox(height: 14),
          _buildTextField('Account Holder Name', _accountHolderNameController),
          const SizedBox(height: 14),
          _buildTextField('Account Number', _accountNumberController,
              keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          _buildTextField('IFSC Code', _ifscController),
          const SizedBox(height: 14),
          _buildDropdownField(
            label: 'Account Type',
            value: _accountTypeController.text,
            items: const ['Savings', 'Current', 'Salary', 'NRI'],
            onChanged: (val) {
              if (val != null) {
                _accountTypeController.text = val;
              }
            },
          ),
        ],
      ),
    );
  }

  // ─── Profile Header ────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
              child: _imageFile == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F9CF7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _firstNameController.text.trim(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1A33),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    _phoneNumber,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Plan Section ──────────────────────────────────────────────
  Widget _buildPlanSection() {
    final plan = _loginData?.user.planDetails;
    final planName = plan?.planName ?? 'No Plan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Plan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    planName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B1A33),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Valid Till: Life Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F9CF7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  // ─── Update Button ─────────────────────────────────────────────
  Widget _buildUpdateButton() {
    return Consumer<EditProfileProvider>(
      builder: (context, provider, child) {
        bool isLoading = false;
        // Determine which loading flag to show based on tab index
        switch (_tabController.index) {
          case 0:
            isLoading = provider.isUpdatingPersonal || provider.isUploadingPicture;
            break;
          case 1:
            isLoading = provider.isUpdatingAddress;
            break;
          case 2:
            isLoading = provider.isUpdatingBank;
            break;
        }

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _handleUpdate(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F9CF7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text(
              'Update Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Handle update based on active tab ────────────────────────
  Future<void> _handleUpdate(EditProfileProvider provider) async {
    bool success = false;

    switch (_tabController.index) {
      case 0: // Personal
        success = await provider.updatePersonalDetails(
          name: _firstNameController.text.trim(),
          email: _emailController.text.trim(),
        );
        // If image is selected, upload it after personal update
        if (success && _imageFile != null) {
          final imageSuccess = await provider.uploadProfilePicture(_imageFile!);
          if (!imageSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage)),
            );
            return;
          }
        }
        break;

      case 1: // Address
        success = await provider.updateAddress(
          address: _addressController.text.trim(),
          pincode: _pincodeController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
        );
        break;

      case 2: // Bank
        success = await provider.updateBank(
          bankName: _bankNameController.text.trim(),
          acHolderName: _accountHolderNameController.text.trim(),
          ifsc: _ifscController.text.trim(),
          acNumber: _accountNumberController.text.trim(),
          acType: _accountTypeController.text.trim(),
        );
        break;
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  // ─── Helper Widgets ────────────────────────────────────────────
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4F9CF7),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(icon, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hint,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ─── Image Picker ───────────────────────────────────────────────
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (croppedFile == null) return;

      setState(() {
        _imageFile = File(croppedFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}