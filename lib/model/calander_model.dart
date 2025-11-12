import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

List<Appointment> makeAppointments(int hours, int days) {
  List<Appointment> date = <Appointment>[];
  final DateTime day = DateTime.now();
  final DateTime startTime = DateTime(day.year, day.month, day.day, 9,0,0);
  DateTime endTime = startTime.add(Duration(
    days: days,
    hours: hours,
    ));


  date.add(Appointment(
    startTime: startTime,
     endTime: endTime,
     subject: '',
     color: Colors.blue,
     ));

     return date;
}

class DateScheduled extends CalendarDataSource {
  DateScheduled(List<Appointment> source){
    appointments = source;
  }
}