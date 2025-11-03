import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

class CommentDTO {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String content;
  final DateTime createdAt;

  CommentDTO({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.content,
    required this.createdAt,
  });

  Comment toEntity() {
    return Comment(
      id: id,
      postId: postId,
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      content: content,
      createdAt: createdAt,
    );
  }

  factory CommentDTO.fromEntity(Comment comment) {
    return CommentDTO(
      id: comment.id,
      postId: comment.postId,
      userId: comment.userId,
      userName: comment.userName,
      userProfileImage: comment.userProfileImage,
      content: comment.content,
      createdAt: comment.createdAt,
    );
  }

  factory CommentDTO.fromMap(Map<String, dynamic> map) {
    return CommentDTO(
      id: map['id'] as String,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userProfileImage: map['userProfileImage'] as String?,
      content: map['content'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'content': content,
      'createdAt': createdAt,
    };
  }
}
