//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/info/state/info_bloc.dart';
import 'package:admin/widgets/loadings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoHome extends StatefulWidget {
  const InfoHome({super.key});

  @override
  State<StatefulWidget> createState() => _InfoHomeState();
}

class _InfoHomeState extends State<InfoHome> {
  late InfoBloc infoBloc;

  @override
  void initState() {
    infoBloc = context.read<InfoBloc>();
    infoBloc.autoFetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: BlocBuilder<InfoBloc, InfoState>(builder: (context, state) {
        if (state.event == InfoEvents.getStart) {
          return Center(child: Loadings.cupertino(context));
        }

        // TODO: impl editable text fields
        return Container();
      }),
    );
  }
}
