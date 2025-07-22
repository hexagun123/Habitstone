// 1. Update the Responsive widget implementation (create responsive.dart)
import 'package:flutter/material.dart';

class Responsive {
  static bool isOverFlow(BuildContext context) =>
      MediaQuery.of(context).size.width < 800 ||
      MediaQuery.of(context).size.height < 800;
}
