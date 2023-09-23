// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart';

// import '../shopping_cart.dart';

// String formatNumber(int value) {
//   return NumberFormat('###,###,###').format(value);
// }

// //Future<Uint8List> makePdf(CartProvider cartProvider, Map<String, dynamic> data) async {
// Future<Uint8List> makePdf(
//   String customerName,
//   int subTotal,
//   int discountPrice,
//   int grandTotal,
//   int paymentNominal,
//   List<Cart> carts,
// ) async {
//   final pdf = Document();
//   final logo = MemoryImage(
//       (await rootBundle.load('assets/logo-black.png')).buffer.asUint8List());

//   DateTime now = new DateTime.now();

//   pdf.addPage(
//     Page(
//       pageFormat: PdfPageFormat(360, double.infinity),
//       margin: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
//       build: (Context context) {
//         return Container(
//           width: double.infinity,
//           child: Column(
//             children: [
//               SizedBox(height: 48, child: Image(logo)),
//               SizedBox(height: 20),
//               Text(customerName),
//               SizedBox(height: 8),
//               Text(DateFormat('EEEE, dd MMMM yyyy').format(now)),
//               Text(DateFormat('hh:mm:ss').format(now)),
//               SizedBox(height: 20),
//               //////////
//               ...carts.map(
//                 (e) {
//                   return Row(
//                     children: [
//                       Expanded(child: Text(e.product.name)),
//                       SizedBox(width: 8),
//                       SizedBox(
//                         width: 80,
//                         child: Text(formatNumber(e.product.price),
//                             textAlign: TextAlign.right),
//                       ),
//                       SizedBox(width: 8),
//                       Text(e.quantity.value.toString()),
//                       SizedBox(width: 8),
//                       SizedBox(
//                         width: 80,
//                         child: Text(
//                             formatNumber(e.product.price * e.quantity.value),
//                             textAlign: TextAlign.right),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               //////////
//               SizedBox(height: 20),
//               //////////
//               Row(
//                 children: [
//                   Expanded(child: Text("Subtotal", textAlign: TextAlign.right)),
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 80,
//                     child: Text(formatNumber(subTotal),
//                         textAlign: TextAlign.right),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(child: Text("Diskon", textAlign: TextAlign.right)),
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 80,
//                     child: Text('-${formatNumber(discountPrice)}',
//                         textAlign: TextAlign.right),
//                   ),
//                 ],
//               ),
//               //////////
//               SizedBox(height: 20),
//               //////////
//               Row(
//                 children: [
//                   Expanded(child: Text("Total", textAlign: TextAlign.right)),
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 80,
//                     child: Text(formatNumber(grandTotal),
//                         textAlign: TextAlign.right),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(child: Text("Bayar", textAlign: TextAlign.right)),
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 80,
//                     child: Text(formatNumber(paymentNominal),
//                         textAlign: TextAlign.right),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                       child: Text("Kembalian", textAlign: TextAlign.right)),
//                   SizedBox(width: 8),
//                   SizedBox(
//                     width: 80,
//                     child: Text(formatNumber(paymentNominal - grandTotal),
//                         textAlign: TextAlign.right),
//                   ),
//                 ],
//               ),
//               //////////
//               SizedBox(height: 20),
//               Text("Terimakasih atas Kunjungannya"),
//             ],
//           ),
//         );
//       },
//     ),
//   );
//   return pdf.save();
// }
