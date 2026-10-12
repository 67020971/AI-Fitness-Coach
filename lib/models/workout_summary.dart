class WorkoutSummary {
  const WorkoutSummary({
    required this.totalReps,
    required this.correctReps,
    required this.completedAt,
    required this.durationSeconds,
  });

  final int totalReps;
  final int correctReps;
  final DateTime completedAt;
  final int durationSeconds;

  int get incorrectReps => totalReps - correctReps;

  int get accuracyPercent =>
      totalReps == 0 ? 0 : (correctReps * 100 / totalReps).round();

  Map<String, Object> toJson() => {
        'totalReps': totalReps,
        'correctReps': correctReps,
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSummary(
      totalReps: json['totalReps'] as int? ?? 0,
      correctReps: json['correctReps'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }
}