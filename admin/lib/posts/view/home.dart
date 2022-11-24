//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/models/post.dart';
import 'package:admin/posts/state/post_bloc.dart';
import 'package:admin/posts/view/post_write.dart';
import 'package:admin/posts/view/widgets/post_card.dart';
import 'package:admin/widgets/loadings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostsHome extends StatefulWidget {
  const PostsHome({super.key});

  @override
  State<StatefulWidget> createState() => _PostHomeState();
}

class _PostHomeState extends State<PostsHome> {
  late PostBloc postBloc;

  @override
  void initState() {
    postBloc = BlocProvider.of<PostBloc>(context);
    postBloc.add(PostEvent.fetch());
    super.initState();
  }

  void onRemove(Post post) {
    showDialog(
      context: context,
      builder: (context) => BlocListener<PostBloc, PostState>(
        bloc: postBloc,
        listener: (context, state) {
          final isSuccess = state.event == PostEvents.deleteSuccess;
          final isError = state.event == PostEvents.deleteError;
          if (isSuccess || isError) Navigator.pop(context);
        },
        child: AlertDialog(
          title: RichText(
            text: TextSpan(
              text: 'Do you want to delete post: ',
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: '${post.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            BlocBuilder<PostBloc, PostState>(builder: (context, state) {
              final isLoading = state.event == PostEvents.deleteStart;
              return ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                ),
                child: Builder(builder: (context) {
                  if (isLoading) return Loadings.cupertino(context);
                  return const Text('Delete');
                }),
                onPressed: () {
                  if (isLoading) return;
                  postBloc.add(PostEvent.delete(post.id!));
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostWrite(type: WriteType.create),
            ),
          ),
        ),
        appBar: AppBar(title: const Text('Posts')),
        body: BlocBuilder<PostBloc, PostState>(
          bloc: postBloc,
          builder: (context, state) {
            final isLoading = state.event == PostEvents.fetchStart;
            if (isLoading) return Center(child: Loadings.cupertino(context));

            return PostsList(
              posts: state.posts ?? [],
              onRemovePressed: (_, post) => onRemove(post),
            );
          },
        ),
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  final List<Post> posts;
  final void Function(BuildContext, Post post) onRemovePressed;
  const PostsList({
    super.key,
    required this.posts,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('There is no data to view'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: posts
            .map<Widget>(
              (p) => PostCard(
                model: p,
                onRemovePressed: (context) => onRemovePressed(context, p),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostWrite(
                      model: p,
                      type: WriteType.edit,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
