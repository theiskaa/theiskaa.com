//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/app.dart';
import 'package:admin/core/bloc_observer.dart';
import 'package:admin/firebase_options.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Logins to admin user directly.
Future<void> signin() async {
  await dotenv.load(fileName: ".env");

  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: dotenv.env['EMAIL']!,
    password: dotenv.env['PASSWORD']!,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await signin();

  Bloc.observer = AppStateObserver();

  runApp(const App());
}
