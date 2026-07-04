import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/providers/game_provider.dart';
import 'package:habit_tracker/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'local_player_state': jsonEncode({
        'playerName': 'Shiva',
        'playerClass': 'Self Improver',
        'characterLevel': 8,
        'characterXp': 2350.0,
        'isSoundEnabled': true,
        'activeThemeIndex': 0,
        'totalXpEarned': 2350,
        'questsCompletedCount': 0,
        'punishmentsResolvedCount': 0,
        'longestStreak': 0,
        'totalDaysPlayed': 1,
        'consecutiveCleanDays': 0,
        'lastResetDate': DateTime.now().toIso8601String(),
      })
    });
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
      provider.incrementStrengthTrainingGoal('squats', 100);
      provider.incrementStrengthTrainingGoal('running', 5.0); // Needs 10.0

      expect(quest.isCompleted, isFalse);

      // Complete last target
      provider.incrementStrengthTrainingGoal('running', 5.0);

      expect(quest.isCompleted, isTrue);
    });

    test('Verify Difficulty Levels map to correct XP rewards', () async {
      final provider = GameProvider();
      await provider.initialization;

      provider.addCustomQuest(
        title: 'Learn Advanced Rust Programming',
        description: 'Read 3 chapters of Rust Book.',
        selectedStat: StatType.intelligence,
        difficulty: QuestDifficulty.hard,
        type: QuestType.custom,
      );

      final custom = provider.quests.firstWhere((q) => q.title == 'Learn Advanced Rust Programming');
      expect(custom.rewards[StatType.intelligence], equals(QuestDifficulty.hard.xpReward));
    });

    test('Verify Equipment XP Multiplier boosts gains', () async {
      final provider = GameProvider();
      await provider.initialization;

      // Equip book (+10% Intel)
      provider.toggleEquipment('scholars_book');

      provider.addCustomQuest(
        title: 'Read Article',
        description: 'Read a tech post.',
        selectedStat: StatType.intelligence,
        difficulty: QuestDifficulty.easy,
        type: QuestType.custom,
      );

      final initialIntelLvl = provider.stats[StatType.intelligence]!.level;
      final initialIntelXp = provider.stats[StatType.intelligence]!.xp;

      provider.completeQuest(provider.quests.firstWhere((q) => q.title == 'Read Article').id);

      final finalIntelXp = provider.stats[StatType.intelligence]!.xp;
      // Expect 1.1x boost (10.0 * 1.1 = 11.0)
      expect(finalIntelXp - initialIntelXp, equals(11.0));
    });

    test('Verify Achievement System Unlocks', () async {
      final provider = GameProvider();
      await provider.initialization;

      final firstQuestAchievement = provider.achievements.firstWhere((a) => a.id == 'first_quest');
      expect(firstQuestAchievement.isUnlocked, isFalse);

      provider.addCustomQuest(
        title: 'Simple Task',
        description: 'Test task',
        selectedStat: StatType.discipline,
        difficulty: QuestDifficulty.easy,
        type: QuestType.custom,
      );

      provider.completeQuest(provider.quests.firstWhere((q) => q.title == 'Simple Task').id);

      expect(firstQuestAchievement.isUnlocked, isTrue);
    });

    test('Verify Contribution Graph Log on Reset', () async {
      final provider = GameProvider();
      await provider.initialization;

      final todayStr = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      expect(provider.contributionHistory.containsKey(todayStr), isFalse);

      // Force a rollover
      provider.performDailyReset();

      expect(provider.contributionHistory.containsKey(todayStr), isTrue);
      // Strength training was not checked off, so failed status logged
      expect(provider.contributionHistory[todayStr], equals('failed'));
    });
  });
}
