enum Gender implements Comparable<Gender> {
  male("Male"),
  female("Female"),
  other("Other");

  final String name;

  const Gender(this.name);

  static fromString(String gd) {
    return Gender.values.firstWhere(
      (g) => g.name.toLowerCase() == gd.toLowerCase(),
    );
  }

  @override
  int compareTo(Gender other) => name.compareTo(other.name);
}
