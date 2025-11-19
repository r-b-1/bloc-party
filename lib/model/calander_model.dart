import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';



///  Appointment creation logic
List<Appointment> makeAppointments(
  int hours,
  int days,
  String sub,
  String notes,
) {
  final DateTime now = DateTime.now();
  final DateTime startTime = DateTime(now.year, now.month, now.day, 9, 0, 0);
  final DateTime endTime = startTime.add(Duration(days: days, hours: hours));

  return [
    Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: sub,
      color: Colors.blue,
      notes: 'this is a test',
    ),
  ];
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