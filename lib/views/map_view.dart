import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lemun/models/vehicle.dart';
import 'package:lemun/models/vehicle_types.dart';
import 'package:lemun/providers/position_provider.dart';
import 'package:lemun/views/compass_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Stateful class that displays a map with vehicle markers and a legend
// Allows users to filter through the legend buttons and move to their location
class MapView extends StatefulWidget {
  final List<Vehicle> vehicles;
  final bool showLegend;

  // Creates a MapView with a given list of vehicles on it
  // Parameters:
  //      vehicles: a list of Vehicle objects to display on the map
  const MapView({super.key, required this.vehicles, required this.showLegend});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  late final MapController _mapController; // Controls view of map
  bool _mapReady = false;
  bool _needsUpdate = true;
  LatLng _currentPosition = const LatLng(47.6061, -122.3328); // Default to Seattle;
  final double _defaultZoom = 17;

  // Set of displayed supported vehicle types
  final Set<VehicleType> _visibleVehicleTypes = {VehicleType.bike, VehicleType.scooter, VehicleType.bus};

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchPermissionStatus();
  }

  // called when map is ready to update current location
  void _onMapReady() {
    setState(() {
      _mapReady = true;
    });
    _updateCurrentLocation();
  }

  @override
  void dispose() {
    final positionProvider = Provider.of<PositionProvider>(context, listen: false);
    positionProvider.removeListener(_updateCurrentLocation);
    super.dispose();
  }

  // Update current location based on the position provider
  void _updateCurrentLocation() {
    if (_mapReady) {
      final positionProvider = Provider.of<PositionProvider>(context, listen: false);
      if (positionProvider.status) {
        _currentPosition = LatLng(positionProvider.latitude, positionProvider.longitude);
        if (_needsUpdate) {
          _mapController.moveAndRotate(_currentPosition, _defaultZoom, 0);
          setState(() {
            _needsUpdate = false;
          });
        }
      }
    }
  }

  // Returns the provided vehicle's type as a string.
  // Parameter:
  //      vehicle: the vehicle to turn into a String
  String _vehicleTypeAsString(Vehicle vehicle) {
    switch(vehicle.vehicleType) {
      case VehicleType.bike: return 'Bike';
      case VehicleType.scooter: return 'Scooter';
      case VehicleType.bus: return 'Bus Stop';
      default: throw Exception('Invalid vehicle');
    }
  }

  // Create a list of markers to place on the map signifying available vehicles
  // Parameters:
  //      vehicles: a list of Vehicle objects to create markers for
  // Returns: a list of marker widgets
  List<Marker> createVehicleMarkers(List<Vehicle> vehicles) {
    return vehicles
        .where((vehicle) => _visibleVehicleTypes.contains(vehicle.vehicleType))
        .map((vehicle) {
      return Marker(
        width: 70.0,
        height: 70.0,
        point: LatLng(vehicle.latitude, vehicle.longitude),
        child: Semantics(
          label: 'Marker: ${_vehicleTypeAsString(vehicle)}.',
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CompassView(vehicle: vehicle)));
            },
            child: Opacity(
              opacity: 0.75,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Opacity(opacity: 1, child: getVehicleIcon(vehicle.vehicleType)),
                ),
              ),
            )
          ),
        )
      );
    }).toList();
  }

  // Get an icon representing the given vehicle type
  // Parameters:
  //      type: the VehicleType to get an icon for
  // Returns: an Icon
  Icon getVehicleIcon(VehicleType type) {
    switch (type) {
    case VehicleType.bike:
      return const Icon(Icons.directions_bike, color: Colors.green, size: 25);
    case VehicleType.scooter:
      return const Icon(Icons.electric_scooter, color: Colors.orange, size: 25);
    case VehicleType.bus:
      return const Icon(Icons.directions_bus, color: Colors.blue, size: 25);
    default:
      return const Icon(Icons.location_on, color: Colors.red, size: 25);
    }
  }

  // Toggle the visiblility of a given vehicle type marker on the map
  // Parameters:
  //      type: the VehicleType to toggle
  void _toggleVehicleType(VehicleType type) {
    setState(() {
      if (_visibleVehicleTypes.contains(type)) {
        _visibleVehicleTypes.remove(type);
      } else {
        _visibleVehicleTypes.add(type);
      }
    });
  }

  // Create a legend that shows all vehicle type icons and whether they are visible
  // Returns: the legend widget
  Widget buildLegend() {

    var bikeColor = switch (_visibleVehicleTypes.contains(VehicleType.bike)) {
      true => Colors.green,
      false => Colors.grey
    };

    var scooterColor = switch (_visibleVehicleTypes.contains(VehicleType.scooter)) {
      true => Colors.orange,
      false => Colors.grey
    };

    var busColor = switch (_visibleVehicleTypes.contains(VehicleType.bus)) {
      true => Colors.blue,
      false => Colors.grey
    };

    return Semantics(
      label: 'Legend',
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 242, 175),
          boxShadow: [BoxShadow(
            color: Color.fromARGB(105, 1, 1, 1),
            offset: Offset(0, -2.0),
            blurRadius: 4.0,
            spreadRadius: 0,
          )],
        ),
        height: math.max(MediaQuery.of(context).size.height / 6.5, 120),
        width: double.infinity,
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Bike. ${bikeColor == Colors.grey ? 'currently not filtered' : 'currently filtered'}',
                      child: GestureDetector(
                        onTap: () {
                          _toggleVehicleType(VehicleType.bike);
                        },
                        child: ExcludeSemantics(child: legendItem(Icons.directions_bike, bikeColor, 'Bike'))
                      ),
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      label: 'Scooter. ${bikeColor == Colors.grey ? 'currently not filtered' : 'currently filtered'}',
                      child: GestureDetector(
                        onTap: () {
                          _toggleVehicleType(VehicleType.scooter);
                        },
                        child: ExcludeSemantics(child: legendItem(Icons.electric_scooter, scooterColor, 'Scooter'))
                      ),
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      label: 'Bus Stop. ${bikeColor == Colors.grey ? 'currently not filtered' : 'currently filtered'}',
                      child: GestureDetector(
                        onTap: () {
                          _toggleVehicleType(VehicleType.bus);
                        },
                        child: ExcludeSemantics(child: legendItem(Icons.directions_bus, busColor, 'Bus Stop'))
                      ),
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      label: 'Navigate to ',
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _needsUpdate = true;
                          });
                          _updateCurrentLocation();
                        },
                        child: legendItem(Icons.catching_pokemon, Colors.red, 'You')
                      ),
                    ),
                  ),
                ],
              ),
          ),
    );
    }

  // Create a singular legend Item for a given item
  // Parameters:
  //      iconData: the Icon to display for the item
  //      color: the color of the icon
  //      label: the text label of the item
  // Returns: a legend item widget
  Widget legendItem(IconData iconData, Color color, String label) {
    Color textColor = color == Colors.grey ? color : Colors.black;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: color, size: 48),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
          ),
        ],
    );
  }

  // Fetches user's permission status.
  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _mapReady = status == PermissionStatus.granted);
      }
    });
  }

  // Builds a permission sheet (should not be encountered by user) with
  // a button that takes user to their settings app and requests location.
  // No parameters.
  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Location Permissions Required', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: !widget.showLegend,
      child: Scaffold(
        body: Consumer<PositionProvider>(
          builder: (context, positionProvider, child) {
            
            if (!positionProvider.status && !positionProvider.loadFailure) {
              _fetchPermissionStatus();
              return const Center(child: CircularProgressIndicator());
            } else if (positionProvider.loadFailure) {
              return _buildPermissionSheet();
            }
      
            if (_mapReady) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateCurrentLocation();
              });
            }
            return Semantics(
              label: 'map view',
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  maxZoom: 19,
                  minZoom: 10,
                  initialCenter:  _currentPosition,
                  onMapReady: _onMapReady,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  Builder(
                    builder: (context) {
                      if (MapCamera.of(context).zoom > 16) {
                        return MarkerLayer(
                          markers: [
                            ...createVehicleMarkers(widget.vehicles),
                            Marker(
                              width: 40,
                              height: 40,
                              point: _currentPosition,
                              rotate: false,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.catching_pokemon, color: Colors.red, size: 40)),
                            )                    
                          ]
                        );
                      }
                      return MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: _currentPosition,
                            rotate: false,
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), 
                              child: const Icon(Icons.catching_pokemon, color: Colors.red, size: 40)),
                          )
                        ]
                      );
                    }
                  )
                ],
              ),
            );
          }
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            if (widget.showLegend) {
              return buildLegend();
            }
            return Container(height: 0);
          }
        ),
      ),
    );
  }
}
