// lib/widgets/transaction/recipient_search_widget.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import '../../core/constants.dart';
import '../../widgets/input_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/account.dart';
import '../../confirmation/auth_service.dart';
import '../../services/qr_service.dart';

class RecipientSearchWidget extends StatefulWidget {
  final Account? selectedRecipient;
  final Function(Account) onRecipientSelected;
  final VoidCallback onClearRecipient;
  final bool isDarkMode;

  const RecipientSearchWidget({
    super.key,
    this.selectedRecipient,
    required this.onRecipientSelected,
    required this.onClearRecipient,
    required this.isDarkMode,
  });

  @override
  State<RecipientSearchWidget> createState() => _RecipientSearchWidgetState();
}

class _RecipientSearchWidgetState extends State<RecipientSearchWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Search user by phone number
  Future<void> _searchByPhone() async {
    if (_phoneController.text.trim().isEmpty) {
      _setSearchError('Please enter a phone number');
      return;
    }

    _setSearching(true);
    _clearSearchError();

    try {
      final accounts = await _authService.searchAccountsByPhone(
        _phoneController.text.trim(),
      );

      if (accounts.isNotEmpty) {
        widget.onRecipientSelected(accounts.first);
        _clearControllers();
      } else {
        _setSearchError('No user found with this phone number');
      }
    } catch (e) {
      _setSearchError('Search failed: ${e.toString()}');
    } finally {
      _setSearching(false);
    }
  }

  // Search user by email
  Future<void> _searchByEmail() async {
    if (_emailController.text.trim().isEmpty) {
      _setSearchError('Please enter an email address');
      return;
    }

    _setSearching(true);
    _clearSearchError();

    try {
      final userType = await _authService.detectUserType(
        _emailController.text.trim(),
      );

      if (userType == UserType.user) {
        final account = await _authService.getAccountByEmail(
          _emailController.text.trim(),
        );
        if (account != null) {
          widget.onRecipientSelected(account);
          _clearControllers();
        } else {
          _setSearchError('User not found');
        }
      } else {
        _setSearchError('No user found with this email address');
      }
    } catch (e) {
      _setSearchError('Search failed: ${e.toString()}');
    } finally {
      _setSearching(false);
    }
  }

  // Upload and process QR image
  Future<void> _uploadQRImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      _setSearching(true);
      _clearSearchError();

      // Process QR code from selected image
      await _processQRFromImageFile(image);
    } catch (e) {
      _setSearchError('Image processing failed: ${e.toString()}');
    } finally {
      _setSearching(false);
    }
  }

  // Process QR code from image file using qr_code_tools
  Future<void> _processQRFromImageFile(XFile imageFile) async {
    try {
      // Use qr_code_tools to decode QR from image file
      final String? qrData = await QrCodeToolsPlugin.decodeFrom(imageFile.path);

      if (qrData != null && qrData.isNotEmpty) {
        // Process the QR data using your existing service
        await _processScannedQRData(qrData);
      } else {
        _setSearchError('No QR code found in the selected image');
      }
    } catch (e) {
      _setSearchError('Failed to process QR image: ${e.toString()}');
    }
  }

  // Process scanned QR data (shared by camera scan and image upload)
  Future<void> _processScannedQRData(String qrData) async {
    try {
      // Parse QR data using your existing QR service
      final parsedData = QRService.parseQRData(qrData);

      if (parsedData != null && QRService.isValidQRData(parsedData)) {
        // Extract account ID from QR data
        final accountId = parsedData['account_id'] as int;

        // Get account details from database
        final account = await _authService.getAccountById(accountId);

        if (account != null) {
          // Successfully found recipient
          widget.onRecipientSelected(account);
          _clearControllers();
        } else {
          _setSearchError('Account not found in system');
        }
      } else {
        _setSearchError('Invalid or expired QR code');
      }
    } catch (e) {
      _setSearchError('Failed to process QR data: ${e.toString()}');
    }
  }

  // Camera QR scanning
  Future<void> _scanQRWithCamera() async {
    try {
      final result =
          await Navigator.pushNamed(
                context,
                '/qr-scanner',
                arguments: {'transaction_type': 'transfer'},
              )
              as Map<String, dynamic>?;

      if (result != null && result.containsKey('account_id')) {
        final accountId = result['account_id'] as int;
        final account = await _authService.getAccountById(accountId);

        if (account != null) {
          widget.onRecipientSelected(account);
          _clearControllers();
        } else {
          _setSearchError('Account not found');
        }
      }
    } catch (e) {
      _setSearchError('QR scan failed: ${e.toString()}');
    }
  }

  // Helper methods
  void _setSearching(bool searching) {
    setState(() {
      _isSearching = searching;
    });
  }

  void _setSearchError(String error) {
    setState(() {
      _searchError = error;
    });
  }

  void _clearSearchError() {
    setState(() {
      _searchError = null;
    });
  }

  void _clearControllers() {
    _phoneController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedRecipient != null) {
      return _buildSelectedRecipient();
    }

    return _buildSearchInterface();
  }

  // Build selected recipient display
  Widget _buildSelectedRecipient() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            widget.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: Text(
              widget.selectedRecipient!.username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Recipient Selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.selectedRecipient!.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        widget.isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                ),
                if (widget.selectedRecipient!.email != null &&
                    widget.selectedRecipient!.email!.isNotEmpty)
                  Text(
                    widget.selectedRecipient!.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClearRecipient,
            icon: const Icon(Icons.close),
            tooltip: 'Change Recipient',
          ),
        ],
      ),
    );
  }

  // Build search interface
  Widget _buildSearchInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Recipient',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),

        // Search method tabs
        Container(
          decoration: BoxDecoration(
            color:
                widget.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor:
                widget.isDarkMode ? Colors.white70 : Colors.black54,
            tabs: const [
              Tab(text: 'Phone', icon: Icon(Icons.phone, size: 20)),
              Tab(text: 'Email', icon: Icon(Icons.email, size: 20)),
              Tab(text: 'Scan QR', icon: Icon(Icons.qr_code_scanner, size: 20)),
              Tab(text: 'Upload QR', icon: Icon(Icons.upload, size: 20)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab content
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPhoneTab(),
              _buildEmailTab(),
              _buildScanQRTab(),
              _buildUploadQRTab(),
            ],
          ),
        ),

        // Error message
        if (_searchError != null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _searchError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Phone search tab
  Widget _buildPhoneTab() {
    return Column(
      children: [
        InputField(
          controller: _phoneController,
          label: 'Phone Number',
          hintText: 'Enter recipient\'s phone number',
          keyboardType: TextInputType.phone,
          isDarkMode: widget.isDarkMode,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: _isSearching ? 'Searching...' : 'Search',
          onPressed: _isSearching ? null : _searchByPhone,
          isPrimary: true,
          isLoading: _isSearching,
          icon: Icons.search,
        ),
      ],
    );
  }

  // Email search tab
  Widget _buildEmailTab() {
    return Column(
      children: [
        InputField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter recipient\'s email',
          keyboardType: TextInputType.emailAddress,
          isDarkMode: widget.isDarkMode,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: _isSearching ? 'Searching...' : 'Search',
          onPressed: _isSearching ? null : _searchByEmail,
          isPrimary: true,
          isLoading: _isSearching,
          icon: Icons.search,
        ),
      ],
    );
  }

  // QR camera scan tab
  Widget _buildScanQRTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_scanner,
          size: 48,
          color: widget.isDarkMode ? Colors.white54 : Colors.black54,
        ),
        const SizedBox(height: 16),
        Text(
          'Scan recipient\'s QR code with camera',
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Open Camera',
          onPressed: _scanQRWithCamera,
          isPrimary: true,
          icon: Icons.qr_code_scanner,
        ),
      ],
    );
  }

  // QR image upload tab
  Widget _buildUploadQRTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.upload,
          size: 48,
          color: widget.isDarkMode ? Colors.white54 : Colors.black54,
        ),
        const SizedBox(height: 16),
        Text(
          'Upload QR code image from gallery',
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: _isSearching ? 'Processing...' : 'Choose Image',
          onPressed: _isSearching ? null : _uploadQRImage,
          isPrimary: true,
          icon: Icons.upload,
          isLoading: _isSearching,
        ),
        const SizedBox(height: 8),
        Text(
          'Select a QR code image from your photos',
          style: TextStyle(
            fontSize: 12,
            color: widget.isDarkMode ? Colors.white60 : Colors.black45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
