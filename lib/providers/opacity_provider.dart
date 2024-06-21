import 'package:flutter/material.dart';

class OpacityProvider extends ChangeNotifier {
  Opacity canvas = const Opacity(opacity: 0.0,);
  bool showCanvas = false;
  AppBar? appBar;
  Widget? drawer;

  /// Toggles app between two states: showing the drawing canvas and not showing it
  updateCanvas(Opacity canv, bool show, AppBar? bar, Widget? drwr) {
    canvas = canv;
    showCanvas = show;
    appBar = bar;
    drawer = drwr;
    notifyListeners();
  }
}