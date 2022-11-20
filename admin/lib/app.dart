//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/info/state/info_bloc.dart';
import 'package:admin/posts/state/post_bloc.dart';
import 'package:admin/widgets/navigator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (context) => PostBloc()),
        BlocProvider<InfoBloc>(create: (context) => InfoBloc()),
      ],
      child: const MaterialApp(
        title: 'theiskaa.com admin app',
        debugShowCheckedModeBanner: false,
        home: MainWrapper(),
      ),
    );
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('theiskaa.com admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: const [
                NavigatorButton(route: 'info'),
                SizedBox(width: 10),
                NavigatorButton(route: 'posts'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
