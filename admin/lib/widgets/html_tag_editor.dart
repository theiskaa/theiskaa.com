//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';
import 'package:admin/core/exts.dart';

class HtmlTagBar extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final Border border;

  const HtmlTagBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.border = const Border(
      bottom: BorderSide(color: Colors.grey, style: BorderStyle.solid),
      left: BorderSide(color: Colors.grey, style: BorderStyle.solid),
      right: BorderSide(color: Colors.grey, style: BorderStyle.solid),
    ),
  });

  // A wrapper method for [wrapSelectionWith] extension method of text editing controller.
  Future<void> focusAndWrapSelection(String left, right) async {
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    controller.wrapSelectionWith(left: left, right: right);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Wrap(children: [
          IconButton(
            icon: const Icon(Icons.format_bold),
            onPressed: () async => focusAndWrapSelection('<b>', '</b>'),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.format_italic),
            onPressed: () async => focusAndWrapSelection('<i>', '</i>'),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.format_underline),
            onPressed: () async => focusAndWrapSelection('<u>', '</u>'),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.format_strikethrough),
            onPressed: () async => focusAndWrapSelection('<s>', '</s>'),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () async {
              final nextLine = controller.value.text.isNotEmpty;
              focusAndWrapSelection(nextLine ? '\n- ' : '- ', '');
            },
          ),
        ]),
      ),
    );
  }
}
