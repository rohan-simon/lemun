import 'draw_actions/draw_actions.dart';

// This class represents the drawing, built up from a list of draw actions.
class Drawing {
  final double width;
  final double height;

  final List<DrawAction> drawActions;

  Drawing(this.drawActions, {required this.width, required this.height});
}