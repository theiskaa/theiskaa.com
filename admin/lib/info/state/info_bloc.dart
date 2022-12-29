//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/core/error.dart';
import 'package:admin/info/models/info.dart';
import 'package:admin/info/services/info_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'info_event.dart';
part 'info_state.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final infoService = InfoService();
  InfoBloc() : super(InfoState.unknown());

  @override
  Future<void> close() async => await super.close();

  /// Emits the cleared state model to the actual state.
  // ignore: invalid_use_of_visible_for_testing_member
  void clearCache() => emit(InfoState.unknown());

  /// A wrapper call method for get event.
  ///
  /// In case of being [info] null, fetches them again.
  Future<void> autoFetch() async {
    final posts = state.info;
    if (posts == null) add(InfoEvent.get());
  }

  @override
  Stream<InfoState> mapEventToState(InfoEvent event) async* {
    switch (event.type) {
      case InfoEvents.getStart:
        yield* mapEventToGetStart(event);
        break;
      case InfoEvents.updateStart:
        yield* mapEventToUpdateStart(event);
        break;
      default:
        //ignore:avoid_print
        print('Found no implementation for event: ${event.type}');
    }
  }

  Stream<InfoState> mapEventToGetStart(InfoEvent event) async* {
    var infoState = state.copyWith(event: event.type, loading: true);

    yield infoState;

    try {
      final res = await infoService.get();
      final info = Info.fromJson(res.data);

      infoState = state.copyWith(
        loading: false,
        info: info,
        event: InfoEvents.getSuccess,
      );
    } on Exception catch (exception) {
      infoState = state.copyWith(
        loading: false,
        event: InfoEvents.getError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield infoState;
  }

  Stream<InfoState> mapEventToUpdateStart(InfoEvent event) async* {
    var infoState = state.copyWith(event: event.type, loading: true);

    yield infoState;

    try {
      final Info info = event.payload['info'];
      final String field = event.payload['field'];

      await infoService.update(field, info);

      var currentInfo = state.info;
      if (currentInfo == null) {
        currentInfo = info;
      } else {
        currentInfo.mergeWith(info);
      }

      infoState = state.copyWith(
        loading: false,
        info: currentInfo,
        event: InfoEvents.updateSuccess,
      );
    } on Exception catch (exception) {
      infoState = state.copyWith(
        loading: false,
        event: InfoEvents.updateError,
        error: ErrorModel.fromException(exception),
      );
    }

    yield infoState;
  }
}
