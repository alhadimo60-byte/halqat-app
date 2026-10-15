enum UserRole {
  admin,
  user,
}

class UserModel {
  final String id;
  final String username;
  final String password;
  final String displayName;
  final UserRole role;
  final String phone;
  final String createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.displayName,
    required this.role,
    this.phone = '',
    String? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? '2026-03-01';

  UserModel copyWith({
    String? username,
    String? password,
    String? displayName,
    UserRole? role,
    String? phone,
    String? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'displayName': displayName,
      'role': role.name,
      'phone': phone,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.user,
      phone: map['phone']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '2026-03-01',
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

class CircleModel {
  final int id;
  final String name;
  final String teacherName;
  final String timing;
  final String category;
  final String location;
  final int maxCapacity;
  final String description;

  CircleModel({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.timing,
    required this.category,
    required this.location,
    required this.maxCapacity,
    required this.description,
  });

  CircleModel copyWith({
    String? name,
    String? teacherName,
    String? timing,
    String? category,
    String? location,
    int? maxCapacity,
    String? description,
  }) {
    return CircleModel(
      id: id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      timing: timing ?? this.timing,
      category: category ?? this.category,
      location: location ?? this.location,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherName': teacherName,
      'timing': timing,
      'category': category,
      'location': location,
      'maxCapacity': maxCapacity,
      'description': description,
    };
  }

  factory CircleModel.fromMap(Map<String, dynamic> map) {
    return CircleModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      timing: map['timing']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      maxCapacity: (map['maxCapacity'] as num?)?.toInt() ?? 20,
      description: map['description']?.toString() ?? '',
    );
  }
}

class CurriculumModel {
  final int id;
  final String title;
  final String category;
  final String author;
  final int totalLessons;
  final String targetLevel;
  final String summary;
  final String keyTopics;

  CurriculumModel({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.totalLessons,
    required this.targetLevel,
    required this.summary,
    required this.keyTopics,
  });

  CurriculumModel copyWith({
    String? title,
    String? category,
    String? author,
    int? totalLessons,
    String? targetLevel,
    String? summary,
    String? keyTopics,
  }) {
    return CurriculumModel(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      author: author ?? this.author,
      totalLessons: totalLessons ?? this.totalLessons,
      targetLevel: targetLevel ?? this.targetLevel,
      summary: summary ?? this.summary,
      keyTopics: keyTopics ?? this.keyTopics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'author': author,
      'totalLessons': totalLessons,
      'targetLevel': targetLevel,
      'summary': summary,
      'keyTopics': keyTopics,
    };
  }

  factory CurriculumModel.fromMap(Map<String, dynamic> map) {
    return CurriculumModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      totalLessons: (map['totalLessons'] as num?)?.toInt() ?? 0,
      targetLevel: map['targetLevel']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      keyTopics: map['keyTopics']?.toString() ?? '',
    );
  }
}

class StudyPlanModel {
  final int id;
  final String title;
  final String circleCategory;
  final int durationWeeks;
  final String weeklyMemorization;
  final String weeklyRevision;
  final String educationalFocus;
  final String status;

  StudyPlanModel({
    required this.id,
    required this.title,
    required this.circleCategory,
    required this.durationWeeks,
    required this.weeklyMemorization,
    required this.weeklyRevision,
    required this.educationalFocus,
    required this.status,
  });

  StudyPlanModel copyWith({
    String? title,
    String? circleCategory,
    int? durationWeeks,
    String? weeklyMemorization,
    String? weeklyRevision,
    String? educationalFocus,
    String? status,
  }) {
    return StudyPlanModel(
      id: id,
      title: title ?? this.title,
      circleCategory: circleCategory ?? this.circleCategory,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      weeklyMemorization: weeklyMemorization ?? this.weeklyMemorization,
      weeklyRevision: weeklyRevision ?? this.weeklyRevision,
      educationalFocus: educationalFocus ?? this.educationalFocus,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'circleCategory': circleCategory,
      'durationWeeks': durationWeeks,
      'weeklyMemorization': weeklyMemorization,
      'weeklyRevision': weeklyRevision,
      'educationalFocus': educationalFocus,
      'status': status,
    };
  }

  factory StudyPlanModel.fromMap(Map<String, dynamic> map) {
    return StudyPlanModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      circleCategory: map['circleCategory']?.toString() ?? '',
      durationWeeks: (map['durationWeeks'] as num?)?.toInt() ?? 16,
      weeklyMemorization: map['weeklyMemorization']?.toString() ?? '',
      weeklyRevision: map['weeklyRevision']?.toString() ?? '',
      educationalFocus: map['educationalFocus']?.toString() ?? '',
      status: map['status']?.toString() ?? 'نشطة',
    );
  }
}

