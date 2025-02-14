double convertData(double value, String fromUnit, String toUnit) {
  Map<String, double> units = {
    "Byte": 1,
    "Kilobyte": 1024,
    "Megabyte": 1024 * 1024,
    "Gigabyte": 1024 * 1024 * 1024,
    "Terabyte": 1024 * 1024 * 1024 * 1024,
    "Petabyte": 1024 * 1024 * 1024 * 1024 * 1024,
  };

  if (!units.containsKey(fromUnit) || !units.containsKey(toUnit)) {
    throw ArgumentError("Invalid unit");
  }

  double bytes = value * units[fromUnit]!; // Convert to bytes first
  return bytes / units[toUnit]!; // Convert to target unit
}
