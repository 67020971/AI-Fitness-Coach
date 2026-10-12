import 'package:flutter_test/flutter_test.dart';
import 'package:ai_fitness_coach/workout/squat_analyzer.dart';
import 'package:ai_fitness_coach/workout/squat_rep_counter.dart';

void main() {
  group('SquatRepCounter', () {
    test('counts one correct rep only after down then up', () {
      final counter = SquatRepCounter();

      expect(counter.update(_assessment(SquatPhase.down, 95, true)), isNull);
      expect(counter.update(_assessment(SquatPhase.up, 170, false))?.isCorrect, true);
      expect(counter.totalReps, 1);
      expect(counter.correctReps, 1);
      expect(counter.update(_assessment(SquatPhase.up, 170, false)), isNull);
      expect(counter.totalReps, 1);
    });

    test('does not count a shallow squat that never reaches down', () {
      final counter = SquatRepCounter();

      counter.update(_assessment(SquatPhase.transition, 130, false));
      expect(counter.update(_assessment(SquatPhase.up, 170, false)), isNull);
      expect(counter.totalReps, 0);
      expect(counter.correctReps, 0);
    });

    test('counts an excessively deep squat as incorrect', () {
      final counter = SquatRepCounter();

      counter.update(_assessment(SquatPhase.down, 55, false));
      expect(counter.update(_assessment(SquatPhase.up, 170, false))?.isCorrect, false);
      expect(counter.totalReps, 1);
      expect(counter.correctReps, 0);
    });

    test('does not count a descent until the user returns to up', () {
      final counter = SquatRepCounter();

      counter.update(_assessment(SquatPhase.down, 95, true));
      expect(counter.totalReps, 0);
    });

    test('discards an interrupted descent when pose becomes unavailable', () {
      final counter = SquatRepCounter();

      counter.update(_assessment(SquatPhase.down, 95, true));
      counter.update(_assessment(SquatPhase.unavailable, 0, false));

      expect(counter.update(_assessment(SquatPhase.up, 170, false)), isNull);
      expect(counter.totalReps, 0);
      expect(counter.correctReps, 0);
    });

    test('counts each completed down-up cycle once', () {
      final counter = SquatRepCounter();

      for (var rep = 0; rep < 2; rep++) {
        counter.update(_assessment(SquatPhase.down, 95, true));
        expect(
          counter.update(_assessment(SquatPhase.up, 170, false))?.isCorrect,
          isTrue,
        );
        expect(counter.update(_assessment(SquatPhase.up, 170, false)), isNull);
      }

      expect(counter.totalReps, 2);
      expect(counter.correctReps, 2);
    });
  });
}

SquatAssessment _assessment(SquatPhase phase, double angle, bool goodDepth) {
  return SquatAssessment(
    phase: phase,
    kneeAngle: angle,
    feedback: '',
    hasFullBody: true,
    goodDepth: goodDepth,
  );
}