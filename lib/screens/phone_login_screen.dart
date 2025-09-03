import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:blinkit_clone/providers/user_provider.dart';
import 'package:blinkit_clone/screens/otp_screen.dart';
import 'package:blinkit_clone/screens/signup_screen.dart';
import 'package:blinkit_clone/screens/main_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  bool _hasError = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _setupFocusListener();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _setupFocusListener() {
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _verifyPhone() async {
    if (_phoneController.text.length != 10) {
      setState(() {
        _hasError = true;
      });
      HapticFeedback.lightImpact();
      _showErrorSnackBar('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _hasError = false;
    });

    HapticFeedback.selectionClick();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.verifyPhone(
        phoneNumber: _phoneController.text,
        onCodeSent: (String verificationId) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  OTPScreen(
                    verificationId: verificationId,
                    phoneNumber: _phoneController.text,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        onError: (String error) {
          _showErrorSnackBar(error);
        },
        onVerificationComplete: (userCredential) {
          _checkUserExists();
        },
      );
    } catch (e) {
      _showErrorSnackBar('Error sending OTP');
    }

    // Loading state is handled by the provider
  }

  void _checkUserExists() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userExists = await userProvider.checkUserExists(
      _phoneController.text,
    );

    if (userExists) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SignupScreen(phoneNumber: _phoneController.text),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFF8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: SingleChildScrollView(
              child: Container(
                height: size.height - keyboardHeight,
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00C853).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150,
                      left: -150,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF4CAF50).withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                const SizedBox(height: 40),

                                // Header section
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Logo/Icon with pulse animation
                                      AnimatedBuilder(
                                        animation: _pulseAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _pulseAnimation.value,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF00C853),
                                                    Color(0xFF4CAF50),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF00C853,
                                                    ).withOpacity(0.3),
                                                    blurRadius: 25,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.phone_android,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 32),

                                      const Text(
                                        'Welcome to Blinkit',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E2E2E),
                                          letterSpacing: -0.5,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Text(
                                        'Enter your phone number to get started\nwith instant grocery delivery',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Form section
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Phone input field
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: _phoneFocusNode.hasFocus
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF00C853,
                                                    ).withOpacity(0.15),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                        ),
                                        child: TextField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocusNode,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2E2E2E),
                                            letterSpacing: 1.5,
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            hintText: '9876543210',
                                            hintStyle: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 1.5,
                                            ),
                                            prefixIcon: Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF00C853,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      '🇮🇳 +91',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(
                                                          0xFF00C853,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Colors.grey.shade300,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 12,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: _hasError
                                                    ? Colors.red.shade300
                                                    : Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: _hasError
                                                    ? Colors.red.shade600
                                                    : const Color(0xFF00C853),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 20,
                                                ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          onChanged: (value) {
                                            if (_hasError &&
                                                value.length == 10) {
                                              setState(() {
                                                _hasError = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      // Send OTP Button
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: double.infinity,
                                        height: 58,
                                        child: ElevatedButton(
                                          onPressed:
                                              context
                                                  .watch<UserProvider>()
                                                  .isLoading
                                              ? null
                                              : _verifyPhone,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00C853,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            disabledBackgroundColor:
                                                Colors.grey.shade300,
                                          ),
                                          child:
                                              context
                                                  .watch<UserProvider>()
                                                  .isLoading
                                              ? TweenAnimationBuilder<double>(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  tween: Tween(
                                                    begin: 0.0,
                                                    end: 1.0,
                                                  ),
                                                  builder: (context, value, child) {
                                                    return Opacity(
                                                      opacity: value,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 22,
                                                            height: 22,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    Colors.white
                                                                        .withOpacity(
                                                                          0.9,
                                                                        ),
                                                                  ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 16,
                                                          ),
                                                          TweenAnimationBuilder<
                                                            double
                                                          >(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      400,
                                                                ),
                                                            tween: Tween(
                                                              begin: 0.0,
                                                              end: 1.0,
                                                            ),
                                                            builder: (context, value, child) {
                                                              return Transform.translate(
                                                                offset: Offset(
                                                                  0.0,
                                                                  (1 - value) *
                                                                      10,
                                                                ),
                                                                child: Opacity(
                                                                  opacity:
                                                                      value,
                                                                  child: const Text(
                                                                    'Sending OTP...',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.sms,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'Send OTP',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),

                                      // const SizedBox(height: 24),

                                      // Terms and privacy
                                      // Container(
                                      //   padding: const EdgeInsets.all(16),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.orange.shade50,
                                      //     borderRadius: BorderRadius.circular(12),
                                      //     border: Border.all(color: Colors.orange.shade100),
                                      //   ),
                                      //   child: Row(
                                      //     children: [
                                      //       Icon(Icons.info_outline,
                                      //            color: Colors.orange.shade700, size: 20),
                                      //       const SizedBox(width: 12),
                                      //       Expanded(
                                      //         child: RichText(
                                      //           text: TextSpan(
                                      //             style: TextStyle(
                                      //               color: Colors.orange.shade800,
                                      //               fontSize: 12,
                                      //               fontWeight: FontWeight.w400,
                                      //             ),
                                      //             children: const [
                                      //               TextSpan(
                                      //                 text: 'By continuing, you agree to our ',
                                      //               ),
                                      //               TextSpan(
                                      //                 text: 'Terms of Service',
                                      //                 style: TextStyle(
                                      //                   fontWeight: FontWeight.w600,
                                      //                   decoration: TextDecoration.underline,
                                      //                 ),
                                      //               ),
                                      //               TextSpan(text: ' and '),
                                      //               TextSpan(
                                      //                 text: 'Privacy Policy',
                                      //                 style: TextStyle(
                                      //                   fontWeight: FontWeight.w600,
                                      //                   decoration: TextDecoration.underline,
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:blinkit_clone/screens/otp_screen.dart';
// import 'package:blinkit_clone/screens/signup_screen.dart';
// import 'package:blinkit_clone/screens/main_screen.dart';

// class PhoneLoginScreen extends StatefulWidget {
//   const PhoneLoginScreen({super.key});

//   @override
//   State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
// }

// class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
//   final _phoneController = TextEditingController();
//   bool _isLoading = false;

//   void _verifyPhone() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: '+91${_phoneController.text}',
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           _checkUserExists();
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(e.message ?? 'Verification Failed')),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OTPScreen(
//                 verificationId: verificationId,
//                 phoneNumber: _phoneController.text,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {},
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Error sending OTP')));
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _checkUserExists() async {
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(_phoneController.text)
//         .get();

//     if (!mounted) return;

//     if (userDoc.exists) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainScreen()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               SignupScreen(phoneNumber: _phoneController.text),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.green),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               maxLength: 10,
//               decoration: const InputDecoration(
//                 labelText: 'Phone Number',
//                 hintText: 'Enter your 10 digit phone number',
//                 prefix: Text('+91 '),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyPhone,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Send OTP',
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
