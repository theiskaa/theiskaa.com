//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/error.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'info_event.dart';
part 'info_state.dart';


class Info extends Bloc<InfoEvent, InfoState> {
  Info() : super(InfoState.unknown());

  @override
  Future<void> close() async => await super.close();

  /// Emits the cleared state model to the actual state.
  // ignore: invalid_use_of_visible_for_testing_member
  void clearCache() => emit(InfoState.unknown());

  @override
  Stream<InfoState> mapEventToState(InfoEvent event) async* {
    switch (event.type) {
      // TODO: add event handlers.
      default:
        //ignore:avoid_print
        print('Found no implementation for event: ${event.type}');
    }
  }
}
