import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemun/models/bus_stop_db.dart';
import 'package:lemun/providers/drawing_provider.dart';
import 'package:lemun/providers/opacity_provider.dart';
import 'package:lemun/providers/position_provider.dart';
import 'package:lemun/providers/scooter_provider.dart';
import 'package:lemun/views/home_page.dart';
import 'package:provider/provider.dart';

Future<BusStopDB> loadBusStopDB(String dataPath) async {
  return BusStopDB.initializeFromCSV(await rootBundle.loadString(dataPath));
}


void main() {
  const busDataPath = 'lib/assets/bus_stops.csv';
  WidgetsFlutterBinding.ensureInitialized();
  loadBusStopDB(busDataPath).then((value) => runApp(LemunApp(value)));
}

// This class represents the Lemun App.
class LemunApp extends StatelessWidget {
  final BusStopDB _busStops;
  const LemunApp(this._busStops, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScooterProvider>(create: (context) => ScooterProvider()),
        ChangeNotifierProvider<PositionProvider>(create: (context) => PositionProvider()),
        ChangeNotifierProvider<DrawingProvider>(create: (context) => DrawingProvider(width: width, height: height)),
        ChangeNotifierProvider<OpacityProvider>(create: (context) => OpacityProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(busStops: _busStops.all)
      )
    );
  }
}