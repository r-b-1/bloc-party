import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final uid = FirebaseAuth.instance.currentUser!.uid;

///  Appointment creation logic
List<Appointment> convertToCalendarAppointments(
  List<UserAppointment> userAppts,
) {
  return userAppts
      .map(
        (u) => Appointment(
          startTime: u.startTime!,
          endTime: u.endTime!,
          subject: u.subject ?? '',
          color: u.color ?? Colors.blue,
        ),
      )
      .toList();
}

class UserAppointment {
  DateTime? startTime;
  DateTime? endTime;
  String? subject;
  Color? color;
  String? notes;
  String? userId;

  UserAppointment({
    this.startTime,
    this.endTime,
    this.subject,
    this.color,
    this.notes,
    this.userId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'color': color?.value,
      'notes': notes,
      'userId': userId,
    };
  }

factory UserAppointment.fromFirestore(Map<String, dynamic> data) {
  return UserAppointment(
    startTime: (data['startTime'] as Timestamp).toDate(),
    endTime: (data['endTime'] as Timestamp).toDate(),
    subject: data['subject'] ?? '',
    color: data['color'] != null ? Color(data['color'] as int) : null,
    notes: data['notes'] ?? '',
    userId: data['userId'] ?? '',
  );
}
}

Future<List<UserAppointment>> fetchUserAppointments() async {
  // 1. Use the 'await' keyword inside the 'async' function
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final snapshot = await FirebaseFirestore.instance
      .collection('user_appointment')
      .where('userId', isEqualTo: uid)
      .get();
  return snapshot.docs
      .map((doc) => UserAppointment.fromFirestore(doc.data()))
      .toList();
}

///  Calendar DataSource
class DateScheduled extends CalendarDataSource {
  DateScheduled(List<Appointment> source) {
    appointments = source;
  }
}

///  Global calendar view options
final List<CalendarView> calendarViews = [
  CalendarView.month,
  CalendarView.week,
  CalendarView.day,
];

final Map<CalendarView, String> calendarViewNames = {
  CalendarView.month: "Month",
  CalendarView.week: "Week",
  CalendarView.day: "Day",
};

///  Global controller (used by the UI)
class ScheduleController extends ChangeNotifier {
  CalendarView currentView = CalendarView.week;

  void setView(CalendarView newView) {
    currentView = newView;
    notifyListeners();
  }
}

/// Global instance used everywhere
final ScheduleController scheduleController = ScheduleController();


SfCalendar makeCalendar({
  required CalendarView view,
  required CalendarDataSource dataSource,
  required void Function(CalendarTapDetails) onTap,
}) {
  return SfCalendar(
    key: ValueKey(view),
    view: view,
    dataSource: dataSource,
    appointmentBuilder: (context, details) {
      final Appointment appt = details.appointments.first;
      return Container(
        padding: const EdgeInsets.all(4),
        color: appt.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appt.subject,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              appt.notes ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    },
    onTap: onTap,
  );
}



