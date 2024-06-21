
import 'package:flutter/material.dart';
import 'package:lemun/models/draw_actions/actions/null_action.dart';
import 'package:lemun/models/draw_actions/draw_actions.dart';
import 'package:lemun/models/drawing.dart';
import 'package:lemun/providers/drawing_provider.dart';

class DrawingPainter extends CustomPainter {
  final Drawing _drawing;
  final DrawingProvider _provider;

  DrawingPainter(DrawingProvider provider) : _drawing = provider.drawing, _provider = provider;

  /// Paints the canvas based on the current drawing
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.clipRect(rect); // make sure we don't scribble outside the lines.

    final erasePaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRect(rect, erasePaint);

    for (final action in _provider.drawing.drawActions){
      _paintAction(canvas, action, size);
    }

    // Live view of stroke
    if (_provider.pendingAction is! NullAction) {
    _paintAction(canvas, _provider.pendingAction, size);
  }


  }

  /// Paints the particular action on the canvas
  void _paintAction(Canvas canvas, DrawAction action, Size size){
    final Rect rect = Offset.zero & size;
    final erasePaint = Paint()..blendMode = BlendMode.clear;

    switch (action) {
        case NullAction _:
          break;
        case ClearAction _:
          canvas.drawRect(rect, erasePaint);
          break;
        case StrokeAction strokeAction:
          final paint = Paint()..color = strokeAction.color
          ..strokeWidth = 2;
          // collect all the strokes in the action
          for (int i = 0; i < strokeAction.points.length - 1; i++) {
            canvas.drawLine(strokeAction.points[i], strokeAction.points[i+1], paint);
          }
          break;
        default:
          throw UnimplementedError('Action not implemented: $action'); 
      }
  }

  /// Determines whether the canvas should be repainted
  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate._drawing != _drawing;
  }
}
