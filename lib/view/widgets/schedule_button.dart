import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/model/calander_model.dart'; // your UserAppointment model

class ScheduleButton extends StatelessWidget {
  const ScheduleButton({super.key});

  Future<void> _showScheduleDialog(BuildContext context) async {
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    Color selectedColor = Colors.blue;
    TextEditingController descriptionController = TextEditingController();

    // Pick date
    Future<DateTime?> pickDate() async {
      final now = DateTime.now();
      return await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 5),
      );
    }

    // Pick time
    Future<TimeOfDay?> pickTime() async {
      return await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
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
                        selectedStartDate == null
                            ? 'Pick start Date'
                            : '${selectedStartDate!.toLocal()}'.split(' ')[0],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await pickDate();
                        if (picked!=null){
                        setState(() {
                          selectedStartDate = picked;
                        });
                       }
                      },
                    ),
                    ListTile(
                      title: Text(
                        selectedStartTime == null
                            ? 'Pick start Time'
                            : '${selectedStartTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await pickTime();
                        if (picked!=null){
                        setState(() {
                          selectedStartTime = picked;
                        });
                      
                        }
                      },
                    ),
                       ListTile(
                      title: Text(
                        selectedEndDate == null
                            ? 'Pick end Date'
                            : '${selectedStartDate!.toLocal()}'.split(' ')[0],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await pickDate();
                        if (picked!=null){
                        setState(() {
                          selectedEndDate = picked;
                        });
                        
                        }
                      },
                    ),
                    ListTile(
                       title: Text(
                        selectedEndTime == null
                            ? 'Pick end Time'
                            : '${selectedEndTime!.format(context)}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await pickTime();
                        if (picked!=null){
                        setState(() {
                          selectedEndTime = picked;
                        });
                        
                        }
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
                    if (selectedStartDate == null || selectedStartTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please pick date and time'),
                        ),
                      );
                      return;
                    }

                    final startDateTime = DateTime(
                      selectedStartDate!.year,
                      selectedStartDate!.month,
                      selectedStartDate!.day,
                      selectedStartTime!.hour,
                      selectedStartTime!.minute,
                    );

                    final endDateTime = DateTime(
                      selectedEndDate!.year,
                      selectedEndDate!.month,
                      selectedEndDate!.day,
                      selectedEndTime!.hour,
                      selectedEndTime!.minute,
                    );


                    final newAppointment = UserAppointment(
                      startTime: startDateTime,
                      endTime: endDateTime,
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
      onPressed: ()  {
        _showScheduleDialog(context);
      } 
    );
  }
}
