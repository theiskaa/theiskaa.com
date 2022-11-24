//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  @visibleForTesting
  static final Logger log = Logger(
    level: getLevel(),
    output: ConsoleOutput(),
    printer: PrettyPrinter(printEmojis: false),
  );

  @visibleForTesting
  static final Logger logNoStack = Logger(
    level: getLevel(),
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      printTime: false,
      printEmojis: false,
      methodCount: 0,
    ),
  );

  static String? level;

  /// Log a message at level `verbose`.
  static Function get v => logNoStack.v;

  /// Log a message at level `debug`.
  static Function get d => logNoStack.d;

  /// Log a message at level `info`.
  static Function get i => logNoStack.i;

  /// Log a message at level `warning` with stacktrace.
  static Function get w => log.w;

  /// Log a message at level `error` with stacktrace.
  static Function get e => log.e;

  /// Log a message at level `critical` with stacktrace.
  static Function get c => log.wtf;

  @visibleForTesting
  static Level getLevel() {
    const levels = {
      'verbose': Level.verbose,
      'debug': Level.debug,
      'info': Level.info,
      'warning': Level.warning,
      'error': Level.error,
      'critical': Level.wtf,
    };

    return levels[level] ?? Level.verbose;
  }
}

class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      developer.log(line);
    }
  }
}
