//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';

class Themes {
  static ThemeData appThemeLight = ThemeData(
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: Colors.black.withOpacity(.2),
      cursorColor: Colors.black,
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        color: Colors.grey.shade900,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    ),
  );
}
