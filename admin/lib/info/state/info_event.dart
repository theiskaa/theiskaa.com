//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

part of 'info_bloc.dart';

enum InfoEvents {
    getStart,
    getSuccess,
    getError,

    updateStart,
    updateSuccess,
    updateError,
}

class InfoEvent {
  InfoEvents? type;
  dynamic payload;

  InfoEvent.get() {
    type = InfoEvents.getStart;
  }

  InfoEvent.update(String field, Info info) {
    type = InfoEvents.updateStart;
    payload = {'field': field, 'info': info};
  }
}
