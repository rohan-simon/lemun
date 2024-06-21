import 'package:flutter/material.dart';
import 'package:lemun/models/city.dart';
import 'package:lemun/models/vehicle.dart';

class ScooterProvider extends ChangeNotifier {
  List<LinkScooter>? links;
  List<Vehicle>? limes;
  bool hasUpdated = false;
  Cities _city = Cities.seattle;

  Cities get city => _city;

  set city(Cities city) {
    _city = city;
    notifyListeners();
  }

  /// Updates the LinkScooter list with the most current version
  /// paramaters:
  ///  - updatedLink: the new list to use
  updateLinks(List<LinkScooter> updatedLink) {
    links = updatedLink;
    hasUpdated = true;
    notifyListeners();
  }
  /// Updates the Lime list with the most current version
  /// paramaters:
  ///  - updatedLime: the new list to use
  updateLimes(List<Lime> updatedLime) {
    limes = updatedLime;
    hasUpdated = true;
    notifyListeners();
  }
}