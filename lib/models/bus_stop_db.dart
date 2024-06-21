import 'package:lemun/models/bus_stop.dart';

// This class represents a database of bus stops within King County
class BusStopDB {

  // The actual list of bus stops
  final List<BusStop> _busStops;

  // Gets all of the bus stops stored in the database
  List<BusStop> get all{
    return List<BusStop>.from(_busStops, growable: false);
  }


  // Takes in a String in csv format with all the bus stop information in king county and 
  //turns it into a list of bus stops to set up the database
  BusStopDB.initializeFromCSV(String csvString) : _busStops = _decodeBusStopList(csvString);


  // Private helper to parse csv string into a list of bus stops
  static List<BusStop> _decodeBusStopList(String csvString) {
    List<BusStop> busStops = [];
    var listOfRows = csvString.split('\n');

    for (var row in listOfRows) {
      List elemList = row.split(',');
      if (elemList.length > 1) {
        busStops.add(BusStop(name: elemList[2], latitude: double.parse(elemList[4]), longitude: double.parse(elemList[5])));
      }      
    }
    return busStops;
  }
}