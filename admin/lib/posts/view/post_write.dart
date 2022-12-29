//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/models/post.dart';
import 'package:admin/posts/state/post_bloc.dart';
import 'package:admin/posts/view/post_preview.dart';
import 'package:admin/widgets/fields.dart';
import 'package:admin/widgets/html_tag_editor.dart';
import 'package:admin/widgets/loadings.dart';
import 'package:admin/widgets/utils.dart';
import 'package:admin/core/exts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late PostBloc postBloc;

  final FocusNode contentNode = FocusNode();

  final titleKey = GlobalKey<FormState>();
  final descriptionKey = GlobalKey<FormState>();
  final contentKey = GlobalKey<FormState>();
  final coverKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController contentController;
  late TextEditingController coverController;

  void updateState() => setState(() {});

  @override
  void initState() {
    postBloc = BlocProvider.of<PostBloc>(context);

    titleController = TextEditingController(text: widget.model?.title);
    descriptionController = TextEditingController(
      text: widget.model?.description,
    );
    contentController = TextEditingController(text: widget.model?.content);
    coverController = TextEditingController(text: widget.model?.cover);

    titleController.addListener(updateState);
    descriptionController.addListener(updateState);
    contentController.addListener(updateState);
    coverController.addListener(updateState);
    super.initState();
  }

  // Generates a post model from the active text editing controllers.
  Post generatePost() {
    return Post(
      id: widget.model?.id,
      title: titleController.text,
      description: descriptionController.text,
      cover: coverController.text,
      date: widget.model?.date,
      content: contentController.text,
    );
  }

  void onAct() {
    final validations = [
      titleKey.currentState?.validate() ?? false,
      descriptionKey.currentState?.validate() ?? false,
      contentKey.currentState?.validate() ?? false,
      coverKey.currentState?.validate() ?? false,
    ];

    if (validations.contains(false)) {
      ViewUtils.showSnack(context, title: 'Some fields are invalid');
      return;
    }

    final post = generatePost();
    final PostEvent event = {
      WriteType.create: PostEvent.add(post),
      WriteType.edit: PostEvent.update(
        widget.model?.id ?? '',
        '',
        post,
      ),
    }[widget.type]!;

    postBloc.add(event);
  }

  // The general state listener method for current page.
  void stateListener(BuildContext context, PostState state) {
    if (state.event == PostEvents.addSuccess) {
      titleController.clear();
      descriptionController.clear();
      contentController.clear();
      coverController.clear();

      postBloc.add(PostEvent.fetch());
      setState(() {});
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: stateListener,
      child: DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () => setState(() => contentNode.unfocus()),
          child: Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: FractionallySizedBox(
                widthFactor: .8,
                child: ElevatedButton(
                  onPressed: onAct,
                  child: BlocBuilder<PostBloc, PostState>(
                    builder: (context, state) {
                      if (state.event == PostEvents.addStart ||
                          state.event == PostEvents.updateStart) {
                        return Loadings.cupertino(context);
                      }

                      final title = {
                        WriteType.edit: 'Save Changes',
                        WriteType.create: 'Create new post'
                      }[widget.type];

                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          title ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            appBar: AppBar(
              bottom: const TabBar(
                overlayColor: null,
                indicatorWeight: 5,
                tabs: [
                  Tab(text: "Edit"),
                  Tab(text: "Preview"),
                ],
              ),
              title: Builder(builder: (context) {
                if (widget.type == WriteType.edit) {
                  return Text('#${widget.model?.id}');
                }

                return const Text('Create New Post');
              }),
            ),
            body: TabBarView(children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  EditableImageField(
                    formKey: coverKey,
                    controller: coverController,
                    validator: (v) {
                      if ((v ?? '').isURL()) return null;
                      return "Invalid URL";
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(indent: 30, endIndent: 30),
                  const SizedBox(height: 10),
                  EditableTile(
                    hint: 'Post Title',
                    formKey: titleKey,
                    controller: titleController,
                    validator: (v) {
                      if (v != null && v.isNotEmpty) return null;
                      return "Title couldn't be empty";
                    },
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
                    validator: (v) {
                      if (v != null && v.isNotEmpty) return null;
                      return "Short description couldn't be empty";
                    },
                    style: TextStyle(
                      color: Colors.black.withOpacity(.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(indent: 30, endIndent: 30),
                  const SizedBox(height: 10),
                  Column(children: [
                    EditableTile(
                      hint: '< the content as html >',
                      node: contentNode,
                      formKey: contentKey,
                      controller: contentController,
                      validator: (v) {
                        if (v != null && v.length > 50) return null;
                        return "Content couldn't be this short";
                      },
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(.1),
                          width: 1.2,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    if (contentNode.hasFocus)
                      HtmlTagBar(
                        controller: contentController,
                        focusNode: contentNode,
                      ),
                  ]),
                ]),
              ),
              PostPreview(model: generatePost()),
            ]),
          ),
        ),
      ),
    );
  }
}
