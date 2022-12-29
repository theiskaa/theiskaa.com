//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/models/post.dart';
import 'package:admin/posts/view/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class PostPreview extends StatelessWidget {
  final Post model;
  const PostPreview({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        PostCard(
          onPressed: null,
          onRemovePressed: null,
          model: model.copyWith(
            id: model.id ?? 'auto-generated-id',
            date: model.date ?? 'December 3 | 2022',
          ),
        ),
        const SizedBox(height: 10),
        const Divider(indent: 30, endIndent: 30),
        const SizedBox(height: 10),
        Html(data: model.content),
      ]),
    );
  }
}
