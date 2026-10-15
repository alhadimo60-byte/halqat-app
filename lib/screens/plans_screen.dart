import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/app_bar_actions.dart';

class StudyPlansScreen extends StatelessWidget {
  const StudyPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.isAdmin;
    final plans = provider.studyPlans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الخطط ومستهدفات الحفظ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        actions: const [UserAppBarActions()],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddPlanDialog(context),
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_task),
              label: const Text('إضافة خطة جديدة'),
            )
          : null,
      body: Column(
        children: [
          const ReadOnlyBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final p = plans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Chip(label: Text(p.status), backgroundColor: Colors.green[100]),
                            if (isAdmin) ...[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF047857)),
                                tooltip: 'تعديل الخطة',
                                onPressed: () => _showEditPlanDialog(context, p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                tooltip: 'حذف الخطة',
                                onPressed: () => _confirmDeletePlan(context, p),
                              ),
                            ],
                          ],
                        ),
                        Text('المدة: ${p.durationWeeks} أسبوعاً | الفئة: ${p.circleCategory}'),
                        const Divider(),
                        Text('• مستهدف الحفظ: ${p.weeklyMemorization}'),
                        Text('• مستهدف المراجعة: ${p.weeklyRevision}'),
                        Text('• التركيز التجويدي: ${p.educationalFocus}'),
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

  void _showAddPlanDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'الناشئة والفتيان');
    final durationCtrl = TextEditingController(text: '16');
    final memoCtrl = TextEditingController();
    final revCtrl = TextEditingController();
    final focusCtrl = TextEditingController();
    final statusCtrl = TextEditingController(text: 'نشطة');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة خطة حفظ ومراجعة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان الخطة')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'الفئة المستهدفة')),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدة الخطة (بالأسابيع)')),
              TextField(controller: memoCtrl, decoration: const InputDecoration(labelText: 'مستهدف الحفظ الأسبوعي')),
              TextField(controller: revCtrl, decoration: const InputDecoration(labelText: 'مستهدف المراجعة الأسبوعي')),
              TextField(controller: focusCtrl, decoration: const InputDecoration(labelText: 'التركيز التجويدي والتربوي')),
              TextField(controller: statusCtrl, decoration: const InputDecoration(labelText: 'حالة الخطة (نشطة، مكتملة)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().addStudyPlan(StudyPlanModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleCtrl.text,
                  circleCategory: catCtrl.text,
                  durationWeeks: int.tryParse(durationCtrl.text) ?? 16,
                  weeklyMemorization: memoCtrl.text,
                  weeklyRevision: revCtrl.text,
                  educationalFocus: focusCtrl.text,
                  status: statusCtrl.text,
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

  void _showEditPlanDialog(BuildContext context, StudyPlanModel plan) {
    final titleCtrl = TextEditingController(text: plan.title);
    final catCtrl = TextEditingController(text: plan.circleCategory);
    final durationCtrl = TextEditingController(text: plan.durationWeeks.toString());
    final memoCtrl = TextEditingController(text: plan.weeklyMemorization);
    final revCtrl = TextEditingController(text: plan.weeklyRevision);
    final focusCtrl = TextEditingController(text: plan.educationalFocus);
    final statusCtrl = TextEditingController(text: plan.status);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFF047857)),
            SizedBox(width: 8),
            Text('تعديل الخطة الدراسية'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان الخطة')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'الفئة المستهدفة')),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدة الخطة (بالأسابيع)')),
              TextField(controller: memoCtrl, decoration: const InputDecoration(labelText: 'مستهدف الحفظ الأسبوعي')),
              TextField(controller: revCtrl, decoration: const InputDecoration(labelText: 'مستهدف المراجعة الأسبوعي')),
              TextField(controller: focusCtrl, decoration: const InputDecoration(labelText: 'التركيز التجويدي والتربوي')),
              TextField(controller: statusCtrl, decoration: const InputDecoration(labelText: 'حالة الخطة')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().updateStudyPlan(plan.copyWith(
                  title: titleCtrl.text,
                  circleCategory: catCtrl.text,
                  durationWeeks: int.tryParse(durationCtrl.text) ?? plan.durationWeeks,
                  weeklyMemorization: memoCtrl.text,
                  weeklyRevision: revCtrl.text,
                  educationalFocus: focusCtrl.text,
                  status: statusCtrl.text,
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

  void _confirmDeletePlan(BuildContext context, StudyPlanModel plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الخطة الدراسية'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف الخطة "${plan.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
            onPressed: () {
              ctx.read<AppProvider>().deleteStudyPlan(plan.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف الخطة "${plan.title}" بنجاح'),
                  backgroundColor: Colors.red[700],
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
