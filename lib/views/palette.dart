
import 'package:flutter/material.dart';
import 'package:lemun/providers/drawing_provider.dart';
import 'package:provider/provider.dart';

class Palette extends StatelessWidget {
  const Palette(BuildContext context, {super.key});

  
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawingProvider, unchangingChild) => ListView(
        scrollDirection: Axis.vertical,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Semantics(
              label: 'Select color',
              hint: 'currently selected: ${_colourAsString(drawingProvider.colorSelected)}',
              excludeSemantics: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Color', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 5),
                  Container(
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: drawingProvider.colorSelected,
                      border: Border.all(
                        width: 0.5,
                        color: const Color.fromARGB(255, 94, 94, 94),
                        style: BorderStyle.solid,
                      )
                    )
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color.fromARGB(255, 213, 192, 74)),
          
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.fromLTRB(16.0, 3.0, 16.0, 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorButton('Black', Colors.black, drawingProvider),
                _buildColorButton('White', Colors.white, drawingProvider),
                _buildColorButton('Red', Colors.red, drawingProvider),
                _buildColorButton('Orange', Colors.orange, drawingProvider),
                _buildColorButton('Yellow', Colors.yellow, drawingProvider),
                _buildColorButton('Green', Colors.green, drawingProvider),
                _buildColorButton('Blue', Colors.blue, drawingProvider),
                _buildColorButton('Purple', Colors.purple, drawingProvider),
              ],
            ),
          ),
          // colors
        ],
      ),
    );
  }

  // Returns String representation of the provided colour;
  // Only defined on basic colours for this app.
  // Parameter:
  // - Color colour: colour to get String representation of
  String _colourAsString(Color colour) {
    switch(colour) {
      case Colors.white: return 'white';
      case Colors.black: return 'black';
      case Colors.red: return 'red';
      case Colors.orange: return 'orange';
      case Colors.yellow: return 'yellow';
      case Colors.green: return 'green';
      case Colors.blue: return 'blue';
      case Colors.purple: return 'purple';
      default: return colour.toString();
    }
  }

  /// Builds a button to change the color
  /// paramaters:
  ///  - name: The name of the color
  ///  - color: The color to switch to
  ///  - provider: Drawing Provider to manage state
  Widget _buildColorButton(String name, Color color,  DrawingProvider provider) {
    bool selected = provider.colorSelected == color;

    return Semantics(
      button: true,
      selected: selected,
      label: 'colour: $name.',
      hint: 'Double tap to change colour to $name',
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          // manage state
          provider.colorSelected = color;
        },
        hoverColor: color,
        child: Row(
          children: [
            Stack(
              children: [
                 Container(
                  margin: const EdgeInsets.only(bottom: 5, right: 7),
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: color,
                    border: Border.all(
                      width: 0.5,
                      color: const Color.fromARGB(255, 94, 94, 94),
                      style: BorderStyle.solid,
                    )
                  )
                ),
              ],
            ),
            Text('$name  '),
            if (selected) const Icon(
              Icons.check,
              color: Colors.green,
            )
          ],
        )
      ),
    );
  }

}
