// responsive.dart
// This file provides a simple utility class for handling responsive UI adjustments.
// It contains static methods to help widgets determine the screen size context,
// allowing for adaptive layouts based on available screen real estate.

import 'package:flutter/material.dart';

/// A utility class for simple responsive UI checks.
///
/// This class is not meant to be instantiated. It provides a collection of
/// static methods that can be called from anywhere in the widget tree to query
/// the screen dimensions and make layout decisions accordingly.
class Responsive {
  /// Determines if the screen size is below a specific threshold.
  ///
  /// This method is useful for layouts that are optimized for larger screens
  /// (like desktops or tablets) and need to adapt to a more constrained view
  /// on smaller devices (like mobile phones). It helps prevent UI overflow
  /// by allowing widgets to switch to a more compact layout.
  ///
  /// Returns `true` if the screen width is less than 800 pixels or the screen
  /// height is less than 800 pixels, `false` otherwise.
  static bool isOverFlow(BuildContext context) =>
      MediaQuery.of(context).size.width < 800 ||
      MediaQuery.of(context).size.height < 800;
}