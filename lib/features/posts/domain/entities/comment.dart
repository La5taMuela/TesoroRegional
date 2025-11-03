import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    userName,
    userProfileImage,
    content,
    createdAt,
  ];
}
