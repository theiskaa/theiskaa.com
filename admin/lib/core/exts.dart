//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';

extension WrapWith on TextEditingController {
  /// Wraps current selection with <left> and <right> string values.
  ///
  /// For example:
  ///   if the selection is "Hello, World!"
  ///   and we use `wrapSelectionWith(left: "**", right: "**")`
  ///   result will be "**Hello, World!**".
  wrapSelectionWith({required String left, required String right}) {
    final middle = selection.textInside(value.text);

    value = value.copyWith(
      text:
          '${selection.textBefore(value.text)}$left$middle$right${selection.textAfter(value.text)}',
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + left.length + middle.length,
      ),
    );
  }
}

extension Validation on String {
  /// Checks if current([this]] string is valid URL or not.
  bool isURL() {
    final url = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    );

    return url.hasMatch(this);
  }
}
