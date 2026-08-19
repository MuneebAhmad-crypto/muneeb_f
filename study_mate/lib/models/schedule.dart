import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final String courseId;
  final String dayOfWeek; // 'Monday', 'Tuesday', etc.
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? room;
  final String? courseName;
  final String? courseCode;

  Schedule({
    required this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.courseName,
    this.courseCode,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      courseId: json['course_id'],
      dayOfWeek: json['day_of_week'],
      startTime: _parseTime(json['start_time']),
      endTime: _parseTime(json['end_time']),
      room: json['room'],
      courseName: json['sm_courses']?['name'],
      courseCode: json['sm_courses']?['code'],
    );
  }

  static TimeOfDay _parseTime(String time) {
    // Handle both HH:mm and HH:mm:ss formats
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'day_of_week': dayOfWeek,
      'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'room': room,
    };
  }
}
