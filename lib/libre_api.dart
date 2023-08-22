import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LibrelinkClient {
  String username;
  String password;
  String url;
  String version;
  late Map<String, String> headers;
  late String jwtToken;
  late double lowBound;
  late double highBound;
  String? patientId;

  LibrelinkClient(this.username, this.password,
      {this.url = 'https://api-eu2.libreview.io', this.version = '4.7.0'}) {
    headers = {
      'product': 'llu.android',
      'version': version,
      'accept-encoding': 'gzip',
      'cache-control': 'no-cache',
      'connection': 'Keep-Alive',
      'content-type': 'application/json',
    };
    login();
    lowBound = 3.5;
    highBound = 8.5;
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('$url/llu/auth/login'),
      headers: headers,
      body: jsonEncode({'email': username, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login: ${response.body}');
    }
    final data = jsonDecode(response.body);
    jwtToken = data['data']['authTicket']['token'].toString();
    headers['Authorization'] = 'Bearer $jwtToken';
  }

  Future<String> getPatientId() async {
    final response = await http.get(
      Uri.parse('$url/llu/connections'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get patient ID: ${response.body}');
    }
    final connections = jsonDecode(response.body);
    return connections['data'][0]['patientId'].toString();
  }

  Future getCgmData() async {
    patientId ??= await getPatientId();
    final response = await http.get(
      Uri.parse('$url/llu/connections/$patientId/graph'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get CGM data: ${response.body}');
    }
    final cgmData = jsonDecode(response.body);
    return cgmData;
  }

  Future getLogbookData() async {
    patientId ??= await getPatientId();
    final response = await http.get(
      Uri.parse('$url/llu/connections/$patientId/logbook'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get logbook data: ${response.body}');
    }
    final logbookData = jsonDecode(response.body);
    return logbookData;
  }

  Future getLatestReading() async {
    final cgmData = await getCgmData();
    final latestReading = cgmData['data']['connection']['glucoseItem']['Value'];
    return latestReading;
  }

  bool isInRange(double reading, String d) {
    // bool inRange = lowBound <= reading && reading <= highBound;
    // print('Reading: $reading, $inRange, $d');
    return lowBound <= reading && reading <= highBound;
  }

  Future<String> percentageInRange() async {
    final cgmData = await getCgmData();
    final graphData = cgmData['data']["graphData"] as List<dynamic>;
    final now = DateTime.now();
    final last24Hours = now.subtract(Duration(hours: 24));
    final readingsInLast24Hours = [
      for (var d in graphData)
        if (DateFormat('M/d/y h:m:s a')
                .parse(d['Timestamp'].toString())
                .isAfter(last24Hours) &&
            d['Value'] != null)
          d
    ];

    final percentInRange = ((100.0 *
                readingsInLast24Hours
                    .where((d) => isInRange(double.parse(d['Value'].toString()),
                        d['Timestamp'].toString()))
                    .length) /
            readingsInLast24Hours.length)
        .toStringAsFixed(1);
    return percentInRange;
  }
}

const String appGroupId = 'libreappgroup';
const String iOSWidgetName = 'NewsWidgets';
const String androidWidgetName = 'NewsWidget';

// New: add this function
void addToStore(String percentInRange) {
  // Set the group ID
  HomeWidget.setAppGroupId(appGroupId);

  final timestamp_seconds = DateFormat('h:mm:ss a').format(DateTime.now());
  HomeWidget.saveWidgetData<String>('percent_in_range', percentInRange);
  HomeWidget.updateWidget(
    iOSName: iOSWidgetName,
    androidName: androidWidgetName,
  );
}

Future<(String, Color)> getPercentInRange(
    String username, String password) async {
  final client = LibrelinkClient(username, password);
  await client.login();
  final percentInRange = await client.percentageInRange();
  // red if < 70%, green if > 70%
  final color = double.parse(percentInRange) < 70 ? Colors.red : Colors.green;
  return (percentInRange, color);
}
