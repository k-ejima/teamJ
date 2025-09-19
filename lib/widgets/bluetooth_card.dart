import 'package:flutter/material.dart';

class BluetoothCard extends StatelessWidget {
  const BluetoothCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Bluetooth",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("・イヤホン（ダミー）"),
            Text("・スピーカー（ダミー）"),
          ],
        ),
      ),
    );
  }
}
