import 'package:flutter/material.dart';
import 'package:gradpro/providers/pdf_viewer_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatelessWidget {
  const PdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<PdfViewerProvider>(builder: (context, provider, _c) {
      return SfPdfViewer.network(provider.pdf);
    }));
  }
}
