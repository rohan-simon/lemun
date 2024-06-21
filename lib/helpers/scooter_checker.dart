import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lemun/models/city.dart';
import 'package:lemun/models/lime.dart';
import 'package:lemun/models/link_scooter.dart';
import 'package:lemun/providers/scooter_provider.dart';

class ScooterChecker {

  final ScooterProvider scooterProvider;
  var _latitude = 49.4404395;
  var _longitude = 11.0760811;
  var _city = Cities.seattle;

  ScooterChecker(this.scooterProvider);

  /// Updates the location that the Link API uses
  /// parameters:
  ///  - latitude: The latitude to update
  ///  - longitude: The longitude to update
  updateLocation({required latitude, required longitude})  {
    _latitude = latitude;
    _longitude = longitude;
  }

  /// Gets the current list of the Link scooters based on the user's
  /// current position, updating the scooter provider
  fetchLinkScooter() async {

    var client = http.Client();
    try {
      var latitude = _latitude.toString();
      var longitude = _longitude.toString();

      // connect to Link API
      final linkResponse = await client.get(
        Uri.parse('https://vehicles.linkyour.city/reservation-api/local-vehicles/?format=json&latitude=$latitude&longitude=$longitude')
      );
      final linkParsed = (jsonDecode(linkResponse.body));

      // Convert json to Link list
      final List<LinkScooter> links = (linkParsed['vehicles'] as List)
        .map((vehicle) => LinkScooter.fromJson(vehicle)).toList();

      // Update scooter provider
      scooterProvider.updateLinks(links);

    } catch (e) {
      // ignore: avoid_print
      print(e);
    }finally {
      client.close();
    }
  }

  /// Gets the current list of the Lime vehicles based on the user's
  /// currently selected city, updating the scooter provider
  fetchLime() async {
    var client = http.Client();
    _city = scooterProvider.city;
    try {
      // Connect to lime API
      var limeResponse = await client.get(
        Uri.parse('https://data.lime.bike/api/partners/v1/gbfs/${_city.name}/free_bike_status')
      );
      var limeParsed = (jsonDecode(limeResponse.body));

      // convert json to Lime list
      final List<Lime> limes = (limeParsed['data']?['bikes'] as List)
          .map((vehicle) => Lime.fromJson(vehicle)).toList();

      // update scooter provider
      scooterProvider.updateLimes(limes);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      client.close();
    } 
  }
}