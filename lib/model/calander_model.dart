import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

List<Appointment> makeAppointments(int hours, int days, String sub, String notes) {
  List<Appointment> date = <Appointment>[];
  final DateTime day = DateTime.now();
  final DateTime startTime = DateTime(day.year, day.month, day.day, 9,0,0);
  final String subject = sub;
  final String note = notes;
  DateTime endTime = startTime.add(Duration(
    days: days,
    hours: hours,
    ));


  date.add(Appointment(
    startTime: startTime,
     endTime: endTime,
     subject: subject,
     color: Colors.blue,
     notes: note,
     ));

     return date;
}
class DateScheduled extends CalendarDataSource {
  DateScheduled(List<Appointment> source) {
    appointments = source;
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({Key? key}) : super(key: key);

    @override
  Widget build(BuildContext context) {
    final dataSource = DateScheduled(
      makeAppointments(2, 0, "Test Appointment", "This is a sample note"),
    );
        return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: dataSource,
      ),
    );
  }
}