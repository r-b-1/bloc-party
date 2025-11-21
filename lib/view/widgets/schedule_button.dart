import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/model/calander_model.dart'; // your UserAppointment model

class ScheduleButton extends StatelessWidget {
  const ScheduleButton({super.key});

  Future<void> _showScheduleDialog(BuildContext context) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    Color selectedColor = Colors.blue;
    TextEditingController descriptionController = TextEditingController();

    // Pick date
    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 5),
      );
      if (picked != null) {
        selectedDate = picked;
      }
    }

    // Pick time
    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        selectedTime = picked;
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Schedule New Appointment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? 'Pick a Date'
                            : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        await pickDate();
                        setState(() {});
                      },
                    ),
                    ListTile(
                      title: Text(
                        selectedTime == null
                            ? 'Pick a Time'
                            : 'Time: ${selectedTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        await pickTime();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Pick a Color'),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        color: selectedColor,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Select Color'),
                            content: BlockPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please pick date and time'),
                        ),
                      );
                      return;
                    }

                    final startDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    final newAppointment = UserAppointment(
                      startTime: startDateTime,
                      endTime: startDateTime.add(const Duration(hours: 1)),
                      subject: descriptionController.text.trim(),
                      color: selectedColor,
                      notes: descriptionController.text.trim(),
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    );

                    // Save to Firebase
                    await FirebaseFirestore.instance
                        .collection('user_appointment')
                        .add(newAppointment.toFirestore());

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment scheduled!')),
                    );
                  },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Schedule'),
      onPressed: () => _showScheduleDialog(context),
    );
  }
}
