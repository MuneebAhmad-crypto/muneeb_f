class BMICalculator {
  static double calculateBMI(double heightCm, double weightKg) {
    double heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getCategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal Weight";
    } else if (bmi < 30) {
      return "Overweight";
    } else {
      return "Obese";
    }
  }
}