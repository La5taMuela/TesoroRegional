import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part 'content_database.g.dart';

@HiveType(typeId: 0)
class LocalizedContent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, String> title;

  @HiveField(2)
  final Map<String, String> description;

  @HiveField(3)
  final Map<String, String> content;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final DateTime lastUpdated;

  @HiveField(6)
  final DateTime lastAccessed;

  LocalizedContent({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.lastUpdated,
    required this.lastAccessed,
  });

  String getTitle(String languageCode) {
    return title[languageCode] ?? title['es'] ?? id;
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['es'] ?? '';
  }

  String getContent(String languageCode) {
    return content[languageCode] ?? content['es'] ?? '';
  }
}

class ContentDatabase {
  static const String _storiesBoxName = 'stories';
  static const String _missionsBoxName = 'missions';

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    Hive.registerAdapter(LocalizedContentAdapter());

    await Hive.openBox<LocalizedContent>(_storiesBoxName);
    await Hive.openBox<LocalizedContent>(_missionsBoxName);
  }

  static Box<LocalizedContent> get storiesBox => Hive.box<LocalizedContent>(_storiesBoxName);
  static Box<LocalizedContent> get missionsBox => Hive.box<LocalizedContent>(_missionsBoxName);

  static Future<void> saveStory(LocalizedContent story) async {
    await storiesBox.put(story.id, story);
  }

  static Future<void> saveMission(LocalizedContent mission) async {
    await missionsBox.put(mission.id, mission);
  }

  static List<LocalizedContent> getStories() {
    return storiesBox.values.toList();
  }

  static List<LocalizedContent> getMissions() {
    return missionsBox.values.toList();
  }

  static Future<void> updateLastAccessed(String id, String boxName) async {
    final box = boxName == 'stories' ? storiesBox : missionsBox;
    final content = box.get(id);
    if (content != null) {
      final updated = LocalizedContent(
        id: content.id,
        title: content.title,
        description: content.description,
        content: content.content,
        category: content.category,
        lastUpdated: content.lastUpdated,
        lastAccessed: DateTime.now(),
      );
      await box.put(id, updated);
    }
  }

  static Future<void> cleanOldContent() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

    // Clean old stories
    final storiesToDelete = storiesBox.values
        .where((story) => story.lastAccessed.isBefore(cutoffDate))
        .map((story) => story.id)
        .toList();

    for (final id in storiesToDelete) {
      await storiesBox.delete(id);
    }

    // Clean old missions
    final missionsToDelete = missionsBox.values
        .where((mission) => mission.lastAccessed.isBefore(cutoffDate))
        .map((mission) => mission.id)
        .toList();

    for (final id in missionsToDelete) {
      await missionsBox.delete(id);
    }
  }
}
