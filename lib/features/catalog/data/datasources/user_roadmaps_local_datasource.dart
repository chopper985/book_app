// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/constants/storage_key.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

typedef UserRoadmapsData = ({List<UserRoadmap> roadmaps, String? activeId});

abstract class UserRoadmapsLocalDataSource {
  UserRoadmapsData read();

  Future<void> write(UserRoadmapsData data);
}

/// One JSON document: `{"active": id, "items": [{trackId, level, addedAt}]}`.
@LazySingleton(as: UserRoadmapsLocalDataSource)
class HiveUserRoadmapsLocalDataSource implements UserRoadmapsLocalDataSource {
  static const String _key = 'data';

  Box<String> get _box => Hive.box<String>(StorageKeys.userRoadmapsBox);

  @override
  UserRoadmapsData read() {
    final raw = _box.get(_key);
    if (raw == null) return (roadmaps: const [], activeId: null);
    try {
      return UserRoadmapsJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Unreadable roadmaps: $error');
      return (roadmaps: const [], activeId: null);
    }
  }

  @override
  Future<void> write(UserRoadmapsData data) =>
      _box.put(_key, jsonEncode(UserRoadmapsJson.toJson(data)));
}

class UserRoadmapsJson {
  const UserRoadmapsJson._();

  static Map<String, dynamic> toJson(UserRoadmapsData data) => {
        if (data.activeId != null) 'active': data.activeId,
        'items': [
          for (final roadmap in data.roadmaps)
            {
              'trackId': roadmap.trackId,
              'level': roadmap.level.name,
              'addedAt': roadmap.addedAt.toUtc().millisecondsSinceEpoch,
              if (roadmap.positionId != null) 'positionId': roadmap.positionId,
              if (roadmap.optionId != null) 'optionId': roadmap.optionId,
            },
        ],
      };

  /// Unknown levels (from a newer app version) are skipped.
  static UserRoadmapsData fromJson(Map<String, dynamic> json) {
    final roadmaps = <UserRoadmap>[];
    for (final item in (json['items'] as List).cast<Map>()) {
      final level = QuestionLevel.values
          .where((value) => value.name == item['level'])
          .firstOrNull;
      if (level == null) continue;
      roadmaps.add(
        UserRoadmap(
          trackId: item['trackId'] as String,
          level: level,
          addedAt: DateTime.fromMillisecondsSinceEpoch(
            item['addedAt'] as int,
            isUtc: true,
          ).toLocal(),
          positionId: item['positionId'] as String?,
          optionId: item['optionId'] as String?,
        ),
      );
    }
    return (roadmaps: roadmaps, activeId: json['active'] as String?);
  }
}
