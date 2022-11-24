//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/posts/view/widgets/editable_tile.dart';
import 'package:flutter/material.dart';

class EditableImageField extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final String? Function(String?)? validator;

  const EditableImageField({
    super.key,
    required this.controller,
    required this.formKey,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(children: [
        Expanded(
          flex: 1,
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
        ),
        const SizedBox(width: 5),
        Expanded(
          flex: 3,
          child: EditableTile(
            hint: 'Image URL here',
            controller: controller,
            formKey: formKey,
            validator: validator,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black.withOpacity(.1),
                width: 1.2,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
