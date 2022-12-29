//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

import 'package:admin/info/models/info.dart';
import 'package:admin/info/state/info_bloc.dart';
import 'package:admin/info/view/preview.dart';
import 'package:admin/posts/view/widgets/html_tag_editor.dart';
import 'package:admin/widgets/fields.dart';
import 'package:admin/widgets/loadings.dart';
import 'package:admin/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/core/exts.dart';

class InfoHome extends StatefulWidget {
  const InfoHome({super.key});

  @override
  State<StatefulWidget> createState() => _InfoHomeState();
}

class _InfoHomeState extends State<InfoHome> {
  late InfoBloc infoBloc;

  final FocusNode contentNode = FocusNode();

  final pictureKey = GlobalKey<FormState>();
  final dataKey = GlobalKey<FormState>();

  var pictureController = TextEditingController();
  var dataController = TextEditingController();

  void updateState() => setState(() {});

  @override
  void initState() {
    infoBloc = BlocProvider.of<InfoBloc>(context);

    pictureController.addListener(updateState);
    dataController.addListener(updateState);
    super.initState();
  }

  // Generates a info model from the active text editing controllers.
  Info generateInfo() {
    return Info(
      picture: pictureController.text,
      data: dataController.text,
    );
  }

  void onAct() {
    final validations = [
      pictureKey.currentState?.validate() ?? false,
      dataKey.currentState?.validate() ?? false,
    ];

    if (validations.contains(false)) {
      ViewUtils.showSnack(context, title: 'Some fields are invalid');
      return;
    }

    // TODO: add general empty field for updating all fields.
    infoBloc.add(InfoEvent.update('', generateInfo()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InfoBloc, InfoState>(
      listener: (context, state) {
        if (state.info != null && state.event == InfoEvents.getSuccess) {
          pictureController.text = state.info!.picture ?? '';
          dataController.text = state.info!.data ?? '';
        }

        if (state.event == InfoEvents.getError ||
            state.event == InfoEvents.updateError) {
          ViewUtils.showSnack(
            context,
            title: 'Something went wrong: ${state.error?.toJson()}',
          );
        }
      },
      child: BlocBuilder<InfoBloc, InfoState>(builder: (context, state) {
        if (state.info == null || state.event == InfoEvents.getStart) {
          return Scaffold(body: Center(child: Loadings.cupertino(context)));
        }

        return DefaultTabController(
          length: 2,
          child: GestureDetector(
            onTap: () => setState(() => contentNode.unfocus()),
            child: Scaffold(
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: FractionallySizedBox(
                  widthFactor: .8,
                  child: ElevatedButton(
                    onPressed: onAct,
                    child: BlocBuilder<InfoBloc, InfoState>(
                      builder: (context, state) {
                        if (state.event == InfoEvents.updateStart) {
                          return Loadings.cupertino(context);
                        }

                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              appBar: AppBar(
                bottom: const TabBar(
                  overlayColor: null,
                  indicatorWeight: 5,
                  tabs: [
                    Tab(text: "Edit"),
                    Tab(text: "Preview"),
                  ],
                ),
                title: const Text('Edit Info Page'),
              ),
              body: TabBarView(children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    EditableImageField(
                      formKey: pictureKey,
                      controller: pictureController,
                      validator: (v) {
                        if ((v ?? '').isURL()) return null;
                        return "Invalid URL";
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(indent: 30, endIndent: 30),
                    const SizedBox(height: 10),
                    Column(children: [
                      EditableTile(
                        hint: '< the content as html >',
                        node: contentNode,
                        formKey: dataKey,
                        controller: dataController,
                        validator: (v) {
                          if (v != null && v.length > 50) return null;
                          return "Data couldn't be this short";
                        },
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(.1),
                            width: 1.2,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                      ),
                      if (contentNode.hasFocus)
                        HtmlTagBar(
                          controller: dataController,
                          focusNode: contentNode,
                        ),
                    ]),
                  ]),
                ),
                InfoPreview(model: generateInfo()),
              ]),
            ),
          ),
        );
      }),
    );
  }
}
