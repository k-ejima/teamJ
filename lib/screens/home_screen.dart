import 'package:flutter/material.dart';
import '../widgets/network_card.dart';
import '../widgets/battery_card.dart';
import '../widgets/storage_card.dart';
import '../widgets/bluetooth_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Battery",
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            NetworkCard(),
            BatteryCard(),
            StorageCard(),
            BluetoothCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "ホーム"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "設定"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "履歴"),
        ],
      ),
    );
  }
}
