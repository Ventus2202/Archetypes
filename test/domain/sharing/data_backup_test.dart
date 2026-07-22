import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:archetypes/data/database/app_database.dart';
import 'package:archetypes/domain/sharing/data_backup.dart';

void main() {
  group('BackupData serialization', () {
    test('profile shareId survives a toJson/fromJson round-trip', () {
      final backup = BackupData(
        persons: const [],
        profiles: [
          PersonalityProfileEntry(
            id: 1,
            personId: 1,
            system: 'mbti',
            dataJson: '{"type":"intj"}',
            confidence: 90,
            source: 'manual',
            updatedAt: DateTime.parse('2026-07-22T10:00:00.000'),
            shareId: 'a1b2c3d4e5f6a7b8c9',
          ),
        ],
        relationships: const [],
        groups: const [],
        personGroups: const [],
        events: const [],
        schemaVersion: 2,
      );

      // Full JSON encode/decode to mimic the real ZIP write/read path.
      final restored = BackupData.fromJson(
        jsonDecode(jsonEncode(backup.toJson())) as Map<String, dynamic>,
      );

      expect(restored.profiles.single.shareId, 'a1b2c3d4e5f6a7b8c9');
    });

    test('older backup without a shareId key decodes as null', () {
      final restored = BackupData.fromJson({
        'persons': const [],
        'profiles': [
          {
            'id': 1,
            'personId': 1,
            'system': 'mbti',
            'dataJson': '{}',
            'confidence': 80,
            'source': 'manual',
            'updatedAt': '2026-07-22T10:00:00.000',
            // no 'shareId' key: pre-fix backup format
          },
        ],
        'relationships': const [],
        'groups': const [],
        'personGroups': const [],
        'events': const [],
        'schemaVersion': 2,
      });

      expect(restored.profiles.single.shareId, isNull);
    });
  });
}
