import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final uid = FirebaseAuth.instance.currentUser!.uid;

/// Fetch appointments from Firestore
Future<List<Appointment>> fetchAppointments() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('user_appointment')
      .where('userId', isEqualTo: uid)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Appointment(
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      subject: data['subject'] ?? '',
      color: data['color'] != null ? Color(data['color'] as int) : Colors.blue,
      notes: data['notes'] ?? '',
      id: doc.id, // Store Firestore docId
    );
  }).toList();
}

/// Delete appointment from Firestore
Future<void> deleteAppointment(Appointment appt) async {
  final docId = appt.id as String?;
  if (docId != null) {
    await FirebaseFirestore.instance
        .collection('user_appointment')
        .doc(docId)
        .delete();
  }
}

Map<String, dynamic> appointmentToFirestore(Appointment appt) {
  return {
    'startTime': appt.startTime,
    'endTime': appt.endTime,
    'subject': appt.subject,
    'color': appt.color?.value,
    'notes': appt.notes,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };
}

/// Calendar DataSource
class DateScheduled extends CalendarDataSource {
  DateScheduled(List<Appointment> source) {
    appointments = source;
  }
}

/// Global calendar views
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

/// Calendar controller
class ScheduleController extends ChangeNotifier {
  CalendarView currentView = CalendarView.week;

  void setView(CalendarView newView) {
    currentView = newView;
    notifyListeners();
  }
}

final ScheduleController scheduleController = ScheduleController();

/// Build the calendar
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    appt.notes ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () async {
                await deleteAppointment(appt);
                dataSource.appointments!.remove(appt);
                dataSource.notifyListeners(
                  CalendarDataSourceAction.remove,
                  [appt],
                );
              },
            ),
          ],
        ),
      );
    },
    onTap: onTap,
  );
  
}
