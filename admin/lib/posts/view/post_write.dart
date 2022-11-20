//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/models/post.dart';
import 'package:admin/posts/view/widgets/editable_tile.dart';
import 'package:flutter/material.dart';

/// The action and function identified or
enum WriteType { edit, create }

class PostWrite extends StatefulWidget {
  final WriteType type;
  final Post? model;

  const PostWrite({
    super.key,
    required this.type,
    this.model,
  });

  @override
  State<StatefulWidget> createState() => _PostWriteState();
}

class _PostWriteState extends State<PostWrite> {
  final titleKey = GlobalKey<FormState>();
  final descriptionKey = GlobalKey<FormState>();
  final contentKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController contentController;

  @override
  void initState() {
    titleController = TextEditingController(text: widget.model?.title);
    descriptionController = TextEditingController(
      text: widget.model?.description,
    );
    contentController = TextEditingController(text: widget.model?.content);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (context) {
          if (widget.type == WriteType.edit) {
            return Text('#${widget.model?.id}');
          }

          return const Text('Create New Post');
        }),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          EditableTile(
            hint: 'Post Title',
            formKey: titleKey,
            controller: titleController,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          EditableTile(
            hint: 'Post Description ...',
            formKey: descriptionKey,
            controller: descriptionController,
            style: TextStyle(
              color: Colors.black.withOpacity(.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(indent: 30, endIndent: 30),
          const SizedBox(height: 10),
          EditableTile(
            hint: '< the content as html >',
            formKey: contentKey,
            controller: contentController,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black.withOpacity(.1),
                width: 1.2,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
