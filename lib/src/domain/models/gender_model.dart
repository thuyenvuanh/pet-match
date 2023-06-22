enum Gender implements Comparable<Gender> {
  male("Male", "Đực"),
  female("Female", "Cái"),
  other("Other", "Khác");

  final String name;
  final String vietnameseName;

  const Gender(this.name, this.vietnameseName);

  static fromString(String gd) {
    return Gender.values.firstWhere(
      (g) => g.name.toLowerCase() == gd.toLowerCase(),
    );
  }

  

  @override
  int compareTo(Gender other) => name.compareTo(other.name);
}
