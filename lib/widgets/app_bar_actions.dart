import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';

import '../screens/users_management_screen.dart';
import 'developer_logo.dart';

class UserAppBarActions extends StatelessWidget {
  const UserAppBarActions({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('تسجيل الخروج'),
          ],
        ),
        content:
            const Text('هل ترغب في تسجيل الخروج والعودة لشاشة تسجيل الدخول؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppProvider>().logout();
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.isAdmin;
    final user = provider.currentUser;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DeveloperLogo(onDarkBackground: true, compact: true),
        const SizedBox(width: 6),
        // Admin Management Icon
        if (isAdmin) ...[
          IconButton(
            icon: const Icon(Icons.manage_accounts,
                color: Colors.white, size: 22),
            tooltip: 'إدارة واستعراض المستخدمين',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const UsersManagementScreen()),
              );
            },
          ),
          const SizedBox(width: 2),
        ],

        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAdmin ? const Color(0xFF047857) : const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isAdmin ? const Color(0xFF34D399) : const Color(0xFF93C5FD),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.visibility,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isAdmin ? 'مدير' : 'قراءة فقط',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
          tooltip: 'تسجيل الخروج (${user?.displayName ?? ""})',
          onPressed: () => _confirmLogout(context),
        ),
      ],
    );
  }
}

class ReadOnlyBanner extends StatelessWidget {
  const ReadOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AppProvider>().isAdmin;
    if (isAdmin) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFFEF3C7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF92400E)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'حساب مستخدم (وضع القراءة فقط) • لا تملك صلاحية إضافة أو تعديل البيانات.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
