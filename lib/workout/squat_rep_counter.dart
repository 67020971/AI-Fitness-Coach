import 'squat_analyzer.dart';

class RepEvent {
  const RepEvent({required this.isCorrect});

  final bool isCorrect;
}

class SquatRepCounter {
  int totalReps = 0;
  int correctReps = 0;
  bool _startedDescent = false;
  bool _reachedGoodDepth = false;

  RepEvent? update(SquatAssessment assessment) {
    if (assessment.phase == SquatPhase.unavailable) {
      _startedDescent = false;
      _reachedGoodDepth = false;
      return null;
    }

    if (assessment.phase == SquatPhase.down) {
      _startedDescent = true;
    }
    if (_startedDescent && assessment.goodDepth) {
      _reachedGoodDepth = true;
    }

    if (assessment.phase != SquatPhase.up || !_startedDescent) return null;

    final isCorrect = _reachedGoodDepth;
    totalReps++;
    if (isCorrect) correctReps++;
    _startedDescent = false;
    _reachedGoodDepth = false;
    return RepEvent(isCorrect: isCorrect);
  }

  void reset() {
    totalReps = 0;
    correctReps = 0;
    _startedDescent = false;
    _reachedGoodDepth = false;
  }
}