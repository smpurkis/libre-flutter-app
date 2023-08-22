import 'package:flutter/material.dart';

import 'libre_api.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String inRange = '';
  Color borderColor = Colors.white;
  String timeLastUpdated = '';

  @override
  void initState() {
    super.initState();
    _getPercentInRange();
  }

  Future<void> _getPercentInRange() async {
    var (inRangeAwait, borderColorAwait) = await getPercentInRange('', '');

    setState(() {
      inRange = '$inRangeAwait%';
      borderColor = borderColorAwait;
      timeLastUpdated = 'Last updated: ${DateTime.now().toLocal()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Time in range'),
            centerTitle: false,
            titleTextStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: borderColor,
                  border: Border.all(
                    color: borderColor,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  inRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                timeLastUpdated,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _getPercentInRange,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
