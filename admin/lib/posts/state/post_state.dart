//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

part of 'post_bloc.dart';

class PostState {
  final PostEvents? event;
  final List<Post>? posts;
  final Post? post;
  final bool? loading;
  final ErrorModel? error;

  const PostState({
    required this.event,
    this.posts,
    this.post,
    this.loading,
    this.error,
  });

  PostState copyWith({
    PostEvents? event,
    List<Post>? posts,
    Post? post,
    bool? loading,
    ErrorModel? error,
  }) {
    return PostState(
      event: event ?? this.event,
      posts: posts ?? this.posts,
      post: post ?? this.post,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  PostState.unknown() : this(event: null, loading: true);
}
