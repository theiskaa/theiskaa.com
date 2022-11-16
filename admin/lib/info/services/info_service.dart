//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/api_wrapper.dart';
import 'package:admin/info/models/info.dart';
import 'package:dio/dio.dart';

class InfoService {
  static const String path = 'info';
  final API api = API();

  /// Gets the info model via response.
  Future<Response> get() async => await api.http.get(path);

  /// Gets the info model via response.
  Future<Response> update(String field, Info info) async {
    return await api.http.put('$path/$field', data: info.toJson());
  }

  /// Gets the info model via response.
  Future<Response> delete(String field) async {
    return await api.http.delete('$path/$field');
  }
}
