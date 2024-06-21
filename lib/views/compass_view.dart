import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lemun/models/bus_stop.dart';
import 'package:lemun/models/vehicle.dart';
import 'package:lemun/models/vehicle_types.dart';
import 'package:lemun/providers/position_provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';


// This class is the compass view for when the user taps on a map marker.
// It shows the vehicle type that was selected, a real-time compass pointing
// in the direction of the marker, distance from that marker, and other 
// relevant information.
class CompassView extends StatefulWidget {  
  final Vehicle vehicle;
  final double latitude;
  final double longitude;

  CompassView({super.key, required this.vehicle}): latitude = vehicle.latitude, longitude = vehicle.longitude;

  @override
  State<CompassView> createState() => _CompassViewState();
}



class _CompassViewState extends State<CompassView> {
  bool _hasPermissions = false;

  // Initialises compass view's state.
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Pins compass view in portrait orientation
    _fetchPermissionStatus();
  }

  // Restores our orientation.
  @override
  void dispose() {
    restoreOrientation();
    super.dispose();
  }

  // Restores orientation when disposing. Code copied from https://github.com/flutter/flutter/issues/119473.
  Future<bool> restoreOrientation() async {
    // restore multiple orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // then all wanted orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return true;
  }

  // Returns double representing user's distance (in metres) to selected vehicle.
  // Parameters:
  // - double myLat: user's latitude coordinate
  // - double myLong: user's longitude coordinate
  double _getDistance(double myLat, double myLong) {
    return 100000 * math.sqrt(_squared(myLat - widget.latitude) + _squared(myLong - widget.longitude));
  }

  // This helper function takes the provided distance and returns it as a formatted String.
  // If the provided distance (in metres) is greater than 1000, converts to kilometres;
  // (e.g. an input of distance = 1435 will return the String '1.4 km').
  // Parameter:
  // - double distance: distance value (in metres) to convert into a String
  String _distanceToString(double distance) {
    if (distance > 1000) {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
    return '${distance.toStringAsFixed(0)} m';
  }

  // Returns a String representation of the vehicle's type.
  // Used for the app bar's title.
  // No parameters.
  String _vehicleTypeAsString() {
    final vehicle = widget.vehicle;
    String stringRep = '';
    if (vehicle is Lime) {
      stringRep += 'Lime';
    } else if (vehicle is LinkScooter) {
      stringRep += 'Link';
    } else if (vehicle is BusStop) {
      stringRep += 'Bus Stop';
    } else {
      throw Exception('Invalid action'); // Impossible case
    }
    switch(vehicle.vehicleType) {
      case VehicleType.bike: stringRep += ' Bike';
      case VehicleType.scooter: stringRep += ' Scooter';
      case VehicleType.bus: break; // Do nothing
      case VehicleType.none: throw Exception('Invalid action');
    }
    return stringRep;
  }

  // Returns true if provided vehicle is available, false otherwise.
  // Throws an exception if current vehicle type is 'none'.
  // No parameters.
  bool _availStatus() {
    final vehicle = widget.vehicle;
    if (vehicle is LinkScooter) {
      return vehicle.vehicleStatus == 'available';
    } else if (vehicle is Lime) {
      return !vehicle.isDisabled && !vehicle.isReserved; // Ensures that the Lime vehicle is both enabled and not reserved.
    } else if (vehicle is BusStop) {
      return true; // Bus stops are assumed available; note that this function should not be called on bus stops.
    }
    throw Exception('Invalid vehicle');
  }

  // Returns a double representation of the vehicle's bearing (0-360)
  // from a given latitude and longitude where 0 is north and 180 is south.
  // Parameters:
  // - double myLat: user's latitude
  // - double myLong: user's longitude
  double _getBearing(double myLat, double myLong) {
    double dLon = (widget.longitude - myLong);
    
    double x = math.cos(_degrees2Radians(widget.latitude)) * math.sin(_degrees2Radians(dLon));
    double y = math.cos(_degrees2Radians(myLat)) * math.sin(_degrees2Radians(widget.latitude)) 
             - math.sin(_degrees2Radians(myLat)) * math.cos(_degrees2Radians(widget.latitude)) * math.cos(_degrees2Radians(dLon));
    double bearing = math.atan2(x, y);
    return _radians2Degrees(bearing);
  }

  // Helper function; converts provided double from radians to degrees and returns.
  // Parameter:
  // - double x: the value to convert
  double _radians2Degrees(double x) {
    return x * 180 / math.pi;
  }

  // Helper function; converts provided double from degrees to radians and returns.
  // Parameter:
  // - double x: the value to convert
  double _degrees2Radians(double x) {
    return x / 180 * math.pi;
  }

  // Helper function; defines a square function. Returns the square of a provided number x.
  // Parameter:
  // - double x: the value to square
  double _squared(double x) {
    return x * x;
  }

  // Generates a UI accent colour according to vehicle's operator/maintainer.
  // Colours are generally associated with 'official colours' of whatever
  // service is operating/maintaining the vehicle (e.g. Lime vehicles are a 
  // lime green colour). No parameters.
  Color _getAccentColor() {
    final vehicle = widget.vehicle;
    if (vehicle is Lime) {
      return const Color.fromARGB(255, 100, 218, 65);
    } else if (vehicle is LinkScooter) {
      return const Color.fromARGB(255, 234, 254, 82);
    } else if (vehicle is BusStop) {
      return const Color.fromARGB(255, 53, 110, 134);
    }
    return Colors.white;
  }

  // Generates a UI text colour according to vehicle's operator/maintainer.
  // Colour choices are white or black and are chosen based on contrast.
  // No parameters.
  Color _getTextColor() {
    final vehicle = widget.vehicle;
    if (vehicle is Lime || vehicle is LinkScooter) {
      return Colors.black;
    }
    return Colors.white;
  }

  // Returns an icon corresponding to the vehicle's type.
  // No parameters.
  IconData _getIcon() {
    switch (widget.vehicle.vehicleType) {
      case VehicleType.bike: return Icons.directions_bike;
      case VehicleType.scooter: return Icons.electric_scooter;
      case VehicleType.bus: return Icons.directions_bus;
      default: return Icons.help;
    }
  }

  // Builds the UI from the provided context.
  @override
  Widget build(BuildContext context) {
    DateTime updatedAt = DateTime.now();
    Color accentColor = _getAccentColor();
    Color textColor = _getTextColor();
    return Scaffold(
      backgroundColor: Colors.white,
      // App bar
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black,
        iconTheme: IconThemeData(
          color: textColor,
        ),
        backgroundColor: accentColor,
        title: Semantics(
          label: _vehicleTypeAsString(),
          child: ExcludeSemantics(
            child: Row(
              children: [
                Text(
                  '${_vehicleTypeAsString()} ',
                  style: TextStyle(color: textColor),
                ),
                Icon(_getIcon(), color: textColor)
              ],
            ),
          ),
        ),
      ),

      // Body
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status or bus stop name at top of body (depends on vehicle)
          Builder(
            builder:(context) {
              if (_hasPermissions) {
                if (widget.vehicle is BusStop) { // Builds bus stop name widget if vehicle type is a bus stop...
                  String busStopName = (widget.vehicle as BusStop).name;
                  busStopName = busStopName.substring(1, busStopName.length - 1);
                  return _buildBusStopName(busStopName);
                } else if (widget.vehicle is Lime || widget.vehicle is LinkScooter) { // ... otherwise builds a status widget
                  return _buildStatus(updatedAt);
                } else {
                  throw Exception("Invalid vehicle type: ${widget.vehicle}"); // Case should not be possible
                }
              }
              return _buildBusStopName('⚠️ Location Permissions Disabled'); // Case where permissions are disabled (should not be possible)
            }
          ),
          // Compass and distance text
          Consumer<PositionProvider>(
            builder: (context, positionProvider, child) {
              if (_hasPermissions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    _buildCompass(positionProvider), // Compass
                    const SizedBox(height: 10),
                    // Distance text
                    Semantics(
                      label: 'Approximately ${_distanceToString(_getDistance(positionProvider.latitude, positionProvider.longitude))} away',
                      child: ExcludeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            alignment: Alignment.center,
                            padding: //const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                                        const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 
                                                    math.min(accentColor.red + 16, 255), 
                                                    math.min(accentColor.green + 31, 255),
                                                    math.min(accentColor.blue + 38, 255)),
                              borderRadius: const BorderRadius.all(Radius.circular(50))
                            ),
                            child: Text(
                              '~${_distanceToString(_getDistance(positionProvider.latitude, positionProvider.longitude))} away',
                              style: TextStyle(fontSize: 20, color: textColor),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                // Case where permissions are not enabled; should not be possible.
                return _buildPermissionSheet();
              }
            },
          ),
        ],
      ),
    );
  }

  // Builds a widget representing a scrolling bus stop text box from the provided name.
  // Parameter:
  // - String name: bus stop's name
  Widget _buildBusStopName(String name) {
    return Semantics(
      label: 'Station name: $name',
      excludeSemantics: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color:Color.fromARGB(255, 69, 141, 172),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: TextScroll(
            '$name          ',
            textAlign: TextAlign.center,
            velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
            mode: TextScrollMode.endless,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            )
          ),
        )
      ),
    );
  }

  // Converts the provided time into a semantics label and returns it as a String.
  // Only considers hour and minutes.
  // Parameter:
  // - DateTime time: the time to convert into a semantics label
  String _timeAsSemantics(DateTime time) {
    String label = '';
    bool isAfternoon = false;
    if (time.hour == 0) {
      label = '12';
    } else if (time.hour == 12) {
      label = '12';
      isAfternoon = true;
    } else if (time.hour > 12) {
      label = '${time.hour % 12}';
      isAfternoon = true;
    } else {
      label = '${time.hour}';
    }
    if (time.minute < 10) {
      label = '$label:0${time.minute}';
    } else {
      label = '$label:${time.minute}';
    }
    if (isAfternoon) {
      label = '$label p.m.';
    } else {
      label = '$label a.m.';
    }
    return label;
  }

  // Builds a widget representing a scooter or bike's status text.
  // Parameter:
  // - DateTime updatedAt: time the vehicle's status was last updated
  Widget _buildStatus(DateTime updatedAt) {
    Color accentColor = const Color.fromARGB(255, 248, 221, 86);
    bool isAvailable = _availStatus();
    String statusText = isAvailable ? 'Status: Available ' : 'Status: Unavailable ';
    IconData icon = isAvailable ? Icons.check_circle_rounded : Icons.remove_circle_rounded;
    Color iconColor = isAvailable ? Colors.green : Colors.red;
    String minute = updatedAt.minute.toString();
    if (updatedAt.minute < 10) {
      minute = '0$minute';
    }
    return Semantics(
      label: '$statusText, Last updated at ${_timeAsSemantics(updatedAt)}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  boxShadow: const [BoxShadow(
                    color: Color.fromARGB(255, 167, 167, 167),
                    offset: Offset(2.0, 2.0),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  )],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )
                        ),
                        Icon(
                          icon,
                          color: iconColor,
                        )
                      ],
                    ),
                    Text(
                      'Last updated ${updatedAt.hour}:$minute',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 59, 59, 59),
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds compass from given position provider.
  // Parameter:
  // - PositionProvider positionProvider: the position provider
  Widget _buildCompass(PositionProvider positionProvider) {
    return Semantics(
      label: 'Lemon Compass, currently pointed at the selected ${_vehicleTypeAsString()}',
      child: ExcludeSemantics(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error reading heading: ${snapshot.error}');
            }
        
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        
            double? direction = snapshot.data!.heading;
        
            // if direction is null, then device does not support this sensor
            // show error message
            if (direction == null) {
              return const Center(
                child: Text("Device does not have sensors !"),
              );
            }
            return Transform.rotate(
              angle: (_degrees2Radians(direction) * -1 + _degrees2Radians(_getBearing(positionProvider.latitude, positionProvider.longitude))),
              child: const Image(image: AssetImage('lib/assets/lemun_compass.png'))
            );
          },
        ),
      ),
    );
  }

  // Builds a permission sheet (should not be encountered by user) with
  // a button that takes user to their settings app and requests location.
  // No parameters.
  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Location Permission Required'),
          ElevatedButton(
            child: const Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  // Fetches user's permission status.
  Future<void> _fetchPermissionStatus() async {
    var perm = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _hasPermissions = perm;
    });
  }
}