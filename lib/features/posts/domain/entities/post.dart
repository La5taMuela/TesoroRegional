import 'package:equatable/equatable.dart';
import 'post_location.dart';

class Post extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final PostLocation location;
  final List<String> images;
  final List<String> videos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final List<String> tags;
  final String? userName;
  final String? alias;
  final String? userProfileImage;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.location,
    required this.images,
    this.videos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.tags = const [],
    this.userName,
    this.alias,
    this.userProfileImage,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    PostLocation? location,
    List<String>? images,
    List<String>? videos,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    List<String>? tags,
    String? userName,
    String? alias,
    String? userProfileImage,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      location: location ?? this.location,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      tags: tags ?? this.tags,
      userName: userName ?? this.userName,
      alias: alias ?? this.alias,
      userProfileImage: userProfileImage ?? this.userProfileImage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    content,
    location,
    images,
    videos,
    createdAt,
    updatedAt,
    likes,
    tags,
    userName,
    alias,
    userProfileImage,
  ];
}
