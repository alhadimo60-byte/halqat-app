import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool get isCloudMode => _storage.isCloudEnabled;
  String? _startupError;
  String? get startupError => _startupError;
  String? _operationError;
  String? get operationError => _operationError;

  AppProvider() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    if (_storage.isCloudEnabled) {
      try {
        _currentUser = await _storage.restoreCloudSession();
        if (_currentUser != null) {
          await _loadCloudState();
        }
      } catch (error) {
        _startupError = error.toString();
        _currentUser = null;
      }
      _isInitialized = true;
      notifyListeners();
      return;
    }

    final savedUsers = await _storage.loadUsers();
    if (savedUsers != null && savedUsers.isNotEmpty) {
      _users.clear();
      _users.addAll(savedUsers);
    } else {
      await _storage.saveUsers(_users);
    }

    final savedCircles = await _storage.loadCircles();
    if (savedCircles != null) {
      _circles.clear();
      _circles.addAll(savedCircles);
      if (_circles.isNotEmpty) {
        _selectedAttendanceCircleId = _circles.first.id;
      }
    } else {
      await _storage.saveCircles(_circles);
    }

    final savedCurricula = await _storage.loadCurricula();
    if (savedCurricula != null) {
      _curricula.clear();
      _curricula.addAll(savedCurricula);
    } else {
      await _storage.saveCurricula(_curricula);
    }

    final savedPlans = await _storage.loadStudyPlans();
    if (savedPlans != null) {
      _studyPlans.clear();
      _studyPlans.addAll(savedPlans);
    } else {
      await _storage.saveStudyPlans(_studyPlans);
    }

    final savedStudents = await _storage.loadStudents();
    if (savedStudents != null) {
      _students.clear();
      _students.addAll(savedStudents);
    } else {
      await _storage.saveStudents(_students);
    }

    final savedAttendance = await _storage.loadAttendance();
    if (savedAttendance != null) {
      _attendance.clear();
      _attendance.addAll(savedAttendance);
    } else {
      await _storage.saveAttendance(_attendance);
    }

    final savedGrades = await _storage.loadGrades();
    if (savedGrades != null) {
      _grades.clear();
      _grades.addAll(savedGrades);
    } else {
      await _storage.saveGrades(_grades);
    }

    final savedUserId = await _storage.loadCurrentUserId();
    if (savedUserId != null && _currentUser == null) {
      final foundUser = _users.firstWhere(
        (u) => u.id == savedUserId && u.isActive,
        orElse: () => UserModel(
          id: '',
          username: '',
          password: '',
          displayName: '',
          role: UserRole.user,
        ),
      );
      if (foundUser.id.isNotEmpty) {
        _currentUser = foundUser;
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadCloudState() async {
    final currentUser = _currentUser;
    if (currentUser == null) return;

    _users
      ..clear()
      ..addAll(currentUser.role == UserRole.admin
          ? (await _storage.loadUsers() ?? [currentUser])
          : [currentUser]);

    final savedCircles = await _storage.loadCircles();
    if (savedCircles != null) {
      _circles
        ..clear()
        ..addAll(savedCircles);
      if (_circles.isNotEmpty) {
        _selectedAttendanceCircleId = _circles.first.id;
      }
    }
    final savedCurricula = await _storage.loadCurricula();
    if (savedCurricula != null) {
      _curricula
        ..clear()
        ..addAll(savedCurricula);
    }
    final savedPlans = await _storage.loadStudyPlans();
    if (savedPlans != null) {
      _studyPlans
        ..clear()
        ..addAll(savedPlans);
    }
    final savedStudents = await _storage.loadStudents();
    if (savedStudents != null) {
      _students
        ..clear()
        ..addAll(savedStudents);
    }
    final savedAttendance = await _storage.loadAttendance();
    if (savedAttendance != null) {
      _attendance
        ..clear()
        ..addAll(savedAttendance);
    }
    final savedGrades = await _storage.loadGrades();
    if (savedGrades != null) {
      _grades
        ..clear()
        ..addAll(savedGrades);
    }
  }

  Future<void> _persist(Future<void> operation) async {
    try {
      await operation;
      _operationError = null;
    } on StorageException catch (error) {
      _operationError = error.message;
    } catch (error) {
      _operationError = 'تعذر حفظ البيانات: $error';
    }
    notifyListeners();
  }

  Future<void> _persistAll(List<Future<void>> operations) async {
    try {
      await Future.wait(operations);
      _operationError = null;
    } on StorageException catch (error) {
      _operationError = error.message;
    } catch (error) {
      _operationError = 'تعذر حفظ البيانات: $error';
    }
    notifyListeners();
  }

  String? takeOperationError() {
    final error = _operationError;
    _operationError = null;
    return error;
  }

  int _currentTab = 0;
  int get currentTab => _currentTab;

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  final List<UserModel> _users = [
    UserModel(
      id: '1',
      username: 'admin',
      password: 'admin123',
      displayName: 'مدير النظام',
      role: UserRole.admin,
      phone: '0501112233',
      createdAt: '2026-01-01',
    ),
    UserModel(
      id: '2',
      username: 'user',
      password: 'user123',
      displayName: 'مستخدم تجريبي (قراءة فقط)',
      role: UserRole.user,
      phone: '0504445566',
      createdAt: '2026-02-15',
    ),
  ];
  List<UserModel> get users => List.unmodifiable(_users);

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  String? _loginError;
  String? get loginError => _loginError;

  Future<bool> login(String username, String password) async {
    _loginError = null;
    final trimmedUser = username.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (_storage.isCloudEnabled) {
      try {
        _currentUser = await _storage.loginCloud(trimmedUser, trimmedPass);
        await _loadCloudState();
        _currentTab = 0;
        notifyListeners();
        return true;
      } on StorageException catch (error) {
        _currentUser = null;
        _loginError = error.message;
        notifyListeners();
        return false;
      } catch (error) {
        _currentUser = null;
        _loginError = 'تعذر الاتصال بالخادم: $error';
        notifyListeners();
        return false;
      }
    }

    final found = _users.firstWhere(
      (u) =>
          u.username.toLowerCase() == trimmedUser && u.password == trimmedPass,
      orElse: () => UserModel(
        id: '',
        username: '',
        password: '',
        displayName: '',
        role: UserRole.user,
      ),
    );

    if (found.id.isNotEmpty) {
      if (!found.isActive) {
        _loginError = 'هذا الحساب معطل حالياً. يرجى مراجعة إدارة الحلقات.';
        notifyListeners();
        return false;
      }
      _currentUser = found;
      await _storage.saveCurrentUserId(_currentUser?.id);
      notifyListeners();
      return true;
    } else {
      _loginError = 'اسم المستخدم أو كلمة المرور غير صحيحة';
      notifyListeners();
      return false;
    }
  }

  void loginAsRole(UserRole role) {
    if (_storage.isCloudEnabled) {
      _loginError = 'الدخول السريع غير متاح على الحسابات السحابية';
      notifyListeners();
      return;
    }
    _loginError = null;
    final user = _users.firstWhere(
      (u) => u.role == role,
      orElse: () => _users.first,
    );
    _currentUser = user;
    _storage.saveCurrentUserId(_currentUser?.id);
    notifyListeners();
  }

  Future<String?> registerUser({
    required String username,
    required String password,
    required String displayName,
    String phone = '',
  }) async {
    if (_storage.isCloudEnabled) {
      return 'إنشاء الحسابات السحابية متاح للمدير فقط';
    }

    final trimmedUser = username.trim().toLowerCase();
    if (trimmedUser.length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    if (password.trim().length < 4) {
      return 'كلمة المرور يجب أن تكون 4 خانات على الأقل';
    }
    if (displayName.trim().isEmpty) {
      return 'يرجى كتابة الاسم الكامل';
    }

    final exists = _users.any((u) => u.username.toLowerCase() == trimmedUser);
    if (exists) {
      return 'اسم المستخدم هذا مستخدم بالفعل، يرجى اختيار اسم آخر';
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: trimmedUser,
      password: password.trim(),
      displayName: displayName.trim(),
      role: UserRole.user,
      phone: phone.trim(),
      createdAt: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    _users.add(newUser);
    _currentUser = newUser;
    _loginError = null;
    _persist(_storage.saveUsers(_users));
    await _storage.saveCurrentUserId(_currentUser?.id);
    notifyListeners();
    return null;
  }

  void adminCreateUser(UserModel user) {
    if (!isAdmin) return;
    _users.add(user);
    _persist(_storage.saveUsers(_users));
    notifyListeners();
  }

  void updateUser(UserModel user) {
    if (!isAdmin) return;
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _users[index] = user;
      if (_currentUser?.id == user.id) {
        _currentUser = user;
      }
      _persist(_storage.saveUsers(_users));
      notifyListeners();
    }
  }

  void toggleUserRole(String userId) {
    if (!isAdmin) return;
    final index = _users.indexWhere((u) => u.id == userId);
    if (index >= 0) {
      final old = _users[index];
      final newRole =
          old.role == UserRole.admin ? UserRole.user : UserRole.admin;
      _users[index] = old.copyWith(role: newRole);
      if (_currentUser?.id == userId) {
        _currentUser = _users[index];
      }
      _persist(_storage.saveUsers(_users));
      notifyListeners();
    }
  }

  void toggleUserStatus(String userId) {
    if (!isAdmin) return;
    final index = _users.indexWhere((u) => u.id == userId);
    if (index >= 0) {
      final old = _users[index];
      _users[index] = old.copyWith(isActive: !old.isActive);
      _persist(_storage.saveUsers(_users));
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    if (!isAdmin) return;
    if (_currentUser?.id == userId) return;
    _users.removeWhere((u) => u.id == userId);
    _persist(_storage.saveUsers(_users));
    notifyListeners();
  }

  Future<void> logout() async {
    if (_storage.isCloudEnabled) {
      try {
        await _storage.logoutCloud();
      } catch (error) {
        _operationError = 'تعذر إغلاق الجلسة على الخادم: $error';
        notifyListeners();
        return;
      }
    }
    _currentUser = null;
    _currentTab = 0;
    _loginError = null;
    if (!_storage.isCloudEnabled) {
      await _storage.saveCurrentUserId(null);
    }
    notifyListeners();
  }

  final List<CircleModel> _circles = [
    CircleModel(
      id: 1,
      name: "حلقة الصديق",
      teacherName: "الأستاذ عبدالله",
      timing: "بعد صلاة المغرب",
      category: "",
      location: "المصلى",
      maxCapacity: 15,
      description: "",
    ),
    CircleModel(
      id: 2,
      name: "حلقة الفاروق",
      teacherName: "الأستاذ محمد",
      timing: "بعد صلاة المغرب",
      category: "",
      location: "المصلى",
      maxCapacity: 18,
      description: "",
    ),
    CircleModel(
      id: 3,
      name: "حلقة أبي الحسنين",
      teacherName: "الأستاذ عبدالله",
      timing: "بعد صلاة المغرب",
      category: "",
      location: "المصلى",
      maxCapacity: 20,
      description: "",
    ),
  ];
  List<CircleModel> get circles => _circles;

  final List<CurriculumModel> _curricula = [
    CurriculumModel(
      id: 1,
      title: "سفينة النجاة",
      category: "فقه",
      author: "",
      totalLessons: 18,
      targetLevel: "",
      summary: "",
      keyTopics: "",
    ),
    CurriculumModel(
      id: 2,
      title: "الأربعون النووية",
      category: "حديث شريف",
      author: "الإمام يحيى بن شرف النووي",
      totalLessons: 24,
      targetLevel: "",
      summary: "",
      keyTopics: "",
    ),
  ];
  List<CurriculumModel> get curricula => _curricula;

  final List<StudyPlanModel> _studyPlans = [
    StudyPlanModel(
      id: 1,
      title: "خطة إتمام حفظ جزء عم وتبارك",
      circleCategory: "",
      durationWeeks: 16,
      weeklyMemorization: "",
      weeklyRevision: "",
      educationalFocus: "",
      status: "نشطة",
    ),
  ];
  List<StudyPlanModel> get studyPlans => _studyPlans;

  final List<StudentModel> _students = [
    StudentModel(
      id: 1,
      name: "عبد الله بن محمد",
      studentCode: "STD-201",
      circleId: 1,
      circleName: "حلقة الصديق",
      age: 15,
      educationalLevel: "المرحلة المتوسطة",
      guardianPhone: "0501234567",
      studentPhone: "0559876543",
      enrollmentDate: "2025-09-01",
      memorizedParts: 12,
      notes: "",
    ),
    StudentModel(
      id: 2,
      name: "عمر بن علي",
      studentCode: "STD-202",
      circleId: 2,
      circleName: "حلقة الفاروق",
      age: 16,
      educationalLevel: "",
      guardianPhone: "0531122334",
      enrollmentDate: "2025-09-05",
      memorizedParts: 9,
      notes: "",
    ),
    StudentModel(
      id: 3,
      name: "طالب تجريبي",
      studentCode: "STD-301",
      circleId: 3,
      circleName: "حلقة أبي الحسنين",
      age: 11,
      educationalLevel: "المرحلة الابتدائية",
      guardianPhone: "0544556677",
      enrollmentDate: "2025-09-10",
      memorizedParts: 4,
      notes: "",
    ),
  ];
  List<StudentModel> get students => _students;

  final List<AttendanceModel> _attendance = [];
  int _selectedAttendanceCircleId = 1;
  int get selectedAttendanceCircleId => _selectedAttendanceCircleId;

  DateTime _attendanceDate = DateTime.now();
  String get attendanceDateString =>
      DateFormat('yyyy-MM-dd').format(_attendanceDate);

  final List<GradeModel> _grades = [
    GradeModel(
      id: 1,
      studentId: 1,
      testTitle: "اختبار جزء الذاريات",
      category: "حفظ جديد",
      score: 98,
      maxScore: 100,
      date: "2026-03-10",
      notes: "ممتاز جداً مع ترتيل متقن",
    ),
  ];
  List<GradeModel> get grades => _grades;

  void addCircle(CircleModel circle) {
    if (!isAdmin) return;
    _circles.add(circle);
    _persist(_storage.saveCircles(_circles));
    notifyListeners();
  }

  void updateCircle(CircleModel circle) {
    if (!isAdmin) return;
    final index = _circles.indexWhere((c) => c.id == circle.id);
    if (index >= 0) {
      _circles[index] = circle;
      for (int i = 0; i < _students.length; i++) {
        if (_students[i].circleId == circle.id) {
          _students[i] = _students[i].copyWith(circleName: circle.name);
        }
      }
      _persistAll([
        _storage.saveCircles(_circles),
        _storage.saveStudents(_students),
      ]);
      notifyListeners();
    }
  }

  void deleteCircle(int circleId) {
    if (!isAdmin) return;
    _circles.removeWhere((c) => c.id == circleId);
    final removedStudentIds =
        _students.where((s) => s.circleId == circleId).map((s) => s.id).toSet();
    _students.removeWhere((s) => s.circleId == circleId);
    _attendance.removeWhere((a) =>
        a.circleId == circleId || removedStudentIds.contains(a.studentId));
    _grades.removeWhere((g) => removedStudentIds.contains(g.studentId));
    if (_selectedAttendanceCircleId == circleId && _circles.isNotEmpty) {
      _selectedAttendanceCircleId = _circles.first.id;
    }
    _persistAll([
      _storage.saveCircles(_circles),
      _storage.saveStudents(_students),
      _storage.saveAttendance(_attendance),
      _storage.saveGrades(_grades),
    ]);
    notifyListeners();
  }

  void addCurriculum(CurriculumModel curriculum) {
    if (!isAdmin) return;
    _curricula.add(curriculum);
    _persist(_storage.saveCurricula(_curricula));
    notifyListeners();
  }

  void updateCurriculum(CurriculumModel curriculum) {
    if (!isAdmin) return;
    final index = _curricula.indexWhere((c) => c.id == curriculum.id);
    if (index >= 0) {
      _curricula[index] = curriculum;
      _persist(_storage.saveCurricula(_curricula));
      notifyListeners();
    }
  }

  void deleteCurriculum(int curriculumId) {
    if (!isAdmin) return;
    _curricula.removeWhere((c) => c.id == curriculumId);
    _persist(_storage.saveCurricula(_curricula));
    notifyListeners();
  }

  void addStudyPlan(StudyPlanModel plan) {
    if (!isAdmin) return;
    _studyPlans.add(plan);
    _persist(_storage.saveStudyPlans(_studyPlans));
    notifyListeners();
  }

  void updateStudyPlan(StudyPlanModel plan) {
    if (!isAdmin) return;
    final index = _studyPlans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      _studyPlans[index] = plan;
      _persist(_storage.saveStudyPlans(_studyPlans));
      notifyListeners();
    }
  }

  void deleteStudyPlan(int planId) {
    if (!isAdmin) return;
    _studyPlans.removeWhere((p) => p.id == planId);
    _persist(_storage.saveStudyPlans(_studyPlans));
    notifyListeners();
  }

  void addStudent(StudentModel student) {
    if (!isAdmin) return;
    _students.add(student);
    _persist(_storage.saveStudents(_students));
    notifyListeners();
  }

  void updateStudent(StudentModel student) {
    if (!isAdmin) return;
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index >= 0) {
      _students[index] = student;
      _persist(_storage.saveStudents(_students));
      notifyListeners();
    }
  }

  void deleteStudent(int studentId) {
    if (!isAdmin) return;
    _students.removeWhere((s) => s.id == studentId);
    _attendance.removeWhere((a) => a.studentId == studentId);
    _grades.removeWhere((g) => g.studentId == studentId);
    _persistAll([
      _storage.saveStudents(_students),
      _storage.saveAttendance(_attendance),
      _storage.saveGrades(_grades),
    ]);
    notifyListeners();
  }

  void setAttendanceCircle(int circleId) {
    _selectedAttendanceCircleId = circleId;
    notifyListeners();
  }

  void shiftAttendanceDate(int days) {
    _attendanceDate = _attendanceDate.add(Duration(days: days));
    notifyListeners();
  }

  AttendanceModel getOrCreateAttendance(int studentId, int circleId) {
    final dateStr = attendanceDateString;
    final existing = _attendance.firstWhere(
      (a) => a.studentId == studentId && a.date == dateStr,
      orElse: () => AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch + studentId,
        studentId: studentId,
        circleId: circleId,
        date: dateStr,
        status: 'حاضر',
      ),
    );
    if (!_attendance.contains(existing)) {
      _attendance.add(existing);
    }
    return existing;
  }

  void updateAttendanceStatus(int studentId, String status) {
    if (!isAdmin) return;
    final dateStr = attendanceDateString;
    final index = _attendance
        .indexWhere((a) => a.studentId == studentId && a.date == dateStr);
    if (index >= 0) {
      _attendance[index] = _attendance[index].copyWith(status: status);
    } else {
      _attendance.add(AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch,
        studentId: studentId,
        circleId: _selectedAttendanceCircleId,
        date: dateStr,
        status: status,
      ));
    }
    _persist(_storage.saveAttendance(_attendance));
    notifyListeners();
  }

  void updateAttendanceNote(int studentId, String note) {
    if (!isAdmin) return;
    final dateStr = attendanceDateString;
    final index = _attendance
        .indexWhere((a) => a.studentId == studentId && a.date == dateStr);
    if (index >= 0) {
      _attendance[index] = _attendance[index].copyWith(notes: note);
      _persist(_storage.saveAttendance(_attendance));
      notifyListeners();
    }
  }

  void markAllPresent() {
    if (!isAdmin) return;
    final dateStr = attendanceDateString;
    final circleStudents =
        _students.where((s) => s.circleId == _selectedAttendanceCircleId);
    for (var s in circleStudents) {
      final index = _attendance
          .indexWhere((a) => a.studentId == s.id && a.date == dateStr);
      if (index >= 0) {
        _attendance[index] = _attendance[index].copyWith(status: 'حاضر');
      } else {
        _attendance.add(AttendanceModel(
          id: DateTime.now().millisecondsSinceEpoch + s.id,
          studentId: s.id,
          circleId: s.circleId,
          date: dateStr,
          status: 'حاضر',
        ));
      }
    }
    _persist(_storage.saveAttendance(_attendance));
    notifyListeners();
  }

  void addGrade(GradeModel grade) {
    if (!isAdmin) return;
    _grades.add(grade);
    _persist(_storage.saveGrades(_grades));
    notifyListeners();
  }

  void updateGrade(GradeModel grade) {
    if (!isAdmin) return;
    final index = _grades.indexWhere((g) => g.id == grade.id);
    if (index >= 0) {
      _grades[index] = grade;
      _persist(_storage.saveGrades(_grades));
      notifyListeners();
    }
  }

  void deleteGrade(int gradeId) {
    if (!isAdmin) return;
    _grades.removeWhere((g) => g.id == gradeId);
    _persist(_storage.saveGrades(_grades));
    notifyListeners();
  }
}
