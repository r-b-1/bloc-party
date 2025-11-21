import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:blocparty/model/calander_model.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  @override
  void initState() {
    super.initState();
    scheduleController.addListener(_onViewChange);
  }

  @override
  void dispose() {
    scheduleController.removeListener(_onViewChange);
    super.dispose();
  }

  void _onViewChange() {
    setState(() {}); // UI refresh when model changes
  }

  List<Appointment> getTestAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        startTime: now.add(Duration(hours: 1)),
        endTime: now.add(Duration(hours: 2)),
        subject: "Test Meeting",
        color: Colors.blue,
      ),
      Appointment(
        startTime: now.add(Duration(hours: 3)),
        endTime: now.add(Duration(hours: 4)),
        subject: "Another Event",
        color: Colors.green,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<CalendarView>(
              value: scheduleController.currentView,
              decoration: const InputDecoration(
                labelText: 'Calendar View',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: calendarViews.map((view) {
                return DropdownMenuItem(
                  value: view,
                  child: Text(calendarViewNames[view]!),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  scheduleController.setView(newValue);
                }
              },
              isExpanded: true,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchUserAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Convert Firestore → Syncfusion Appointments
                final appts = convertToCalendarAppointments(snapshot.data!);
                final dataSource = DateScheduled(appts);
                return SfCalendar(
                  key: ValueKey(scheduleController.currentView),
                  view: scheduleController.currentView,
                  dataSource: dataSource,
                  //----------------------
                  appointmentBuilder: (context, details) {
                    final Appointment appt = details.appointments!.first;
                    return buildApptTile(appt);
                  },
                  //----------------------
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.appointment) {
                      final Appointment appt = details.appointments!.first;
                      final TextEditingController controller =
                          TextEditingController(text: appt.notes);
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(appt.subject),
                          content: TextField(
                            controller: controller,
                            maxLines: null, // allows multiline editing
                            decoration: const InputDecoration(
                              hintText: 'Enter notes',
                            ),
                          ),
                          actions: [
                            //--------------------------------
                            // this was to allow users to update the notes they put in the calendar
                            //--------------------------------
                            //  TextButton(
                            //   onPressed: () {

                            //     // Create a new Appointment with updated notes
                            //     final updatedAppt = Appointment(
                            //       startTime: appt.startTime,
                            //       endTime: appt.endTime,
                            //       subject: appt.subject,
                            //       color: appt.color,
                            //       notes: controller.text, // updated notes
                            //     );

                            //     // Replace the old appointment in the data source
                            //     final dataSource = DateScheduled(makeAppointments(6, 0, "Test Appointment", ""));
                            //     final index = dataSource.appointments!.indexOf(appt);
                            //     dataSource.appointments![index] = updatedAppt;
                            //     dataSource.notifyListeners(CalendarDataSourceAction.reset, dataSource.appointments!);
                            //     controller.dispose();
                            //     Navigator.pop(context);
                            //   },
                            //   child: const Text('Save'),
                            // ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildApptTile(Appointment appt) {
  return Container(
    padding: const EdgeInsets.all(4),
    color: appt.color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appt.subject,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          overflow:
              TextOverflow.ellipsis, // ensures long subject won't break layout
        ),
        const SizedBox(height: 2),
        Flexible(
          child: Text(
            appt.notes ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            softWrap: true, // allows text to wrap
            overflow: TextOverflow.fade, // fade if still too long
          ),
        ),
      ],
    ),
  );
}
