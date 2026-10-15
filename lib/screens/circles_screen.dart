import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/app_bar_actions.dart';

class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('حلقات التعليم والتحفيظ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        actions: const [UserAppBarActions()],
      ),
      floatingActionButton: provider.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCircleDialog(context),
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('إضافة حلقة جديدة'),
            )
          : null,
      body: Column(
        children: [
          const ReadOnlyBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.circles.length,
              itemBuilder: (context, index) {
          final circle = provider.circles[index];
          final enrolled = provider.students.where((s) => s.circleId == circle.id).length;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(circle.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Chip(
                        label: Text(circle.category, style: const TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFFEF3C7),
                      ),
                      if (provider.isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF047857)),
                          tooltip: 'تعديل بيانات الحلقة',
                          onPressed: () => _showEditCircleDialog(context, circle),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          tooltip: 'حذف الحلقة',
                          onPressed: () => _confirmDeleteCircle(context, circle, enrolled),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(circle.description, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const Divider(height: 20),
                  Text('المعلم المشرف: ${circle.teacherName}', style: const TextStyle(fontSize: 13)),
                  Text('الموعد: ${circle.timing}', style: const TextStyle(fontSize: 13)),
                  Text('المقر: ${circle.location}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المسجلون: $enrolled من ${circle.maxCapacity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
                        onPressed: () {
                          provider.setAttendanceCircle(circle.id);
                          provider.setTab(3);
                        },
                        icon: const Icon(Icons.fact_check, size: 16),
                        label: const Text('تحضير الحلقة'),
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

  void _showAddCircleDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    final timingCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة حلقة تعليمية جديدة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الحلقة')),
              TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'اسم المعلم')),
              TextField(controller: timingCtrl, decoration: const InputDecoration(labelText: 'الوقت والموعد')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'المستوى / الفئة')),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'المقر أو القاعة')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'وصف موجز')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().addCircle(CircleModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameCtrl.text,
                  teacherName: teacherCtrl.text,
                  timing: timingCtrl.text,
                  category: catCtrl.text,
                  location: locCtrl.text,
                  maxCapacity: 20,
                  description: descCtrl.text,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditCircleDialog(BuildContext context, CircleModel circle) {
    final nameCtrl = TextEditingController(text: circle.name);
    final teacherCtrl = TextEditingController(text: circle.teacherName);
    final timingCtrl = TextEditingController(text: circle.timing);
    final catCtrl = TextEditingController(text: circle.category);
    final locCtrl = TextEditingController(text: circle.location);
    final descCtrl = TextEditingController(text: circle.description);
    final capCtrl = TextEditingController(text: circle.maxCapacity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFF047857)),
            SizedBox(width: 8),
            Text('تعديل بيانات الحلقة'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الحلقة')),
              TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'اسم المعلم')),
              TextField(controller: timingCtrl, decoration: const InputDecoration(labelText: 'الوقت والموعد')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'المستوى / الفئة')),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'المقر أو القاعة')),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعة القصوى')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'وصف موجز')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().updateCircle(circle.copyWith(
                  name: nameCtrl.text,
                  teacherName: teacherCtrl.text,
                  timing: timingCtrl.text,
                  category: catCtrl.text,
                  location: locCtrl.text,
                  maxCapacity: int.tryParse(capCtrl.text) ?? circle.maxCapacity,
                  description: descCtrl.text,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCircle(BuildContext context, CircleModel circle, int enrolled) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الحلقة'),
          ],
        ),
        content: Text(
          enrolled > 0
              ? 'تنبيه: يوجد $enrolled طلاب مسجلين في "${circle.name}". حذف الحلقة سيؤدي أيضاً إلى حذف بيانات تسجيلهم وسجلات حضورهم المرتبطة بها.\n\nهل أنت متأكد من الحذف؟'
              : 'هل أنت متأكد من رغبتك في حذف حلقة "${circle.name}"؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
            onPressed: () {
              ctx.read<AppProvider>().deleteCircle(circle.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف حلقة "${circle.name}" بنجاح'),
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
