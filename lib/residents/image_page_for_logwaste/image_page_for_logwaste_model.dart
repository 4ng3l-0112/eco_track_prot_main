import '/flutter_flow/flutter_flow_util.dart';
import 'image_page_for_logwaste_widget.dart' show ImagePageForLogwasteWidget;
import 'package:flutter/material.dart';

class ImagePageForLogwasteModel
    extends FlutterFlowModel<ImagePageForLogwasteWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  // Add state for loading
  bool isSubmitting = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
