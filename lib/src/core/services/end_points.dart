// ignore_for_file: constant_identifier_names

class EndPoints {
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  static const String home = 'home';
  static const String login = 'auth/dashboard/login';
  static const String subjects = 'subjects';
  static const String createSubject = 'create';
  static const String editSubject = 'edit';
  static const String deleteSubject = 'delete';
  static const String create = 'create';
  static const String update = 'update';
  static const String requests = 'dashboard/course-enrollments/index';
  static const String request_accept = 'dashboard/course-enrollments/update';
  static const String admins = 'admins';
  static const String createAdmin = 'createAdmin';
  static const String dashboard_admins_helper = 'dashboard/admins/helper';
  static const String dashboard_subjects_all = 'dashboard/subjects/all';
  static const String dashboard_subjects_create = 'dashboard/subjects/create';
  static const String dashboard_subjects_update = 'dashboard/subjects/update';
  static const String dashboard_teachers_index = 'dashboard/teachers/index';
  static const String dashboard_teachers_create = 'dashboard/teachers/create';
  static const String dashboard_teachers_update = 'dashboard/teachers/update';
  static const String dashboard_teacher_payouts_all =
      'dashboard/teacher-payouts/all';
  static const String dashboard_payouts_update =
      'dashboard/teacher-payouts/update';
  static const String dashboard_courses_index = 'dashboard/courses/index';
  static const String dashboard_courses_create = 'dashboard/courses/create';
  static const String dashboard_courses_update = 'dashboard/courses/update';
  static const String dashboard_course_sessions_all =
      'dashboard/course-sessions/all';
  static const String attendance_sync = 'attendance/sync';
  static const String dashboard_course_sessions_show =
      'dashboard/course-sessions/show';
  static const String dashboard_homeworks_create = 'dashboard/homeworks/create';
  static const String dashboard_quizzes_create = 'dashboard/quizzes/create';
}
