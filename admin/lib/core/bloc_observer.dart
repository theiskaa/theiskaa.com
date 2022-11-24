//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class AppStateObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    Log.d('[ onEvent $event ]');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    Log.d(
      'Prev State Event: ${transition.currentState.event}\r\n'
      'Next State Event: ${transition.nextState.event}',
    );
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Log.e(bloc, error, stackTrace);
  }
}

