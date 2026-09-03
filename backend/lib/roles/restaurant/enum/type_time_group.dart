enum TypeTimeGroup {
  day("day", "hour"),
  week("week", "day"),
  month("month", "day"),
  year("year", "month");

  final String value;
  final String unit;

  const TypeTimeGroup(this.value, this.unit);

  static TypeTimeGroup fromString(String timeGroup) {
    return TypeTimeGroup.values.firstWhere(
      (e) => e.value == timeGroup,
      orElse: () => TypeTimeGroup.month,
    );
  }
}