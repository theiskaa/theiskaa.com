//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';

class ViewUtils {
  // Shows an easy-modifiable snack bar.
  static showSnack(
    BuildContext context, {
    required String title,
    String? body,
    Color color = Colors.redAccent,
    bool isFloating = true,
    int sec = 3,
  }) async {
    final snack = SnackBar(
      backgroundColor: color,
      duration: Duration(seconds: sec),
      margin: isFloating ? const EdgeInsets.all(8) : null,
      behavior: isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(
        borderRadius: isFloating
            ? BorderRadius.circular(8)
            : const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
      ),
      content: SingleChildScrollView(
        child: Builder(
          builder: (context) {
            if (body == null || body.isEmpty) {
              return Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              );
            }

            return Column(children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  body,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
