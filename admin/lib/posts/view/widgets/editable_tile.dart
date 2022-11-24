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
