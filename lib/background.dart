import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'libre_api.dart';

@pragma('vm:entry-point')
Future<void> onStartAsync() async {
  WidgetsFlutterBinding.ensureInitialized();
  while (true) {
    var (inRangeAwait, _) = await getPercentInRange('', '');
    var timeLastUpdated =
        'inRangeAwait: $inRangeAwait, Last updated: ${DateTime.now().toLocal()}';

    addToStore(inRangeAwait);
    print('updating timestamp $timeLastUpdated');
    // wait 15 minutes
    await Future.delayed(const Duration(seconds: 5 * 60));
    // await Future.delayed(const Duration(seconds: 10));
  }
}

@pragma('vm:entry-point')
void onStartIOS() {}

void startBackgroundUpdate() {
  final service = FlutterBackgroundService();
  service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will execute when the app is in foreground or background in a separated isolate
      onStart: onStartAsync,
      // onStart: onStartAndroid,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationTitle: 'LibreLink',
      foregroundServiceNotificationContent: 'Percent in range is running',
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,
      // this will execute when the app is in foreground in a separated isolate
      onForeground: onStartIOS,
      // you have to enable background fetch capability on xcode project
      onBackground: onStartIOS,
    ),
  );
  service.start();
}
