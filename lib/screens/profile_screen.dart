import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  bool _isNameEditable = false;
  bool _isEmailEditable = false;

  UserProvider? _userProvider;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _userProvider?.removeListener(_onUserProviderChanged);
    super.dispose();
  }

  void _onUpdateProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider =
        _userProvider ?? Provider.of<UserProvider>(context, listen: false);
    provider
        .updateUserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        )
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profile updated')));
          setState(() {
            _isNameEditable = false;
            _isEmailEditable = false;
          });
        })
        .catchError((e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<UserProvider>(context);
    if (_userProvider != provider) {
      _userProvider?.removeListener(_onUserProviderChanged);
      _userProvider = provider;
      _userProvider?.addListener(_onUserProviderChanged);
      _updateControllersFromUser();
    }
  }

  void _onUserProviderChanged() {
    if (!mounted) return;
    _updateControllersFromUser();
  }

  void _updateControllersFromUser() {
    final u = _userProvider?.user;
    _nameController.text = u?.name ?? '';
    _mobileController.text = (u?.phoneNumber ?? '').replaceFirst('+91', '');
    _emailController.text = u?.email ?? '';
    setState(() {});
  }

  OutlineInputBorder _inputBorder(Color color, double radius) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: 1.6),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black87)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep content readable on large screens by constraining width
            final maxContentWidth = constraints.maxWidth > 700
                ? 700.0
                : constraints.maxWidth;
            final horizontalPadding = (constraints.maxWidth > 500)
                ? 28.0
                : 16.0;
            final borderRadius = (constraints.maxWidth > 500) ? 18.0 : 12.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Avatar
                        Center(
                          child: CircleAvatar(
                            radius: constraints.maxWidth > 400 ? 56 : 44,
                            backgroundColor: const Color.fromARGB(
                              255,
                              233,
                              73,
                              73,
                            ),
                            child: Text(
                              (_nameController.text.isNotEmpty)
                                  ? _nameController.text[0].toUpperCase()
                                  : 'S',
                              style: TextStyle(
                                fontSize: constraints.maxWidth > 400 ? 36 : 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Name label
                        const Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Name field with CHANGE suffix
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          readOnly: !_isNameEditable,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter a name'
                              : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: _inputBorder(
                              Colors.black87,
                              borderRadius,
                            ),
                            focusedBorder: _inputBorder(
                              theme.primaryColor,
                              borderRadius,
                            ),
                            hintText: 'Your name',
                            hintStyle: TextStyle(color: Colors.black54),
                            suffix: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isNameEditable = true;
                                });
                                Future.delayed(Duration.zero, () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_nameFocus);
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(64, 24),
                              ),
                              child: Text(
                                'CHANGE',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Mobile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            enabledBorder: _inputBorder(
                              Colors.black87,
                              borderRadius,
                            ),
                            focusedBorder: _inputBorder(
                              theme.primaryColor,
                              borderRadius,
                            ),
                            hintText: 'Mobile number',
                            prefixText: '+91 ',
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          readOnly: !_isEmailEditable,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter email';
                            if (!RegExp(
                              r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}",
                            ).hasMatch(v.trim()))
                              return 'Enter a valid email';
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            enabledBorder: _inputBorder(
                              Colors.black87,
                              borderRadius,
                            ),
                            focusedBorder: _inputBorder(
                              theme.primaryColor,
                              borderRadius,
                            ),
                            hintText: 'Email address',
                            suffix: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEmailEditable = true;
                                });
                                Future.delayed(Duration.zero, () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_emailFocus);
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(64, 4),
                              ),
                              child: Text(
                                'CHANGE',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),

                        const SizedBox(height: 30),

                        // Update button
                        Center(
                          child: ConstrainedBox(
                            // Only constrain the maximum width; don't force minWidth to Infinity
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _onUpdateProfile,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                  elevation: 4,
                                ),
                                child: Consumer<UserProvider>(
                                  builder: (context, provider, child) =>
                                      provider.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Update Profile',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
