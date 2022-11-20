//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PostCard extends StatelessWidget {
  final Post model;
  final Function() onPressed;
  final void Function(BuildContext) onRemovePressed;

  const PostCard({
    super.key,
    required this.model,
    required this.onPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: onRemovePressed,
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        onTap: onPressed,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 80, child: Image.network(model.cover!)),
        ),
        title: Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '#${model.id}',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.orange.withOpacity(.5),
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              model.title ?? '',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ]),
        subtitle: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              model.description ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black.withOpacity(.5),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              model.date ?? '',
              style: TextStyle(
                color: Colors.orange.withOpacity(.5),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
