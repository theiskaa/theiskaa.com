//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loadings {
  /// An IOS style loading animation.
  static Widget cupertino(
    BuildContext context, {
    double? size,
    Brightness? brh,
  }) {
    final brightness = brh ?? Theme.of(context).brightness;

    return SizedBox(
      height: size,
      width: size,
      child: Theme(
        data: ThemeData(
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: brightness,
          ),
        ),
        child: const CupertinoActivityIndicator(),
      ),
    );
  }
}
