import 'package:flutter/material.dart';
import 'package:lemun/models/draw_actions/actions/null_action.dart';

import '../models/draw_actions/draw_actions.dart';
import '../models/drawing.dart';
import '../models/tools.dart';

class DrawingProvider extends ChangeNotifier {
  Drawing? _drawing; // used to create a cached drawing via replay of past actions
  DrawAction _pendingAction = NullAction();
  Tools _toolSelected = Tools.stroke;
  Color _colorSelected = Colors.red;

  final List<DrawAction> _pastActions;
  final List<DrawAction> _futureActions;

  final double width;
  final double height;

  DrawingProvider({required this.width, required this.height})
      : _pastActions = [],
        _futureActions = [];

  Drawing get drawing {
    if (_drawing == null) {
      _createCachedDrawing();
    }
    return _drawing!;
  }

  /// Queues the given action
  /// paramaters:
  ///  - action: the action to queue
  set pendingAction(DrawAction action) {
    _pendingAction = action;
    _invalidateAndNotify();
  }

  DrawAction get pendingAction => _pendingAction;

  /// Sets the current tool to the provided tool
  /// paramaters:
  ///  - aTool: the tool to use
  set toolSelected(Tools aTool) {
    _toolSelected = aTool;
    _invalidateAndNotify();
  }

  Tools get toolSelected => _toolSelected;

  /// Sets the current color to the provided color
  /// paramaters:
  ///  - color: the color to set our tool to
  set colorSelected(Color color) {
    _colorSelected = color;
    _invalidateAndNotify();
  }
  Color get colorSelected => _colorSelected;

  /// Creates a drawing using all of the past actions
  _createCachedDrawing() {
    List<DrawAction> actions = _pastActions;

    // Handle if a clear happened
    if (_pastActions.contains(ClearAction())) {
      int i;
      for (i = _pastActions.length - 1; i > 0; i--) {
        if (_pastActions.elementAt(i) == ClearAction()) {
          break;
        }
      }
      actions = _pastActions.getRange(i, _pastActions.length).toList();
    }

    _drawing = Drawing(
      actions, 
      width: width, 
      height: height,
    );
  }

  /// Invalidates our current drawing and updates all listeners
  _invalidateAndNotify() {
    _drawing = null;
    notifyListeners();
  }

  /// Clears the canvas. Is undoable.
  clear() {
    if (_pastActions.isEmpty || _pastActions.last is ClearAction) {
      return;
    }
    _pastActions.add(ClearAction());
    _createCachedDrawing();
    notifyListeners();
  }

  /// Adds the pending stroke to the canvas
  addPending() {
    _pastActions.add(_pendingAction);
    _pendingAction = NullAction();
    _futureActions.clear();
    _createCachedDrawing();
  }
}
