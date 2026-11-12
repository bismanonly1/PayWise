class WorkShift {
  final DateTime date;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int unpaidBreakMinutes;
  final double hourlyRate;

  const WorkShift({
    required this.date,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.unpaidBreakMinutes,
    required this.hourlyRate,
  });
  
}
