import '../../domain/entities/post.dart';
import '../../domain/entities/post_location.dart';
import 'post_location_dto.dart';

class PostDTO extends Post {
  const PostDTO({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.location,
    required super.images,
    super.videos = const [],
    required super.createdAt,
    required super.updatedAt,
    super.likes = 0,
    super.tags = const [],
    super.userName,
    super.alias,
    super.userProfileImage,
  });

  factory PostDTO.fromMap(Map<String, dynamic> map) {
    return PostDTO(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      location: PostLocationDTO.fromMap(map['location'] as Map<String, dynamic>? ?? {}),
      images: List<String>.from(map['images'] as List<dynamic>? ?? []),
      videos: List<String>.from(map['videos'] as List<dynamic>? ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      likes: map['likes'] as int? ?? 0,
      tags: List<String>.from(map['tags'] as List<dynamic>? ?? []),
      userName: map['userName'] as String?,
      alias: map['alias'] as String?,
      userProfileImage: map['userProfileImage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'location': location.toMap(),
      'images': images,
      'videos': videos,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likes': likes,
      'tags': tags,
      'userName': userName,
      'alias': alias,
      'userProfileImage': userProfileImage,
    };
  }

  Post toEntity() {
    return Post(
      id: id,
      userId: userId,
      title: title,
      content: content,
      location: location,
      images: images,
      videos: videos,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likes: likes,
      tags: tags,
      userName: userName,
      alias: alias,
      userProfileImage: userProfileImage,
    );
  }
}
