//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

part of 'info_bloc.dart';

class InfoState {
  final InfoEvents? event;
  final Info? info;
  final bool? loading;
  final ErrorModel? error;

  const InfoState({
    required this.event,
    this.info,
    this.loading,
    this.error,
  });

  InfoState copyWith({
    InfoEvents? event,
    Info? info,
    bool? loading,
    ErrorModel? error,
  }) {
    return InfoState(
      event: event ?? this.event,
      info: info ?? this.info,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  InfoState.unknown()
      : this(event: null, info: null, loading: true, error: null);
}
