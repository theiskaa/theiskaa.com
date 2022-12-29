//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/api_wrapper.dart';
import 'package:admin/posts/models/post.dart';
import 'package:dio/dio.dart';

class PostService {
  static const String path = 'posts';
  final API api = API();

  /// Fetches all posts.
  Future<Response> fetch() async => await api.http.get(path);

  /// Gets concrete post by its id.
  Future<Response> get(String id) async => await api.http.get('$path/$id');

  /// Adds a new record of post data.
  Future<Response> add(Post post) async {
    return await api.http.post(path, data: post.toJson());
  }

  /// Deletes the concrete post document by identifying it via its id.
  Future<Response> delete(String id) async {
    return await api.http.delete('$path/$id');
  }

  /// Updates the concrete post document's concrete field.
  Future<Response> update(String id, field, Post post) async {
    return await api.http.put('$path/$id/$field', data: post.toJson());
  }
}
