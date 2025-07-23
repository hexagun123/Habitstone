// responsive.dart

import 'package:flutter/material.dart';

// responsive set up class to determine if something is overflow
// works nice and simple
class Responsive {
  static bool isOverFlow(BuildContext context) =>
      MediaQuery.of(context).size.width < 800 ||
      MediaQuery.of(context).size.height < 800;
}
