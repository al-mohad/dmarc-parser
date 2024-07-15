import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

const s = TextStyle(color: Colors.black);

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: controller.pickXmlFile,
            child: const Text('Pick XML File', style: s),
          ),
          Obx(
            () => Expanded(
              child: ListView.builder(
                itemCount: controller.records.length,
                itemBuilder: (context, index) {
                  final record = controller.records[index];
                  return ListTile(
                    title: Text('Source IP: ${record['source_ip']}', style: s),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Count: ${record['count']}', style: s),
                        Text('Disposition: ${record['disposition']}', style: s),
                        Text('DKIM: ${record['dkim']}', style: s),
                        Text('SPF: ${record['spf']}', style: s),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.generatePdf,
            child: const Text('Download as PDF'),
          ),
        ],
      ),
    );
  }
}
