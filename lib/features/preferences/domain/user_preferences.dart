/// Domain model for user preferences that affect the AI Trip Assistant output.
class UserPreferences {
  const UserPreferences({
    required this.userId,
    this.travelStyle,
    this.interests = const [],
    this.pace,
    this.budgetDailyLimit,
    this.avoid = const [],
  });

  final String userId;

  /// e.g. 'budget', 'mid', 'luxury'
  final String? travelStyle;

  /// e.g. ['kuliner', 'alam', 'museum']
  final List<String> interests;

  /// e.g. 'slow', 'normal', 'fast'
  final String? pace;

  /// Daily budget cap in IDR (or user currency).
  final int? budgetDailyLimit;

  /// Things to avoid e.g. ['spicy', 'crowds']
  final List<String> avoid;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'travel_style': travelStyle,
        'interests': interests,
        'pace': pace,
        'budget_daily_limit': budgetDailyLimit,
        'avoid': avoid,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: (json['user_id'] as String?) ?? '',
      travelStyle: json['travel_style'] as String?,
      interests: ((json['interests'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      pace: json['pace'] as String?,
      budgetDailyLimit: (json['budget_daily_limit'] as num?)?.toInt(),
      avoid:
          ((json['avoid'] as List?) ?? []).map((e) => e.toString()).toList(),
    );
  }

  UserPreferences copyWith({
    String? travelStyle,
    List<String>? interests,
    String? pace,
    int? budgetDailyLimit,
    List<String>? avoid,
  }) {
    return UserPreferences(
      userId: userId,
      travelStyle: travelStyle ?? this.travelStyle,
      interests: interests ?? this.interests,
      pace: pace ?? this.pace,
      budgetDailyLimit: budgetDailyLimit ?? this.budgetDailyLimit,
      avoid: avoid ?? this.avoid,
    );
  }
}
