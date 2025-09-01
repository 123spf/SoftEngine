/// A collection of units of measurement for conversion.
enum Unit {
  meters,
  kilometers,
  grams,
  kilograms,
  feet,
  miles,
  pounds,
  ounces
}

/// An exception thrown when a conversion is attempted between two incompatible units.
class IncompatibleUnitsException implements Exception {
  final Unit fromUnit;
  final Unit toUnit;

  /// A message describing the incompatible conversion attempt.
  final String message;

  IncompatibleUnitsException(this.fromUnit, this.toUnit)
      : message = "Cannot convert from ${fromUnit.name} to ${toUnit.name}";

  @override
  String toString() => message;
}

/// An exception thrown for internal configuration errors within the [Conversion]
/// utility, such as a missing or misconfigured conversion factor.
class ConversionSetupException implements Exception {
  /// A message describing the specific setup error.
  final String message;

  ConversionSetupException(this.message);

  @override
  String toString() => "ConversionSetupException: $message";
}

/// A utility class that provides static methods for unit conversions.
class Conversion {
  static final Map<Unit, Map<Unit, double>> _conversionFactors = {
    // Length
    Unit.meters: {
      Unit.meters: 1,
      Unit.kilometers: 0.001,
      Unit.feet: 3.28084,
      Unit.miles: 0.000621371,
    },
    Unit.kilometers: {
      Unit.meters: 1000,
      Unit.kilometers: 1,
      Unit.feet: 3280.84,
      Unit.miles: 0.621371,
    },
    Unit.feet: {
      Unit.meters: 0.3048,
      Unit.kilometers: 0.0003048,
      Unit.feet: 1,
      Unit.miles: 0.000189394,
    },
    Unit.miles: {
      Unit.meters: 1609.344,
      Unit.kilometers: 1.60934,
      Unit.feet: 5280,
      Unit.miles: 1,
    },
    // Mass
    Unit.grams: {
      Unit.grams: 1,
      Unit.kilograms: 0.001,
      Unit.pounds: 0.00220462,
      Unit.ounces: 0.035274,
    },
    Unit.kilograms: {
      Unit.grams: 1000,
      Unit.kilograms: 1,
      Unit.pounds: 2.20462,
      Unit.ounces: 35.274,
    },
    Unit.pounds: {
      Unit.grams: 453.59237,
      Unit.kilograms: 0.453592,
      Unit.pounds: 1,
      Unit.ounces: 16,
    },
    Unit.ounces: {
      Unit.grams: 28.3495,
      Unit.kilograms: 0.0283495,
      Unit.pounds: 0.0625,
      Unit.ounces: 1,
    },
  };

  Conversion._();

  /// Converts a numeric [inputValue] from a [fromUnit] to a [toUnit].
  ///
  /// Throws an [IncompatibleUnitsException] if the units cannot be converted.
  /// Throws a [ConversionSetupException] if the internal conversion matrix
  /// is misconfigured for the requested units.
  static double convert(double inputValue, Unit fromUnit, Unit toUnit) {
    // Check if a conversion map exists for the 'from' unit.
    if (!_conversionFactors.containsKey(fromUnit)) {
      throw ConversionSetupException(
          "Conversion factors matrix missing configuration for unit: ${fromUnit.name}");
    }

    final Map<Unit, double> multipliers = _conversionFactors[fromUnit]!;

    // Check if the 'from' unit's map has a conversion for the 'to' unit.
    final double? multiplier = multipliers[toUnit];

    if (multiplier == null) {
      throw IncompatibleUnitsException(fromUnit, toUnit);
    }

    return inputValue * multiplier;
  }
}
