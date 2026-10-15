import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets/app_bar_actions.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل بيانات الطلاب والدرجات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF065F46),
        foregroundColor: Colors.white,
        actions: const [UserAppBarActions()],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddStudentDialog(context),
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('رفع بيانات طالب'),
            )
          : null,
      body: Column(
        children: [
          const ReadOnlyBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.students.length,
              itemBuilder: (context, index) {
                final student = provider.students[index];
                final studentGrades = provider.grades.where((g) => g.studentId == student.id).toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${student.circleName} • المحفوظ: ${student.memorizedParts} أجزاء\nولي الأمر: ${student.guardianPhone}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdmin) ...[
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF047857)),
                            tooltip: 'تعديل بيانات الطالب',
                            onPressed: () => _showEditStudentDialog(context, student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            tooltip: 'حذف الطالب',
                            onPressed: () => _confirmDeleteStudent(context, student),
                          ),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showStudentDetails(context, student, studentGrades, isAdmin),
                          child: const Text('الدرجات والملف'),
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

  void _showStudentDetails(BuildContext context, StudentModel student, List<GradeModel> grades, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(student.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            Text('كود الطالب: ${student.studentCode} | الحلقة: ${student.circleName}', style: TextStyle(color: Colors.grey[700])),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الدرجات والتقييمات:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (isAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _showAddGradeDialog(ctx, student.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('رصد درجة'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'عرض الدرجات فقط',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: grades.isEmpty
                  ? const Center(child: Text('لا توجد درجات مرصودة حتى الآن'))
                  : ListView.builder(
                      itemCount: grades.length,
                      itemBuilder: (context, index) {
                        final g = grades[index];
                        return Card(
                          child: ListTile(
                            title: Text(g.testTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('النوع: ${g.category} | التاريخ: ${g.date}\nملاحظات: ${g.notes}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${g.score} / ${g.maxScore}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                if (isAdmin) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF047857)),
                                    tooltip: 'تعديل الدرجة',
                                    onPressed: () => _showEditGradeDialog(ctx, g),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    tooltip: 'حذف الدرجة',
                                    onPressed: () => _confirmDeleteGrade(ctx, g),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context, int studentId) {
    final titleCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'تسميع دوري');
    final scoreCtrl = TextEditingController(text: '95');
    final maxCtrl = TextEditingController(text: '100');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رصد درجة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان الاختبار / التسميع')),
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'نوع التقييم')),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: scoreCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الدرجة')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الدرجة القصوى')),
                ),
              ],
            ),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظة المعلم')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().addGrade(GradeModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  studentId: studentId,
                  testTitle: titleCtrl.text,
                  category: catCtrl.text,
                  score: double.tryParse(scoreCtrl.text) ?? 95,
                  maxScore: double.tryParse(maxCtrl.text) ?? 100,
                  date: DateTime.now().toString().split(' ')[0],
                  notes: notesCtrl.text,
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

  void _showEditGradeDialog(BuildContext context, GradeModel grade) {
    final titleCtrl = TextEditingController(text: grade.testTitle);
    final catCtrl = TextEditingController(text: grade.category);
    final scoreCtrl = TextEditingController(text: grade.score.toString());
    final maxCtrl = TextEditingController(text: grade.maxScore.toString());
    final notesCtrl = TextEditingController(text: grade.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFF047857)),
            SizedBox(width: 8),
            Text('تعديل الدرجة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان الاختبار / التسميع')),
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'نوع التقييم')),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: scoreCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الدرجة')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الدرجة القصوى')),
                ),
              ],
            ),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظة المعلم')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ctx.read<AppProvider>().updateGrade(grade.copyWith(
                  testTitle: titleCtrl.text,
                  category: catCtrl.text,
                  score: double.tryParse(scoreCtrl.text) ?? grade.score,
                  maxScore: double.tryParse(maxCtrl.text) ?? grade.maxScore,
                  notes: notesCtrl.text,
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

  void _confirmDeleteGrade(BuildContext context, GradeModel grade) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الدرجة'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف درجة "${grade.testTitle}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
            onPressed: () {
              ctx.read<AppProvider>().deleteGrade(grade.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '14');
    final levelCtrl = TextEditingController(text: 'المرحلة المتوسطة');
    final partsCtrl = TextEditingController(text: '3');
    final circles = context.read<AppProvider>().circles;
    int selectedCircleId = circles.isNotEmpty ? circles.first.id : 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('رفع بيانات طالب جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الطالب الرباعي')),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'هاتف ولي الأمر')),
                TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العمر')),
                TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'المستوى الدراسي')),
                TextField(controller: partsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الأجزاء المحفوظة')),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedCircleId,
                  decoration: const InputDecoration(labelText: 'الحلقة'),
                  items: circles.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedCircleId = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final circle = circles.firstWhere((c) => c.id == selectedCircleId, orElse: () => circles.first);
                  ctx.read<AppProvider>().addStudent(StudentModel(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: nameCtrl.text,
                    studentCode: 'STD-${DateTime.now().millisecond}',
                    circleId: circle.id,
                    circleName: circle.name,
                    age: int.tryParse(ageCtrl.text) ?? 14,
                    educationalLevel: levelCtrl.text,
                    guardianPhone: phoneCtrl.text,
                    enrollmentDate: DateTime.now().toString().split(' ')[0],
                    memorizedParts: int.tryParse(partsCtrl.text) ?? 0,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ الطالب'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, StudentModel student) {
    final nameCtrl = TextEditingController(text: student.name);
    final phoneCtrl = TextEditingController(text: student.guardianPhone);
    final studentPhoneCtrl = TextEditingController(text: student.studentPhone);
    final ageCtrl = TextEditingController(text: student.age.toString());
    final levelCtrl = TextEditingController(text: student.educationalLevel);
    final partsCtrl = TextEditingController(text: student.memorizedParts.toString());
    final notesCtrl = TextEditingController(text: student.notes);
    final circles = context.read<AppProvider>().circles;
    int selectedCircleId = student.circleId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Color(0xFF047857)),
              SizedBox(width: 8),
              Text('تعديل بيانات الطالب'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الطالب الرباعي')),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'هاتف ولي الأمر')),
                TextField(controller: studentPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'هاتف الطالب (اختياري)')),
                TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'العمر')),
                TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'المستوى الدراسي')),
                TextField(controller: partsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الأجزاء المحفوظة')),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات')),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: circles.any((c) => c.id == selectedCircleId) ? selectedCircleId : (circles.isNotEmpty ? circles.first.id : null),
                  decoration: const InputDecoration(labelText: 'الحلقة'),
                  items: circles.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedCircleId = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final circle = circles.firstWhere((c) => c.id == selectedCircleId, orElse: () => circles.first);
                  ctx.read<AppProvider>().updateStudent(student.copyWith(
                    name: nameCtrl.text,
                    guardianPhone: phoneCtrl.text,
                    studentPhone: studentPhoneCtrl.text,
                    age: int.tryParse(ageCtrl.text) ?? student.age,
                    educationalLevel: levelCtrl.text,
                    memorizedParts: int.tryParse(partsCtrl.text) ?? student.memorizedParts,
                    notes: notesCtrl.text,
                    circleId: circle.id,
                    circleName: circle.name,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteStudent(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف الطالب'),
          ],
        ),
        content: Text('هل أنت متأكد من حذف الطالب "${student.name}"؟ سيتم حذف جميع درجاته وسجلات حضوره المرتبطة به نهائياً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
            onPressed: () {
              ctx.read<AppProvider>().deleteStudent(student.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف الطالب "${student.name}" بنجاح'),
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
