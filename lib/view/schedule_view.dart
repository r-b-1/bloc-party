import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:blocparty/model/calander_model.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
        final dataSource = DateScheduled(
      makeAppointments(2, 0, "Test Appointment", "This is a sample note"),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Container(
        child: SfCalendar(
          view: CalendarView.month,
                    dataSource: dataSource,
        ),
      ),
    );
  }
}
