//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

part of 'post_bloc.dart';

enum PostEvents {
    fetchStart,
    fetchSuccess,
    fetchError,

    getStart,
    getSuccess,
    getError,

    addStart,
    addSuccess,
    addError,

    deleteStart,
    deleteSuccess,
    deleteError,
    
    updateStart,
    updateSuccess,
    updateError,
}

class PostEvent {
  PostEvents? type;
  dynamic payload;

  PostEvent.fetch() {
    type = PostEvents.fetchStart;
  }

  PostEvent.get(String this.payload) {
    type = PostEvents.getStart;
  }

  PostEvent.add(Post this.payload) {
    type = PostEvents.getStart;
  }

  PostEvent.delete(String this.payload) {
    type = PostEvents.deleteStart;
  }

  PostEvent.update(String id ,field, Post post) {
    type = PostEvents.updateStart;
    payload = {'id': id, 'field': field, 'post': post};
  }
}
