//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

class Post {
  final String? id;
  final String? title;
  final String? description;
  final String? cover;
  final String? date;
  final String? content;

  const Post({
    this.id,
    this.title,
    this.description,
    this.cover,
    this.date,
    this.content,
  });

  Post copyWith({
    String? id,
    String? title,
    String? description,
    String? cover,
    String? date,
    String? content,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cover: cover ?? this.cover,
      date: date ?? this.date,
      content: content ?? this.content,
    );
  }

  /// Merges the current Post([this]) with given [post] model.
  Post mergeWith(Post post) {
    return Post(
      id: post.id ?? id,
      title: post.title ?? title,
      description: post.description ?? description,
      cover: post.cover ?? cover,
      date: post.date ?? date,
      content: post.content ?? content,
    );
  }

  /// Removes the given field from the current([this]) Post model.
  Post removeField(String field) {
    switch (field) {
      case 'title':
        return mergeWith(const Post(title: ''));
      case 'description':
        return mergeWith(const Post(description: ''));
      case 'cover':
        return mergeWith(const Post(cover: ''));
      case 'date':
        return mergeWith(const Post(date: ''));
      case 'content':
        return mergeWith(const Post(content: ''));
      default:
        return this;
    }
  }

  Post.fromJson(Map<String, dynamic> data)
      : id = data['id'],
        title = data['title'],
        description = data['description'],
        cover = data['cover'],
        date = data['date'],
        content = data['content'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'cover': cover,
        'date': date,
        'content': content,
      };

  static List<String> get editablefields =>
      ['title', 'description', 'cover', 'date', 'content'];
}
