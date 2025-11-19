import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

List<Appointment> makeAppointments(int hours, int days, String sub, String notes) {
  List<Appointment> date = <Appointment>[];
  final DateTime day = DateTime.now();
  final DateTime startTime = DateTime(day.year, day.month, day.day, 9, 0, 0);
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

// If you want these to be shared app-wide, keep them top-level.
// Otherwise you can move them into the State class.
final List<CalendarView> _views = [
  CalendarView.month,
  CalendarView.week,
  CalendarView.day,
];

final Map<CalendarView, String> _viewNames = {
  CalendarView.month: "Month",
  CalendarView.week: "Week",
  CalendarView.day: "Day",
};

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  // Local state for the currently selected view
  CalendarView _currentView = CalendarView.month;

  @override
  Widget build(BuildContext context) {
    final dataSource = DateScheduled(
      makeAppointments(2, 0, "Test Appointment", "This is a sample note"),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: Column(
        children: [
          // Padding around dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _calendarSelection(),
          ),

          // Calendar fills the rest of the screen
          Expanded(
            child: SfCalendar(
              view: _currentView,
              dataSource: dataSource,
            ),
          ),
        ],
      ),
    );
  }

  // Private widget so it can call setState()
  Widget _calendarSelection() {
    return DropdownButtonFormField<CalendarView>(
      value: _currentView,
      decoration: const InputDecoration(
        labelText: 'Calendar View',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _views.map((view) {
        return DropdownMenuItem<CalendarView>(
          value: view,
          child: Text(_viewNames[view] ?? view.toString()),
        );
      }).toList(),
      onChanged: (CalendarView? newValue) {
        if (newValue != null) {
          setState(() {
            _currentView = newValue;
          });
        }
      },
      isExpanded: true,
    );
  }
}