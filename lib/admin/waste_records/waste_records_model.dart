import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'waste_records_widget.dart' show WasteRecordsWidget;
import 'package:flutter/material.dart';

class WasteRecordsModel extends FlutterFlowModel<WasteRecordsWidget> {
  ///  State fields for stateful widgets in this page.

  // State fields for stateful widgets in this page.
  bool isProcessing = false;

  // Stores action output result for [Backend Call - Read Document] action in Container widget.
  UsersRecord? residentLog;
  // Stores action output result for [Backend Call - Read Document] action in Column widget.
  UsersRecord? readResidentsImage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
