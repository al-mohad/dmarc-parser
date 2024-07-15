import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:xml/xml.dart' as xml;

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  @override
  void onInit() {
    print('object');
    super.onInit();
  }

  @override
  void onReady() {
    print('object');
    super.onReady();
  }

  @override
  void onClose() {
    print('object');
    super.onClose();
  }

  String _xmlContent = '';
  final _records = RxList<Map<String, String>>([]);
  List<Map<String, String>> get records => _records;

  void pickXmlFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      _xmlContent = content;
      _parseXml(content);
      update();
    }
  }

  void _parseXml(String content) {
    var document = xml.XmlDocument.parse(content);
    var records = document.findAllElements('record');
    List<Map<String, String>> parsedRecords = [];

    for (var record in records) {
      var row = record.findElements('row').first;
      var sourceIp = row.findElements('source_ip').first.text;
      var count = row.findElements('count').first.text;
      var disposition = row
          .findElements('policy_evaluated')
          .first
          .findElements('disposition')
          .first
          .text;
      var dkim = row
          .findElements('policy_evaluated')
          .first
          .findElements('dkim')
          .first
          .text;
      var spf = row
          .findElements('policy_evaluated')
          .first
          .findElements('spf')
          .first
          .text;

      parsedRecords.add({
        'source_ip': sourceIp,
        'count': count,
        'disposition': disposition,
        'dkim': dkim,
        'spf': spf,
      });
    }

    _records.value = parsedRecords;
    update();
  }

  void generatePdf() async {
    final font = await PdfGoogleFonts.nunitoExtraLight();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              return pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Source IP: ${record['source_ip']}',
                        style: pw.TextStyle(font: font)),
                    pw.Text('Count: ${record['count']}',
                        style: pw.TextStyle(font: font)),
                    pw.Text('Disposition: ${record['disposition']}',
                        style: pw.TextStyle(font: font)),
                    pw.Text('DKIM: ${record['dkim']}',
                        style: pw.TextStyle(font: font)),
                    pw.Text('SPF: ${record['spf']}',
                        style: pw.TextStyle(font: font)),
                    pw.Divider(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
