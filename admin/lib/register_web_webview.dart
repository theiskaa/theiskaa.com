//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
// 

// ignore: depend_on_referenced_packages
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

void registerWebViewWebImplementation() {
  WebView.platform = WebWebViewPlatform();
}
