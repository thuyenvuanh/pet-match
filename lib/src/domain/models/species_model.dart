class Species {
  String? id;
  String? name;

  Species({this.id, this.name});

  Species.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "name": name.toString(),
    };
  }
}
