import 'package:flutter_test/flutter_test.dart';
import 'package:halaqat_app/models.dart';

void main() {
  group('Models Serialization Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        id: 'u123',
        username: 'testadmin',
        password: 'password123',
        displayName: 'المشرف العام',
        role: UserRole.admin,
        phone: '0501234567',
        createdAt: '2026-03-18',
        isActive: true,
      );

      final map = user.toMap();
      final restored = UserModel.fromMap(map);

      expect(restored.id, equals(user.id));
      expect(restored.username, equals(user.username));
      expect(restored.password, equals(user.password));
      expect(restored.displayName, equals(user.displayName));
      expect(restored.role, equals(UserRole.admin));
      expect(restored.phone, equals(user.phone));
      expect(restored.createdAt, equals(user.createdAt));
      expect(restored.isActive, isTrue);
    });

    test('CircleModel serialization and deserialization', () {
      final circle = CircleModel(
        id: 10,
        name: 'حلقة الفرقان',
        teacherName: 'الشيخ أحمد',
        timing: 'عصراً',
        category: 'تلقين',
        location: 'المسجد الرئيسي',
        maxCapacity: 25,
        description: 'حلقة مخصصة للمبتدئين',
      );

      final map = circle.toMap();
      final restored = CircleModel.fromMap(map);

      expect(restored.id, equals(10));
      expect(restored.name, equals('حلقة الفرقان'));
      expect(restored.teacherName, equals('الشيخ أحمد'));
      expect(restored.timing, equals('عصراً'));
      expect(restored.maxCapacity, equals(25));
    });

    test('CurriculumModel serialization and deserialization', () {
      final cur = CurriculumModel(
        id: 5,
        title: 'عمدة الفقه',
        category: 'فقه',
        author: 'ابن قدامة',
        totalLessons: 30,
        targetLevel: 'متوسط',
        summary: 'متن فقهي مبسط',
        keyTopics: 'الطهارة والصلاة',
      );

      final map = cur.toMap();
      final restored = CurriculumModel.fromMap(map);

      expect(restored.id, equals(5));
      expect(restored.title, equals('عمدة الفقه'));
      expect(restored.author, equals('ابن قدامة'));
      expect(restored.totalLessons, equals(30));
    });

    test('StudyPlanModel serialization and deserialization', () {
      final plan = StudyPlanModel(
        id: 8,
        title: 'خطة حفظ جزء النبأ',
        circleCategory: 'مبتدئ',
        durationWeeks: 12,
        weeklyMemorization: 'سورة',
        weeklyRevision: 'ما سبق',
        educationalFocus: 'التجويد',
        status: 'نشطة',
      );

      final map = plan.toMap();
      final restored = StudyPlanModel.fromMap(map);

      expect(restored.id, equals(8));
      expect(restored.title, equals('خطة حفظ جزء النبأ'));
      expect(restored.durationWeeks, equals(12));
    });

    test('StudentModel serialization and deserialization', () {
      final student = StudentModel(
        id: 99,
        name: 'زيد بن ثابت',
        studentCode: 'STD-999',
        circleId: 1,
        circleName: 'حلقة الصديق',
        age: 14,
        educationalLevel: 'متوسط',
        guardianPhone: '0555555555',
        studentPhone: '0566666666',
        enrollmentDate: '2026-01-10',
        memorizedParts: 5,
        notes: 'طالب مجتهد',
      );

      final map = student.toMap();
      final restored = StudentModel.fromMap(map);

      expect(restored.id, equals(99));
      expect(restored.name, equals('زيد بن ثابت'));
      expect(restored.studentCode, equals('STD-999'));
      expect(restored.circleId, equals(1));
      expect(restored.memorizedParts, equals(5));
    });

    test('AttendanceModel serialization and deserialization', () {
      final att = AttendanceModel(
        id: 101,
        studentId: 99,
        circleId: 1,
        date: '2026-03-18',
        status: 'حاضر',
        notes: 'مشارك بفعالية',
      );

      final map = att.toMap();
      final restored = AttendanceModel.fromMap(map);

      expect(restored.id, equals(101));
      expect(restored.studentId, equals(99));
      expect(restored.status, equals('حاضر'));
      expect(restored.notes, equals('مشارك بفعالية'));
    });

    test('GradeModel serialization and deserialization', () {
      final grade = GradeModel(
        id: 42,
        studentId: 99,
        testTitle: 'اختبار جزء عم',
        category: 'تسميع نهائي',
        score: 99.5,
        maxScore: 100,
        date: '2026-03-18',
        notes: 'درجة استثنائية',
      );

      final map = grade.toMap();
      final restored = GradeModel.fromMap(map);

      expect(restored.id, equals(42));
      expect(restored.studentId, equals(99));
      expect(restored.score, equals(99.5));
      expect(restored.maxScore, equals(100));
      expect(restored.testTitle, equals('اختبار جزء عم'));
    });
  });
}
