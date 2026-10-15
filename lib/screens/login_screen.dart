import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/developer_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;

  // Controllers for Login
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Additional Controllers for Registration
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<AppProvider>();

    if (_isRegisterMode) {
      // Registration flow
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('كلمة المرور وتأكيدها غير متطابقين',
                textAlign: TextAlign.center),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      final error = await provider.registerUser(
        username: _usernameController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
        phone: _phoneController.text,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, textAlign: TextAlign.center),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح! مرحباً بك.',
                textAlign: TextAlign.center),
            backgroundColor: Color(0xFF047857),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() => _isSubmitting = true);
      final success = await provider.login(
          _usernameController.text, _passwordController.text);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.loginError ?? 'فشل تسجيل الدخول',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _quickLogin(UserRole role) {
    context.read<AppProvider>().loginAsRole(role);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon & Header
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF065F46), Color(0xFF047857)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF047857).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'حلقات القربات',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'منظومة إدارة الحلقات القرآنية والتعليم الشرعي',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const DeveloperLogo(),
                  const SizedBox(height: 22),

                  if (!provider.isCloudMode)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isRegisterMode = false;
                                  _formKey.currentState?.reset();
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isRegisterMode
                                      ? const Color(0xFF047857)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'تسجيل الدخول',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_isRegisterMode
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isRegisterMode = true;
                                  _formKey.currentState?.reset();
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isRegisterMode
                                      ? const Color(0xFF047857)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'إنشاء حساب جديد',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isRegisterMode
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Form Card
                  Card(
                    elevation: 3,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isRegisterMode
                                  ? 'إنشاء حساب مستخدم جديد'
                                  : 'تسجيل الدخول للنظام',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),

                            // If register: Full Name
                            if (_isRegisterMode) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الكامل',
                                  hintText: 'مثال: أحمد عبد الله',
                                  prefixIcon: const Icon(Icons.badge_outlined,
                                      color: Color(0xFF047857)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'يرجى إدخال الاسم الكامل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Username
                            TextFormField(
                              controller: _usernameController,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                labelText: 'اسم المستخدم',
                                hintText: _isRegisterMode
                                    ? 'username (أحرف إنجليزية)'
                                    : 'admin أو user',
                                prefixIcon: const Icon(Icons.person_outline,
                                    color: Color(0xFF047857)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'يرجى إدخال اسم المستخدم';
                                }
                                if (_isRegisterMode && val.trim().length < 3) {
                                  return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // If register: Phone (optional)
                            if (_isRegisterMode) ...[
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: 'رقم الهاتف (اختياري)',
                                  hintText: '05xxxxxxxx',
                                  prefixIcon: const Icon(Icons.phone_outlined,
                                      color: Color(0xFF047857)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Color(0xFF047857)),
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
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                if (_isRegisterMode && val.trim().length < 4) {
                                  return 'كلمة المرور يجب أن تكون 4 خانات على الأقل';
                                }
                                return null;
                              },
                            ),

                            // If register: Confirm Password
                            if (_isRegisterMode) ...[
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_reset,
                                      color: Color(0xFF047857)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'يرجى تأكيد كلمة المرور';
                                  }
                                  if (val != _passwordController.text) {
                                    return 'كلمة المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Submit Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF047857),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                              ),
                              onPressed: _isSubmitting ? null : _submit,
                              child: Text(
                                _isSubmitting
                                    ? 'جارٍ التحقق...'
                                    : _isRegisterMode
                                        ? 'إنشاء الحساب ودخول التطبيق'
                                        : 'دخول',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 12),

                            if (!provider.isCloudMode)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isRegisterMode = !_isRegisterMode;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                child: Text(
                                  _isRegisterMode
                                      ? 'لديك حساب بالفعل؟ تسجيل الدخول'
                                      : 'ليس لديك حساب؟ إنشاء حساب مستخدم جديد',
                                  style: const TextStyle(
                                      color: Color(0xFF047857),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // If in login mode: show quick logins
                  if (provider.isCloudMode && !_isRegisterMode) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'الحسابات السحابية تُنشأ وتُدار بواسطة مدير النظام.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF065F46)),
                    ),
                  ],

                  if (!_isRegisterMode && !provider.isCloudMode) ...[
                    const SizedBox(height: 18),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color:
                                const Color(0xFF047857).withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on,
                                    color: Color(0xFFD97706), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'تسجيل دخول سريع للتجربة:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF065F46),
                                side: const BorderSide(
                                    color: Color(0xFF047857), width: 1.5),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: const Color(0xFFECFDF5),
                              ),
                              onPressed: () => _quickLogin(UserRole.admin),
                              icon: const Icon(Icons.admin_panel_settings,
                                  color: Color(0xFF047857)),
                              label: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('الدخول كـ مدير (Admin)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('(كامل صلاحيات التعديل)',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF047857))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1E40AF),
                                side: const BorderSide(
                                    color: Color(0xFF3B82F6), width: 1.5),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: const Color(0xFFEFF6FF),
                              ),
                              onPressed: () => _quickLogin(UserRole.user),
                              icon: const Icon(Icons.menu_book,
                                  color: Color(0xFF2563EB)),
                              label: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('الدخول كـ مستخدم (User)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('(قراءة وتصفح فقط)',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2563EB))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'بيانات الحسابات التجريبية:',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• المدير: اسم المستخدم: admin | كلمة المرور: admin123\n• المستخدم: اسم المستخدم: user | كلمة المرور: user123',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFF92400E), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ملاحظة: الحسابات الجديدة تُنشأ بصلاحية "مستخدم عادي" (قراءة وتصفح فقط). لتغيير الصلاحية يرجى التواصل مع إدارة حلقات القربات.',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF92400E),
                                  height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
