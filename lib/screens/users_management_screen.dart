import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/developer_logo.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final users = provider.users;
    final currentUserId = provider.currentUser?.id;

    final totalAdmins = users.where((u) => u.role == UserRole.admin).length;
    final totalRegular = users.where((u) => u.role == UserRole.user).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة واستعراض المستخدمين',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: DeveloperLogo(onDarkBackground: true, compact: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('إضافة مستخدم جديد'),
      ),
      body: Column(
        children: [
          // Stat Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFECFDF5),
            child: Row(
              children: [
                _buildStatCard(
                  title: 'إجمالي الحسابات',
                  count: users.length.toString(),
                  icon: Icons.people,
                  color: const Color(0xFF065F46),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'المدراء',
                  count: totalAdmins.toString(),
                  icon: Icons.admin_panel_settings,
                  color: const Color(0xFF047857),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'المستخدمون',
                  count: totalRegular.toString(),
                  icon: Icons.visibility,
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isCurrent = user.id == currentUserId;
                final isAdminUser = user.role == UserRole.admin;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isAdminUser
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              child: Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0]
                                    : 'U',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Name & Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.displayName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber[100],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'حسابك الحالي',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.amber[900],
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${user.username}',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),

                            // Role Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAdminUser
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAdminUser
                                      ? const Color(0xFF047857)
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAdminUser
                                        ? Icons.shield
                                        : Icons.visibility,
                                    size: 14,
                                    color: isAdminUser
                                        ? const Color(0xFF047857)
                                        : const Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAdminUser ? 'مدير' : 'مستخدم',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isAdminUser
                                          ? const Color(0xFF047857)
                                          : const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 20),

                        // Info row
                        Row(
                          children: [
                            if (user.phone.isNotEmpty) ...[
                              Icon(Icons.phone,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(user.phone,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700])),
                              const SizedBox(width: 16),
                            ],
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('تاريخ التسجيل: ${user.createdAt}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700])),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Action Buttons for this user
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Role Switch button
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: isAdminUser
                                    ? Colors.orange[800]
                                    : const Color(0xFF047857),
                              ),
                              onPressed: isCurrent
                                  ? null
                                  : () => _confirmChangeRole(context, user),
                              icon: Icon(
                                isAdminUser
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                size: 16,
                              ),
                              label: Text(
                                isAdminUser ? 'خفض لمستخدم' : 'ترقية لمدير',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Edit Button
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 20, color: Color(0xFF047857)),
                              tooltip: 'تعديل بيانات المستخدم',
                              onPressed: () =>
                                  _showEditUserDialog(context, user),
                            ),

                            // Delete Button
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color:
                                    isCurrent ? Colors.grey[400] : Colors.red,
                              ),
                              tooltip: isCurrent
                                  ? 'لا يمكن حذف حسابك الحالي'
                                  : 'حذف المستخدم',
                              onPressed: isCurrent
                                  ? null
                                  : () => _confirmDeleteUser(context, user),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmChangeRole(BuildContext context, UserModel user) {
    final willBeAdmin = user.role == UserRole.user;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              willBeAdmin ? Icons.verified_user : Icons.remove_moderator,
              color: willBeAdmin ? const Color(0xFF047857) : Colors.orange[800],
            ),
            const SizedBox(width: 8),
            Text(willBeAdmin ? 'ترقية إلى مدير' : 'تحويل إلى مستخدم عادي'),
          ],
        ),
        content: Text(
          willBeAdmin
              ? 'هل تريد ترقية "${user.displayName}" ليصبح مديراً بصلاحيات كاملة تشمل التعديل والحذف؟'
              : 'هل تريد تحويل "${user.displayName}" إلى مستخدم عادي بصلاحيات القراءة والتصفح فقط؟',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  willBeAdmin ? const Color(0xFF047857) : Colors.orange[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<AppProvider>().toggleUserRole(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تحديث صلاحية "${user.displayName}" بنجاح'),
                  backgroundColor: const Color(0xFF047857),
                ),
              );
            },
            child: const Text('تأكيد التغيير'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    UserRole selectedRole = UserRole.user;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('إضافة مستخدم جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'الاسم الكامل')),
                TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                        labelText: 'اسم المستخدم (أحرف إنجليزية)')),
                TextField(
                    controller: passCtrl,
                    decoration:
                        const InputDecoration(labelText: 'كلمة المرور')),
                TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف')),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'صلاحية الحساب'),
                  items: const [
                    DropdownMenuItem(
                        value: UserRole.user,
                        child: Text('مستخدم عادي (قراءة وتصفح فقط)')),
                    DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('مدير النظام (صلاحيات كاملة)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white),
              onPressed: () {
                if (userCtrl.text.isNotEmpty &&
                    passCtrl.text.isNotEmpty &&
                    nameCtrl.text.isNotEmpty) {
                  final provider = context.read<AppProvider>();
                  if (provider.isCloudMode &&
                      passCtrl.text.trim().length < 12) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'كلمة المرور السحابية يجب أن تكون 12 خانة على الأقل'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final exists = provider.users.any((u) =>
                      u.username.toLowerCase() ==
                      userCtrl.text.trim().toLowerCase());
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('اسم المستخدم مسجل مسبقاً'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  provider.adminCreateUser(UserModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    username: userCtrl.text.trim().toLowerCase(),
                    password: passCtrl.text.trim(),
                    displayName: nameCtrl.text.trim(),
                    role: selectedRole,
                    phone: phoneCtrl.text.trim(),
                    createdAt: DateTime.now().toString().split(' ')[0],
                  ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'تمت إضافة المستخدم "${nameCtrl.text}" بنجاح')),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final cloudMode = context.read<AppProvider>().isCloudMode;
    final nameCtrl = TextEditingController(text: user.displayName);
    final phoneCtrl = TextEditingController(text: user.phone);
    final passCtrl =
        TextEditingController(text: cloudMode ? '' : user.password);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Color(0xFF047857)),
              SizedBox(width: 8),
              Text('تعديل بيانات المستخدم'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('اسم المستخدم: @${user.username}',
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'الاسم الكامل')),
                TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف')),
                TextField(
                  controller: passCtrl,
                  decoration: InputDecoration(
                    labelText: cloudMode
                        ? 'كلمة المرور الجديدة (اختياري)'
                        : 'كلمة المرور',
                    helperText: cloudMode
                        ? 'اتركه فارغًا للإبقاء على كلمة المرور الحالية'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'الصلاحية'),
                  items: const [
                    DropdownMenuItem(
                        value: UserRole.user,
                        child: Text('مستخدم عادي (قراءة فقط)')),
                    DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('مدير النظام (صلاحيات كاملة)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white),
              onPressed: () {
                final password = passCtrl.text.trim();
                if (nameCtrl.text.isNotEmpty &&
                    (cloudMode
                        ? password.isEmpty || password.length >= 12
                        : password.isNotEmpty)) {
                  context.read<AppProvider>().updateUser(user.copyWith(
                        displayName: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        password: password.isEmpty ? user.password : password,
                        role: selectedRole,
                      ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('تم تحديث بيانات "${nameCtrl.text}" بنجاح')),
                  );
                }
              },
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الحساب'),
          ],
        ),
        content: Text(
            'هل أنت متأكد من رغبتك في حذف حساب "${user.displayName}" (@${user.username}) نهائياً؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white),
            onPressed: () {
              context.read<AppProvider>().deleteUser(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف المستخدم "${user.displayName}" بنجاح'),
                  backgroundColor: Colors.red[700],
                ),
              );
            },
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }
}
