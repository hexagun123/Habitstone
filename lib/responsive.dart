// responsive.dart

import 'package:flutter/material.dart';

/// A utility class for simple responsive UI checks.
class Responsive {
  // just return if one side of the screen is less than 800 pixels
  static bool isOverFlow(BuildContext context) =>
      MediaQuery.of(context).size.width < 800 ||
      MediaQuery.of(context).size.height < 800;
}