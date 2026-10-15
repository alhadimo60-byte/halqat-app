import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/app_bar_actions.dart';

class CurriculaScreen extends StatelessWidget {
  const CurriculaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.isAdmin;
    final curricula = provider.curricula;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المناهج والكتب الدراسية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        actions: const [UserAppBarActions()],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCurriculumDialog(context),
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.post_add),
              label: const Text('إضافة منهج جديد'),
            )
          : null,
      body: Column(
        children: [
          const ReadOnlyBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: curricula.length,
              itemBuilder: (context, index) {
                final c = curricula[index];
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
                              child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Chip(label: Text(c.category)),
                            if (isAdmin) ...[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF047857)),
                                tooltip: 'تعديل المنهج',
                                onPressed: () => _showEditCurriculumDialog(context, c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                tooltip: 'حذف المنهج',
                                onPressed: () => _confirmDeleteCurriculum(context, c),
                              ),
                            ],
                          ],
                        ),
                        Text('المؤلف: ${c.author} • عدد الدروس: ${c.totalLessons}', style: TextStyle(color: Colors.grey[700])),
                        Text('المستوى المستهدف: ${c.targetLevel}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(c.summary),
                        const Divider(),
                        Text('المحاور: ${c.keyTopics}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  void _showAddCurriculumDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'تجويد');
    final authorCtrl = TextEditingController();
    final lessonsCtrl = TextEditingController(text: '20');
    final levelCtrl = TextEditingController(text: 'الناشئة');
    final summaryCtrl = TextEditingController();
    final topicsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة منهج تعليمي جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان المنهج / الكتاب')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'التصنيف (تجويد، حديث، فقه...)')),
              TextField(controller: authorCtrl, decoration: const InputDecoration(labelText: 'المؤلف')),
              TextField(controller: lessonsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'إجمالي الدروس')),
              TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'المستوى المستهدف')),
              TextField(controller: summaryCtrl, decoration: const InputDecoration(labelText: 'نبذة عن المنهج')),
              TextField(controller: topicsCtrl, decoration: const InputDecoration(labelText: 'المحاور الرئيسية')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().addCurriculum(CurriculumModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleCtrl.text,
                  category: catCtrl.text,
                  author: authorCtrl.text,
                  totalLessons: int.tryParse(lessonsCtrl.text) ?? 20,
                  targetLevel: levelCtrl.text,
                  summary: summaryCtrl.text,
                  keyTopics: topicsCtrl.text,
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

  void _showEditCurriculumDialog(BuildContext context, CurriculumModel curriculum) {
    final titleCtrl = TextEditingController(text: curriculum.title);
    final catCtrl = TextEditingController(text: curriculum.category);
    final authorCtrl = TextEditingController(text: curriculum.author);
    final lessonsCtrl = TextEditingController(text: curriculum.totalLessons.toString());
    final levelCtrl = TextEditingController(text: curriculum.targetLevel);
    final summaryCtrl = TextEditingController(text: curriculum.summary);
    final topicsCtrl = TextEditingController(text: curriculum.keyTopics);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFF047857)),
            SizedBox(width: 8),
            Text('تعديل المنهج'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان المنهج / الكتاب')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'التصنيف')),
              TextField(controller: authorCtrl, decoration: const InputDecoration(labelText: 'المؤلف')),
              TextField(controller: lessonsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'إجمالي الدروس')),
              TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'المستوى المستهدف')),
              TextField(controller: summaryCtrl, decoration: const InputDecoration(labelText: 'نبذة عن المنهج')),
              TextField(controller: topicsCtrl, decoration: const InputDecoration(labelText: 'المحاور الرئيسية')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().updateCurriculum(curriculum.copyWith(
                  title: titleCtrl.text,
                  category: catCtrl.text,
                  author: authorCtrl.text,
                  totalLessons: int.tryParse(lessonsCtrl.text) ?? curriculum.totalLessons,
                  targetLevel: levelCtrl.text,
                  summary: summaryCtrl.text,
                  keyTopics: topicsCtrl.text,
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

  void _confirmDeleteCurriculum(BuildContext context, CurriculumModel curriculum) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف المنهج'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف منهج "${curriculum.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
            onPressed: () {
              ctx.read<AppProvider>().deleteCurriculum(curriculum.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف منهج "${curriculum.title}" بنجاح'),
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
