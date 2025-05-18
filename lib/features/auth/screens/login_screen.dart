import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logistics_demo/theme/palette.dart';
import 'package:logistics_demo/features/dashboard/screens/main_screen.dart';
import 'package:logistics_demo/services/auth_service.dart';
import 'package:logistics_demo/theme/spacing.dart';
import 'package:logistics_demo/widgets/gradient_button.dart';
import 'package:logistics_demo/widgets/custom_text_field.dart';
import 'package:logistics_demo/widgets/custom_text.dart';
import 'package:logistics_demo/constants/image_constants.dart';

const width = Spacing.space200 * 2.25; // 450.0
const webWidth = Spacing.space200 * 3; // 600.0

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: AppLocalizations.of(context)!.invalidCredentials,
              style: CustomText.errorStyle,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: AppLocalizations.of(context)!.generalError,
            style: CustomText.errorStyle,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > webWidth;
          final contentWidth = isWeb ? width : constraints.maxWidth;
          final logoSize =
              isWeb ? Spacing.space200 : constraints.maxWidth * 0.4;
          final padding = isWeb ? Spacing.space48 : Spacing.space24;

          return Center(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: contentWidth,
                  padding: EdgeInsets.all(padding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo with constrained size
                        Center(
                          child: SizedBox(
                            width: logoSize,
                            height: logoSize,
                            child: Image.asset(
                              ImageConstants.logoPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: isWeb ? 48.0 : 24.0),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          labelText: AppLocalizations.of(context)!.emailLabel,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          isDesktop: isWeb,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.enterEmail;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: isWeb ? Spacing.space24 : Spacing.space16,
                        ),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          labelText:
                              AppLocalizations.of(context)!.passwordLabel,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock,
                          isDesktop: isWeb,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.enterPassword;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: isWeb ? Spacing.space32 : Spacing.space24,
                        ),

                        // Login Button
                        GradientButton(
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
