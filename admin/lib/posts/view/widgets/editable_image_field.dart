//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/view/widgets/editable_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditableImageField extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const EditableImageField({
    super.key,
    required this.controller,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () async => await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Paste URL'),
          content: EditableTile(
            hint: 'Image URL here',
            controller: controller,
            formKey: formKey,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 80,
          child: Builder(
            builder: (context) {
              final source = controller.text.replaceAll(' ', '');

              if (source.isEmpty) return Image.asset('assets/cover.png');
              return Image.network(source);
            },
          ),
        ),
      ),
    );
  }
}
