enum TypeTimeGroup {
  day("day"),
  week("week"),
  month("month"),
  year("year");

  final String value;
  const TypeTimeGroup(this.value);
  static TypeTimeGroup fromString(String timeGroup) {
    return TypeTimeGroup.values.firstWhere(
      (e) => e.value == timeGroup,
      orElse: () => TypeTimeGroup.month,
    );
  }
}