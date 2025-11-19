import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:blocparty/model/calander_model.dart';

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
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  // ADD THIS — the selected view
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
          // Dropdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: _calendarSelection(),
          ),
          // Calendar
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

  Widget _calendarSelection() {
    return DropdownButtonFormField<CalendarView>(
     // value: _currentView,
      decoration: const InputDecoration(
        labelText: 'Calendar View',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _views.map((view) {
        return DropdownMenuItem(
          value: view,
          child: Text(_viewNames[view]!),
        );
      }).toList(),
      onChanged: (CalendarView? newValue) {
        if (newValue != null) {
            newValue = CalendarView.week;
            _currentView = newValue ?? _currentView;
        }
      },
      isExpanded: true,
    );
  }
}



