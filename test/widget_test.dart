import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/providers/game_provider.dart';
import 'package:habit_tracker/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SYSTEM Solo Leveling Quest Unit Tests', () {
    test('Verify Shiva Profile Initial State', () async {
      final provider = GameProvider();
      await provider.initialization;

      expect(provider.playerName, equals('Shiva'));
      expect(provider.playerClass, equals('Self Improver'));
      expect(provider.characterLevel, equals(8));
      expect(provider.characterXp, equals(2350.0));
      expect(provider.playerRank, equals('Disciplined'));
      expect(provider.playerTitle, equals('Warrior'));
    });

    test('Verify Daily Strength Training Sub-goal Increments', () async {
      final provider = GameProvider();
      await provider.initialization;

      // Find the daily workout quest
      final quest = provider.quests.firstWhere((q) => q.id == 'default_strength_training');
      expect(quest.pushupsProgress, equals(0));
      expect(quest.runningProgress, equals(0.0));

      // Increment pushups and running
      provider.incrementStrengthTrainingGoal('pushups', 30);
      provider.incrementStrengthTrainingGoal('running', 2.0);

      expect(quest.pushupsProgress, equals(30));
      expect(quest.runningProgress, equals(2.0));
    });

    test('Verify Strength Training Completes Only on Reaching All Targets', () async {
      final provider = GameProvider();
      await provider.initialization;

      final quest = provider.quests.firstWhere((q) => q.id == 'default_strength_training');
      expect(quest.isCompleted, isFalse);

      // Increment some, not all
      provider.incrementStrengthTrainingGoal('pushups', 100);
      provider.incrementStrengthTrainingGoal('situps', 100);
      provider.incrementStrengthTrainingGoal('squats', 80); // Squats incomplete
      provider.incrementStrengthTrainingGoal('running', 10.0);

      expect(quest.isCompleted, isFalse);

      // Complete last squats goal
      provider.incrementStrengthTrainingGoal('squats', 20);

      // Quest should now auto-complete
      expect(quest.isCompleted, isTrue);
      expect(quest.pushupsProgress, equals(100));
      expect(quest.squatsProgress, equals(100));
    });

    test('Verify Difficulty Levels map to correct XP rewards', () async {
      final provider = GameProvider();
      await provider.initialization;

      provider.addCustomQuest(
        title: 'Learn Advanced Rust Programming',
        description: 'Read Chapter 12 of Rust Book',
        selectedStat: StatType.intelligence,
        difficulty: QuestDifficulty.legendary,
        type: QuestType.custom,
      );

      final customQuest = provider.customQuests.first;
      expect(customQuest.rewards[StatType.intelligence], equals(100.0));
      expect(customQuest.rewards[StatType.discipline], equals(20.0));
    });

    test('Verify Equipment XP Multiplier boosts gains', () async {
      final provider = GameProvider();
      await provider.initialization;

      final initialIntelligenceXp = provider.stats[StatType.intelligence]!.xp;

      provider.toggleEquipment('scholars_book');

      provider.addCustomQuest(
        title: 'Read Article',
        description: 'Deep learning introduction',
        selectedStat: StatType.intelligence,
        difficulty: QuestDifficulty.medium,
        type: QuestType.custom,
      );

      final qId = provider.customQuests.first.id;
      provider.completeQuest(qId);

      final finalIntelligenceXp = provider.stats[StatType.intelligence]!.xp;
      expect(finalIntelligenceXp - initialIntelligenceXp, closeTo(27.5, 0.0001));
    });

    test('Verify Achievement System Unlocks', () async {
      final provider = GameProvider();
      await provider.initialization;

      expect(provider.achievements.firstWhere((a) => a.id == 'first_quest').isUnlocked, isFalse);

      // Complete the main Strength Training quest to unlock
      provider.completeQuest('default_strength_training');

      expect(provider.achievements.firstWhere((a) => a.id == 'first_quest').isUnlocked, isTrue);
    });

    test('Verify Contribution Graph Log on Reset', () async {
      final provider = GameProvider();
      await provider.initialization;

      expect(provider.contributionHistory, isEmpty);

      provider.performDailyReset();

      expect(provider.contributionHistory.isNotEmpty, isTrue);
      final status = provider.contributionHistory.values.first;
      expect(status, equals('failed'));
    });
  });
}
