//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

class Info {
  final String? picture;
  final String? data;

  const Info({
    this.picture,
    this.data,
  });

  Info copyWith({
    String? picture,
    String? data,
  }) {
    return Info(
      picture: picture ?? this.picture,
      data: data ?? this.data,
    );
  }

  /// Merges the current info([this]) with given [info] model.
  Info mergeWith(Info info) {
    return Info(
      picture: info.picture ?? picture,
      data: info.data ?? data,
    );
  }

  Info.fromJson(Map<String, dynamic> d)
      : picture = d['picture'],
        data = d['data'];

  Map<String, dynamic> toJson() => {
        'picture': picture,
        'data': data,
      };
}
