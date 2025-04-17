import 'dart:ui';

class Utils {
  static Map<String, dynamic> colorToParams(Color color) {
    return {
      'red': color.red,
      'green': color.green,
      'blue': color.blue,
      'alpha': color.alpha,
    };
  }
}