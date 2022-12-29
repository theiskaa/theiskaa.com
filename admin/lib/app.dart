//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/themes.dart';
import 'package:admin/info/state/info_bloc.dart';
import 'package:admin/info/view/home.dart';
import 'package:admin/posts/state/post_bloc.dart';
import 'package:admin/posts/view/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (_) => PostBloc()),
        BlocProvider<InfoBloc>(create: (_) => InfoBloc()),
      ],
      child: MaterialApp(
        title: 'theiskaa.com admin app',
        debugShowCheckedModeBanner: false,
        theme: Themes.appThemeLight,
        home: const MainWrapper(),
      ),
    );
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: CupertinoButton(
            pressedOpacity: .8,
            padding: EdgeInsets.zero,
            onPressed: () async {
              context.read<InfoBloc>().add(InfoEvent.get());

              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoHome()),
              );
            },
            child: Container(
              color: Colors.yellow,
              child: const Center(
                child: Text(
                  'Info',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: CupertinoButton(
            pressedOpacity: .8,
            padding: EdgeInsets.zero,
            onPressed: () async => await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostsHome()),
            ),
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
