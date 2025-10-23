class DemoMeasurement {
  final double frequency;
  final double p1;
  final double p2;
  final double micDistance;

  // New fields
  final double? absorption; // Calculated value
  final String? sourceType; // "withSignal", "withoutSignal", "reference"

  DemoMeasurement({
    required this.frequency,
    required this.p1,
    required this.p2,
    required this.micDistance,
    this.absorption,
    this.sourceType,
  });
}
