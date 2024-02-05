extension DoubleExt on double {
  double reduceByPercent({double percent = 1}) {
    final reducedVal = this*(100 - percent)/100;
    return reducedVal;
  }
}