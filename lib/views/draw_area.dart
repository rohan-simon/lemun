
import 'package:flutter/material.dart';
import 'package:lemun/models/draw_actions/actions/null_action.dart';
import 'package:lemun/models/draw_actions/actions/stroke_action.dart';
import 'package:lemun/models/tools.dart';
import 'package:lemun/providers/drawing_provider.dart';
import 'package:provider/provider.dart';

import 'drawing_painter.dart';

class DrawArea extends StatelessWidget {
  const DrawArea({super.key, required this.width, required this.height});

  final double width, height;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, unchangingChild) {
        return CustomPaint(
          size: Size(width, height),
          painter: DrawingPainter(drawingProvider),
          child: GestureDetector(
              onPanStart: (details) => _panStart(details, drawingProvider),
              onPanUpdate: (details) => _panUpdate(details, drawingProvider),
              onPanEnd: (details) => _panEnd(details, drawingProvider),
              child: Container(
                  width: width,
                  height: height,
                  color: Colors.transparent,
                  child: unchangingChild)),
        );
      },
    );
  }

  /// called when stroke starts
  void _panStart(DragStartDetails details, DrawingProvider drawingProvider) {
    final currentTool = drawingProvider.toolSelected;

    switch (currentTool) {
      case Tools.none:
        drawingProvider.pendingAction = NullAction();
        break;
      case Tools.stroke:
        // add a new stroke action to our pending action
        drawingProvider.pendingAction = StrokeAction(
          [details.localPosition], 
          drawingProvider.colorSelected
        );
        break;
      default:
        throw UnimplementedError('Tool not implemented: $currentTool');
    }
  }

  /// called when stroke is being dragged
  void _panUpdate(DragUpdateDetails details, DrawingProvider drawingProvider) {
    final currentTool = drawingProvider.toolSelected;
    
    switch (currentTool) {
      case Tools.none:
        break;
      case Tools.stroke:
        // update the stroke list to include the current location
        final pendingAction = drawingProvider.pendingAction as StrokeAction;
        List<Offset> points = pendingAction.points;
        points.add(details.localPosition);
        drawingProvider.pendingAction = StrokeAction(
          points,
          pendingAction.color
        );
        break;
      default:
        throw UnimplementedError('Tool not implemented: $currentTool');
    }
  }

  /// Ends the stroke and adds it to the list of actions
  void _panEnd(DragEndDetails details, DrawingProvider drawingProvider) {
    // push our changes to our undo list
    drawingProvider.addPending();
  }
}
