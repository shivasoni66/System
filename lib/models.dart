enum StatType {
  stamina,
  strength,
  immunity,
  intelligence,
  discipline,
}

extension StatTypeExtension on StatType {
  String get name {
    switch (this) {
      case StatType.stamina:
        return 'Stamina';
      case StatType.strength:
        return 'Strength';
      case StatType.immunity:
        return 'Immunity';
      case StatType.intelligence:
        return 'Intelligence';
      case StatType.discipline:
        return 'Discipline';
    }
  }

  String get description {
    switch (this) {
      case StatType.stamina:
        return 'Builds cardiovascular endurance and physical energy.';
      case StatType.strength:
        return 'Builds muscle, power, and physical capability.';
      case StatType.immunity:
        return 'Represents physical health, hydration, and recovery.';
      case StatType.intelligence:
        return 'Builds focus, knowledge, and mental capacity.';
      case StatType.discipline:
        return 'Represents consistency, willpower, and overall progress.';
    }
  }
}

class Stat {
  final StatType type;
  int level;
  double xp;

  Stat({
    required this.type,
    this.level = 1,
    this.xp = 0.0,
  });

  double get nextLevelXp => level * 100.0;

  /// Adds XP to the stat. Returns true if the stat leveled up.
  bool addXp(double amount) {
    xp += amount;
    bool leveledUp = false;
    while (xp >= nextLevelXp) {
      xp -= nextLevelXp;
      level++;
      leveledUp = true;
    }
    return leveledUp;
  }

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'level': level,
        'xp': xp,
      };

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      type: StatType.values[json['type'] as int],
      level: json['level'] as int? ?? 1,
      xp: (json['xp'] as num? ?? 0.0).toDouble(),
    );
  }
}

enum QuestType {
  daily,
  custom,
  weekly,
  monthly,
}

enum QuestDifficulty {
  easy,
  medium,
  hard,
  legendary,
}

extension QuestDifficultyExtension on QuestDifficulty {
  String get name {
    switch (this) {
      case QuestDifficulty.easy:
        return 'Easy';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.hard:
        return 'Hard';
      case QuestDifficulty.legendary:
        return 'Legendary';
    }
  }

  double get xpReward {
    switch (this) {
      case QuestDifficulty.easy:
        return 10.0;
      case QuestDifficulty.medium:
        return 25.0;
      case QuestDifficulty.hard:
        return 50.0;
      case QuestDifficulty.legendary:
        return 100.0;
    }
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final Map<StatType, double> rewards;
  bool isCompleted;
  DateTime? completedAt;
  final DateTime createdAt;
  bool isPunishmentTriggered;
  
  // Streak System & Boss System Extensions
  int streak;
  final bool isBoss;
  final String? badgeReward;

  // Solo Leveling Strength Training Sub-goals
  int? pushupsProgress;
  int? situpsProgress;
  int? squatsProgress;
  double? runningProgress;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.difficulty = QuestDifficulty.medium,
    required this.rewards,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.isPunishmentTriggered = false,
    this.streak = 0,
    this.isBoss = false,
    this.badgeReward,
    this.pushupsProgress,
    this.situpsProgress,
    this.squatsProgress,
    this.runningProgress,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.index,
        'difficulty': difficulty.index,
        'rewards': rewards.map((k, v) => MapEntry(k.index.toString(), v)),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'isPunishmentTriggered': isPunishmentTriggered,
        'streak': streak,
        'isBoss': isBoss,
        'badgeReward': badgeReward,
        'pushupsProgress': pushupsProgress,
        'situpsProgress': situpsProgress,
        'squatsProgress': squatsProgress,
        'runningProgress': runningProgress,
      };

  factory Quest.fromJson(Map<String, dynamic> json) {
    final rawRewards = json['rewards'] as Map<String, dynamic>? ?? {};
    final Map<StatType, double> parsedRewards = {};
    rawRewards.forEach((k, v) {
      final statIdx = int.tryParse(k);
      if (statIdx != null && statIdx < StatType.values.length) {
        parsedRewards[StatType.values[statIdx]] = (v as num).toDouble();
      }
    });

    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      type: QuestType.values[json['type'] as int],
      difficulty: QuestDifficulty.values[json['difficulty'] as int? ?? QuestDifficulty.medium.index],
      rewards: parsedRewards,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isPunishmentTriggered: json['isPunishmentTriggered'] as bool? ?? false,
      streak: json['streak'] as int? ?? 0,
      isBoss: json['isBoss'] as bool? ?? false,
      badgeReward: json['badgeReward'] as String?,
      pushupsProgress: json['pushupsProgress'] as int?,
      situpsProgress: json['situpsProgress'] as int?,
      squatsProgress: json['squatsProgress'] as int?,
      runningProgress: (json['runningProgress'] as num?)?.toDouble(),
    );
  }
}

class Punishment {
  final String id;
  final String title;
  final String description;
  final double penaltyXp; // Overall character XP penalty if failed
  bool isCleared;
  final DateTime createdAt;

  Punishment({
    required this.id,
    required this.title,
    required this.description,
    required this.penaltyXp,
    this.isCleared = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'penaltyXp': penaltyXp,
        'isCleared': isCleared,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Punishment.fromJson(Map<String, dynamic> json) {
    return Punishment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      penaltyXp: (json['penaltyXp'] as num? ?? 0.0).toDouble(),
      isCleared: json['isCleared'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class NotificationAlert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationAlert.fromJson(Map<String, dynamic> json) {
    return NotificationAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class Equipment {
  final String id;
  final String name;
  final String description;
  final String statBonusDescription;
  final int unlockedLevel;
  bool isEquipped;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.statBonusDescription,
    required this.unlockedLevel,
    this.isEquipped = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'statBonusDescription': statBonusDescription,
        'unlockedLevel': unlockedLevel,
        'isEquipped': isEquipped,
      };

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      statBonusDescription: json['statBonusDescription'] as String,
      unlockedLevel: json['unlockedLevel'] as int,
      isEquipped: json['isEquipped'] as bool? ?? false,
    );
  }
}
