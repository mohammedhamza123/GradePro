import 'package:flutter/cupertino.dart';

class PdfViewerProvider extends ChangeNotifier {
  String _pdf = "";

  String get pdf => _pdf;

  void setPdf(String pdf) {
    _pdf = pdf;
  }
}
