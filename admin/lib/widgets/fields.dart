//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';

class EditableTile extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final TextStyle? style;
  final bool readOnly;
  final String? hint;
  final InputBorder border;
  final String? Function(String?)? validator;
  final FocusNode? node;

  const EditableTile({
    super.key,
    required this.formKey,
    required this.controller,
    this.style,
    this.readOnly = false,
    this.hint,
    this.border = InputBorder.none,
    this.validator,
    this.node,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        maxLines: null,
        focusNode: node,
        readOnly: readOnly,
        controller: controller,
        style: style,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: border,
          hintStyle: style?.copyWith(
            color: Colors.black.withOpacity(.5),
          ),
        ),
      ),
    );
  }
}

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
