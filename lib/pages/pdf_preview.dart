// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';

// class PdfPreviewPage extends StatelessWidget {
//   const PdfPreviewPage({super.key, required this.builder});

//   final Future<Uint8List> builder;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Preview'),
//       ),
//       body: PdfPreview(
//         canChangeOrientation: false,
//         canChangePageFormat: false,
//         pdfPreviewPageDecoration: BoxDecoration(border: Border.all()),
//         scrollViewDecoration:
//             BoxDecoration(color: Theme.of(context).colorScheme.background),
//         padding: EdgeInsets.all(20),
//         build: (context) => builder,
//       ),
//     );
//   }
// }
