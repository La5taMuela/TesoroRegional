import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostsLoaded extends PostState {
  final List<Post> posts;

  const PostsLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostLoaded extends PostState {
  final Post post;

  const PostLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

class PostCreated extends PostState {
  final String postId;

  const PostCreated(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostSuccess extends PostState {
  final String message;

  const PostSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
