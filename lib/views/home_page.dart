import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lemun/helpers/scooter_checker.dart';
import 'package:lemun/models/bus_stop.dart';
import 'package:lemun/models/vehicle.dart';
import 'package:lemun/providers/drawing_provider.dart';
import 'package:lemun/providers/opacity_provider.dart';
import 'package:lemun/providers/position_provider.dart';
import 'package:lemun/views/city_selector.dart';
import 'package:lemun/views/draw_area.dart';
import 'package:lemun/views/palette.dart';
import 'package:provider/provider.dart';
import 'package:lemun/providers/scooter_provider.dart';
import 'package:lemun/views/map_view.dart';


// ignore: must_be_immutable
class HomePage extends StatefulWidget {

  HomePage({super.key, required this.busStops});
  bool showCanvas = false;
  final List<BusStop> busStops;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Timer _checkerTimer;
  late final ScooterChecker _sc;
  final _backgroundColor = const Color.fromARGB(255, 248, 221, 86);

  @override
  Widget build(BuildContext context) {

    return Consumer3<ScooterProvider, OpacityProvider, PositionProvider>(
      builder: (context, scooterProvider, opacityProvider, positionProvider, child) {

        // Get all vehicles from provider
        List<Vehicle> limes = scooterProvider.limes ?? [];
        List<Vehicle> links = scooterProvider.links ?? [];

        // Add all vehicles to one list
        List<Vehicle> allVehicles = [];
        for (Vehicle busStop in widget.busStops) { 
          allVehicles.add(busStop);
        }
        for (Vehicle lime in limes) {
          allVehicles.add(lime);
        }
        for (Vehicle link in links) {
          allVehicles.add(link);
        }

        return Scaffold(
          appBar: opacityProvider.appBar,
          drawer: Semantics(
            label: (opacityProvider.showCanvas) 
                  ? 'Color selector' 
                  : 'City selector',
            child: opacityProvider.drawer),
          body: Center(
            child: Stack(
              children: [
                MapView(vehicles: allVehicles, showLegend: !opacityProvider.showCanvas),
                Semantics(label: 'canvas', child: opacityProvider.canvas),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();

    // Get non-listening providers
    final singleUseScooterProvider = Provider.of<ScooterProvider>(context, listen: false);    
    final singleUseOpacityProvider = Provider.of<OpacityProvider>(context, listen: false);
    final singleUsePositionProvider = Provider.of<PositionProvider>(context, listen: false);

    // Initial state of app is no canvas shown
    singleUseOpacityProvider.appBar = _buildAppBar(context, true);
    singleUseOpacityProvider.drawer = Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 235, 137),
      child: CitySelector(context)
    );

    // get initial scooter and bike list
    _sc = ScooterChecker(singleUseScooterProvider);
    _sc.updateLocation(latitude: singleUsePositionProvider.latitude, longitude: singleUsePositionProvider.longitude);
    _sc.fetchLinkScooter();
    _sc.fetchLime();

    // update bike and scooter list periodically so it is up to date
    _checkerTimer = Timer.periodic(
      const Duration(seconds: 60), 
      (timer) { 
        _sc.updateLocation(latitude: singleUsePositionProvider.latitude, longitude: singleUsePositionProvider.longitude);
        _sc.fetchLinkScooter();
        _sc.fetchLime();
      }
    );
  }
  @override 
  dispose(){
    super.dispose();
    _checkerTimer.cancel();
  }

  /// Clears the canvas
  _clear(BuildContext context) {
    final nonListen = Provider.of<DrawingProvider>(context, listen: false);
    nonListen.clear();
  }

  /// Toggles whether canvas is shown or not
  _showHideCanvas(BuildContext context) {
    final nonListen = Provider.of<OpacityProvider>(context, listen: false);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Opacity canvas;
    AppBar appBar = _buildAppBar(context, nonListen.showCanvas);
    Widget? drawer;

    if (nonListen.showCanvas) {
      canvas = const Opacity(opacity: 0.0);
      drawer = Drawer(
        backgroundColor: const Color.fromARGB(255, 255, 235, 137),
        child: CitySelector(context)
      );
    } else {
      canvas = Opacity(
        opacity: 0.99,
        child: DrawArea(width: width, height: height)
      );
      drawer = SizedBox(
        width: math.min(200, MediaQuery.of(context).size.width),
        child: Drawer(
          backgroundColor: const Color.fromARGB(255, 255, 235, 137),
          child: Palette(context),
        ),
      );
    }
    nonListen.updateCanvas(canvas, !nonListen.showCanvas, appBar, drawer);
  }

  /// Build the appbar based on whether the canvas should be on or off
  AppBar _buildAppBar(BuildContext context, bool showCanvas) {
    // Default look, 1 button to show the canvas
    if (showCanvas) {
      return AppBar(
        backgroundColor: _backgroundColor,
        elevation: 4,
        shadowColor: Colors.black,
        title: Semantics(
          label: 'Lemon',
          child: const ExcludeSemantics(
            child: Text(
              'LemÚn',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Color.fromARGB(255, 55, 37, 58)
              )
            )
          )
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 237, 147),
                  shape: BoxShape.circle,
                ),
              child: Semantics(
                label: 'Button. Enter drawing mode. Double tap to activate.',
                child: ExcludeSemantics(
                  child: IconButton(
                    onPressed: () => _showHideCanvas(context),
                    icon: const Icon(Icons.edit)
                  ),
                ),
              ),
            ),
          )
        ]
      );
    }

    // Button to display the canvas has been tapped. Show button to clear and exit, title, and a color drawer.
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 4,
      shadowColor: Colors.black,
      title: const Text('Path draw'),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 237, 147),
              shape: BoxShape.circle,
            ),
            child: Semantics(
              label: 'Button. Clear and exit drawing mode. Double tap to activate.',
              child: ExcludeSemantics(
                child: IconButton(
                  onPressed: () {_clear(context); _showHideCanvas(context);}, 
                  icon: const Icon(Icons.clear)
                ),
              ),
            ),
          ),
        ),
      ]
    );
  }
}