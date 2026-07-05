import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Genera y comparte reportes en PDF y Excel a partir de datos ya agregados
/// (mapas categoría -> valor). Mantiene toda la lógica de exportación
/// separada de la UI de la pantalla de Reportes.
class ExportService {
  final _currency = NumberFormat.currency(locale: 'es_AR', symbol: r'$');

  Future<void> exportarPdf({
    required String titulo,
    required Map<String, num> datos,
    String unidad = r'$',
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(titulo,
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Generado el ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Concepto',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Valor',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...datos.entries.map(
                  (e) => pw.TableRow(children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8), child: pw.Text(e.key)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(unidad == r'$'
                          ? _currency.format(e.value)
                          : '${e.value} $unidad'),
                    ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          '${_slug(titulo)}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  Future<void> exportarExcel({
    required String titulo,
    required Map<String, num> datos,
  }) async {
    final excel = xls.Excel.createExcel();
    final hoja = excel[titulo.length > 31 ? titulo.substring(0, 31) : titulo];

    hoja.appendRow([
      xls.TextCellValue('Concepto'),
      xls.TextCellValue('Valor'),
    ]);
    for (final e in datos.entries) {
      hoja.appendRow([
        xls.TextCellValue(e.key),
        xls.DoubleCellValue(e.value.toDouble()),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final nombreArchivo =
        '${_slug(titulo)}_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte: $titulo',
    );
  }

  String _slug(String texto) => texto
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
