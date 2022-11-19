//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/error.dart';
import 'package:admin/posts/models/post.dart';
import 'package:admin/posts/services/post_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final postService = PostService();
  PostBloc() : super(PostState.unknown());

  @override
  Future<void> close() async => await super.close();

  /// Emits the cleared state model to the actual state.
  // ignore: invalid_use_of_visible_for_testing_member
  void clearCache() => emit(PostState.unknown());

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    switch (event.type) {
      case PostEvents.fetchStart:
        yield* mapEventToFetchStart(event);
        break;
      case PostEvents.getStart:
        yield* mapEventToGetStart(event);
        break;
      case PostEvents.addStart:
        yield* mapEventToAddStart(event);
        break;
      case PostEvents.deleteStart:
        yield* mapEventToDeleteStart(event);
        break;
      case PostEvents.updateStart:
        yield* mapEventToUpdateStart(event);
        break;
      default:
        //ignore:avoid_print
        print('Found no implementation for event: ${event.type}');
    }
  }

  Stream<PostState> mapEventToFetchStart(PostEvent event) async* {
    var postState = state.copyWith(event: event.type, loading: true);

    yield postState;

    try {
      final res = await postService.fetch();

      List<Post>? posts;
      if (res.data != null) {
        posts = [];
        for (var data in res.data) {
          posts.add(Post.fromJson(data));
        }
      }

      postState = state.copyWith(
        loading: false,
        posts: posts,
        event:
            res.data == null ? PostEvents.fetchError : PostEvents.fetchSuccess,
      );
    } on Exception catch (exception) {
      postState = state.copyWith(
        loading: false,
        event: PostEvents.fetchError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield postState;
  }

  Stream<PostState> mapEventToGetStart(PostEvent event) async* {
    var postState = state.copyWith(event: event.type, loading: true);

    yield postState;

    try {
      final res = await postService.get(event.payload);

      postState = state.copyWith(
        loading: false,
        post: Post.fromJson(res.data),
        event: res.data == null ? PostEvents.getError : PostEvents.getSuccess,
      );
    } on Exception catch (exception) {
      postState = state.copyWith(
        loading: false,
        event: PostEvents.getError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield postState;
  }

  Stream<PostState> mapEventToAddStart(PostEvent event) async* {
    var postState = state.copyWith(event: event.type, loading: true);

    yield postState;

    try {
      final Post post = event.payload;

      final res = await postService.add(event.payload);

      final List<Post> posts = state.posts ?? [];
      posts.insert(0, post);

      postState = state.copyWith(
        loading: false,
        posts: posts,
        event: res.data == null ? PostEvents.addError : PostEvents.addSuccess,
      );
    } on Exception catch (exception) {
      postState = state.copyWith(
        loading: false,
        event: PostEvents.addError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield postState;
  }

  Stream<PostState> mapEventToDeleteStart(PostEvent event) async* {
    var postState = state.copyWith(event: event.type, loading: true);

    yield postState;

    try {
      final String id = event.payload;

      final res = await postService.delete(id);

      final List<Post> posts = state.posts ?? [];
      final idx = posts.indexWhere((p) => p.id == id);
      if (idx != -1) posts.removeAt(idx);

      postState = state.copyWith(
        loading: false,
        posts: posts,
        event: res.data == null
            ? PostEvents.deleteError
            : PostEvents.deleteSuccess,
      );
    } on Exception catch (exception) {
      postState = state.copyWith(
        loading: false,
        event: PostEvents.deleteError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield postState;
  }

  Stream<PostState> mapEventToUpdateStart(PostEvent event) async* {
    var postState = state.copyWith(event: event.type, loading: true);

    yield postState;

    try {
      final String id = event.payload['id'];
      final String field = event.payload['field'];
      final Post post = event.payload['post'];

      final res = await postService.update(id, field, post);

      final List<Post> posts = state.posts ?? [];
      final idx = posts.indexWhere((p) => p.id == id);
      if (idx != -1) {
        posts.removeAt(idx);
        posts.insert(idx, post);
      }

      postState = state.copyWith(
        loading: false,
        posts: posts,
        event: res.data == null
            ? PostEvents.updateError
            : PostEvents.updateSuccess,
      );
    } on Exception catch (exception) {
      postState = state.copyWith(
        loading: false,
        event: PostEvents.updateError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield postState;
  }
}
