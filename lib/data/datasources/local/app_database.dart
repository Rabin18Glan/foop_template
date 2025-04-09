import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../models/post_model.dart';
import '../../../core/error/exceptions.dart';

class AppDatabase {
  static const String postsBoxName = 'posts_box';
  static const String pendingActionsBoxName = 'pending_actions_box';
  
  // Register all Hive adapters
  static Future<void> registerAdapters() async {
    Hive.registerAdapter(PostModelAdapter());
    Hive.registerAdapter(PendingActionAdapter());
    
    await Hive.openBox<PostModel>(postsBoxName);
    await Hive.openBox<PendingAction>(pendingActionsBoxName);
  }
  
  // Posts methods
  Future<List<PostModel>> getPosts() async {
    try {
      final box = Hive.box<PostModel>(postsBoxName);
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get posts from local storage');
    }
  }
  
  Future<PostModel?> getPostById(int id) async {
    try {
      final box = Hive.box<PostModel>(postsBoxName);
      return box.values.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> savePosts(List<PostModel> posts) async {
    try {
      final box = Hive.box<PostModel>(postsBoxName);
      
      // Create a map of id -> post for batch saving
      final Map<dynamic, PostModel> postsMap = {};
      for (var post in posts) {
        postsMap[post.id] = post;
      }
      
      await box.putAll(postsMap);
    } catch (e) {
      throw CacheException(message: 'Failed to save posts to local storage');
    }
  }
  
  Future<PostModel> savePost(PostModel post) async {
    try {
      final box = Hive.box<PostModel>(postsBoxName);
      await box.put(post.id, post);
      return post;
    } catch (e) {
      throw CacheException(message: 'Failed to save post to local storage');
    }
  }
  
  Future<PostModel> createLocalPost(PostModel post) async {
    try {
      final box = Hive.box<PostModel>(postsBoxName);
      final localId = const Uuid().v4();
      
      // Create a temporary negative ID to avoid conflicts with server IDs
      final localPost = post.copyWith(
        id: -DateTime.now().millisecondsSinceEpoch,
        isSynced: false,
        localId: localId,
      );
      
      await box.put(localPost.id, localPost);
      
      // Add pending action
      await addPendingAction(
        PendingAction(
          id: localId,
          actionType: ActionType.create,
          data: localPost.toJson(),
          timestamp: DateTime.now(),
        ),
      );
      
      return localPost;
    } catch (e) {
      throw CacheException(message: 'Failed to create local post');
    }
  }
  
  Future<bool> deletePost(int id) async {
    try {
      final box = Hive.box<PostModel>(postsBoxName);
      await box.delete(id);
      return true;
    } catch (e) {
      throw CacheException(message: 'Failed to delete post from local storage');
    }
  }
  
  // Pending actions methods
  Future<void> addPendingAction(PendingAction action) async {
    try {
      final box = Hive.box<PendingAction>(pendingActionsBoxName);
      await box.put(action.id, action);
    } catch (e) {
      throw CacheException(message: 'Failed to add pending action');
    }
  }
  
  Future<List<PendingAction>> getPendingActions() async {
    try {
      final box = Hive.box<PendingAction>(pendingActionsBoxName);
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get pending actions');
    }
  }
  
  Future<void> removePendingAction(String id) async {
    try {
      final box = Hive.box<PendingAction>(pendingActionsBoxName);
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to remove pending action');
    }
  }
  
  Future<void> clearAllData() async {
    try {
      final postsBox = Hive.box<PostModel>(postsBoxName);
      final pendingActionsBox = Hive.box<PendingAction>(pendingActionsBoxName);
      
      await postsBox.clear();
      await pendingActionsBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear all data');
    }
  }
}

// Pending action model for tracking offline changes
@HiveType(typeId: 1)
class PendingAction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final ActionType actionType;
  
  @HiveField(2)
  final Map<String, dynamic> data;
  
  @HiveField(3)
  final DateTime timestamp;
  
  PendingAction({
    required this.id,
    required this.actionType,
    required this.data,
    required this.timestamp,
  });
}

@HiveType(typeId: 2)
enum ActionType {
  @HiveField(0)
  create,
  
  @HiveField(1)
  update,
  
  @HiveField(2)
  delete,
}

class PendingActionAdapter extends TypeAdapter<PendingAction> {
  @override
  final int typeId = 1;

  @override
  PendingAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingAction(
      id: fields[0] as String,
      actionType: fields[1] as ActionType,
      data: fields[2] as Map<String, dynamic>,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingAction obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.actionType)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.timestamp);
  }
}

class ActionTypeAdapter extends TypeAdapter<ActionType> {
  @override
  final int typeId = 2;

  @override
  ActionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActionType.create;
      case 1:
        return ActionType.update;
      case 2:
        return ActionType.delete;
      default:
        return ActionType.create;
    }
  }

  @override
  void write(BinaryWriter writer, ActionType obj) {
    switch (obj) {
      case ActionType.create:
        writer.writeByte(0);
        break;
      case ActionType.update:
        writer.writeByte(1);
        break;
      case ActionType.delete:
        writer.writeByte(2);
        break;
    }
  }
}
