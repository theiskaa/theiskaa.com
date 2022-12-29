//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:admin/info/models/info.dart';

class InfoPreview extends StatelessWidget {
  final Info model;
  const InfoPreview({super.key, required this.model});

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(child: Html(data: model.data));
}
