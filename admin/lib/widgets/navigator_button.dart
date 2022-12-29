//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/info/view/home.dart';
import 'package:admin/posts/view/home.dart';
import 'package:flutter/material.dart';

class NavigatorButton extends StatelessWidget {
  final String route;
  final Radius radius;

  const NavigatorButton({
    super.key,
    required this.route,
    this.radius = const Radius.circular(10),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(radius),
          ),
        ),
      ),
      child: Text(route),
      onPressed: () async {
        switch (route) {
          case 'info':
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InfoHome()),
            );
            return;
          case 'posts':
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostsHome()),
            );
            return;
        }
      },
    );
  }
}
