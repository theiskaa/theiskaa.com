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

            return PostsList(posts: state.posts ?? []);
          },
        ),
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  final List<Post> posts;
  const PostsList({super.key, required this.posts});

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
