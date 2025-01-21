import '/flutter_flow/flutter_flow_util.dart';
import '/residents/resident_recent/resident_recent_widget.dart';
import 'rewards_page_widget.dart' show RewardsPageWidget;
import 'package:flutter/material.dart';

class RewardsPageModel extends FlutterFlowModel<RewardsPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for residentRecent component.
  late ResidentRecentModel residentRecentModel;

  @override
  void initState(BuildContext context) {
    residentRecentModel = createModel(context, () => ResidentRecentModel());
  }

  @override
  void dispose() {
    residentRecentModel.dispose();
  }
}