class StudentModel {
  final int id;
  final String name;
  final String studentCode;
  final int circleId;
  final String circleName;
  final int age;
  final String educationalLevel;
  final String guardianPhone;
  final String studentPhone;
  final String enrollmentDate;
  final int memorizedParts;
  final String notes;

  StudentModel({
    required this.id,
    required this.name,
    required this.studentCode,
    required this.circleId,
    required this.circleName,
    required this.age,
    required this.educationalLevel,
    required this.guardianPhone,
    this.studentPhone = '',
    required this.enrollmentDate,
    required this.memorizedParts,
    this.notes = '',
  });

  StudentModel copyWith({
    String? name,
    String? studentCode,
    int? circleId,
    String? circleName,
    int? age,
    String? educationalLevel,
    String? guardianPhone,
    String? studentPhone,
    String? enrollmentDate,
    int? memorizedParts,
    String? notes,
  }) {
    return StudentModel(
      id: id,
      name: name ?? this.name,
      studentCode: studentCode ?? this.studentCode,
      circleId: circleId ?? this.circleId,
      circleName: circleName ?? this.circleName,
      age: age ?? this.age,
      educationalLevel: educationalLevel ?? this.educationalLevel,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      studentPhone: studentPhone ?? this.studentPhone,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      memorizedParts: memorizedParts ?? this.memorizedParts,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentCode': studentCode,
      'circleId': circleId,
      'circleName': circleName,
      'age': age,
      'educationalLevel': educationalLevel,
      'guardianPhone': guardianPhone,
      'studentPhone': studentPhone,
      'enrollmentDate': enrollmentDate,
      'memorizedParts': memorizedParts,
      'notes': notes,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString() ?? '',
      studentCode: map['studentCode']?.toString() ?? '',
      circleId: (map['circleId'] as num?)?.toInt() ?? 1,
      circleName: map['circleName']?.toString() ?? '',
      age: (map['age'] as num?)?.toInt() ?? 14,
      educationalLevel: map['educationalLevel']?.toString() ?? '',
      guardianPhone: map['guardianPhone']?.toString() ?? '',
      studentPhone: map['studentPhone']?.toString() ?? '',
      enrollmentDate: map['enrollmentDate']?.toString() ?? '',
      memorizedParts: (map['memorizedParts'] as num?)?.toInt() ?? 0,
      notes: map['notes']?.toString() ?? '',
    );
  }
}

class AttendanceModel {
  final int id;
  final int studentId;
  final int circleId;
  final String date;
  final String status;
  final String notes;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.circleId,
    required this.date,
    required this.status,
    this.notes = '',
  });

  AttendanceModel copyWith({String? status, String? notes}) {
    return AttendanceModel(
      id: id,
      studentId: studentId,
      circleId: circleId,
      date: date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'circleId': circleId,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      studentId: (map['studentId'] as num?)?.toInt() ?? 0,
      circleId: (map['circleId'] as num?)?.toInt() ?? 0,
      date: map['date']?.toString() ?? '',
      status: map['status']?.toString() ?? 'حاضر',
      notes: map['notes']?.toString() ?? '',
    );
  }
}

class GradeModel {
  final int id;
  final int studentId;
  final String testTitle;
  final String category;
  final double score;
  final double maxScore;
  final String date;
  final String notes;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.testTitle,
    required this.category,
    required this.score,
    required this.maxScore,
    required this.date,
    this.notes = '',
  });

  GradeModel copyWith({
    String? testTitle,
    String? category,
    double? score,
    double? maxScore,
    String? date,
    String? notes,
  }) {
    return GradeModel(
      id: id,
      studentId: studentId,
      testTitle: testTitle ?? this.testTitle,
      category: category ?? this.category,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'testTitle': testTitle,
      'category': category,
      'score': score,
      'maxScore': maxScore,
      'date': date,
      'notes': notes,
    };
  }

  factory GradeModel.fromMap(Map<String, dynamic> map) {
    return GradeModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      studentId: (map['studentId'] as num?)?.toInt() ?? 0,
      testTitle: map['testTitle']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['maxScore'] as num?)?.toDouble() ?? 100.0,
      date: map['date']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
    );
  }
}
