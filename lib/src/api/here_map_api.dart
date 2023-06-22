class HereMapResponse {
  String? title;
  String? id;
  String? resultType;
  String? houseNumberType;
  Address? address;
  Position? position;
  List<Position>? access;
  MapView? mapView;
  bool? houseNumberFallback;
  Scoring? scoring;

  HereMapResponse(
      {this.title,
      this.id,
      this.resultType,
      this.houseNumberType,
      this.address,
      this.position,
      this.access,
      this.mapView,
      this.houseNumberFallback,
      this.scoring});

  HereMapResponse.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    id = json['id'];
    resultType = json['resultType'];
    houseNumberType = json['houseNumberType'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    position = json['position'] != null
        ? Position.fromJson(json['position'])
        : null;
    if (json['access'] != null) {
      access = <Position>[];
      json['access'].forEach((v) {
        access!.add(Position.fromJson(v));
      });
    }
    mapView =
        json['mapView'] != null ? MapView.fromJson(json['mapView']) : null;
    houseNumberFallback = json['houseNumberFallback'];
    scoring =
        json['scoring'] != null ? Scoring.fromJson(json['scoring']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['id'] = id;
    data['resultType'] = resultType;
    data['houseNumberType'] = houseNumberType;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (position != null) {
      data['position'] = position!.toJson();
    }
    if (access != null) {
      data['access'] = access!.map((v) => v.toJson()).toList();
    }
    if (mapView != null) {
      data['mapView'] = mapView!.toJson();
    }
    data['houseNumberFallback'] = houseNumberFallback;
    if (scoring != null) {
      data['scoring'] = scoring!.toJson();
    }
    return data;
  }
}

class Address {
  String? label;
  String? countryCode;
  String? countryName;
  String? county;
  String? city;
  String? district;
  String? street;
  String? postalCode;
  String? houseNumber;

  Address(
      {this.label,
      this.countryCode,
      this.countryName,
      this.county,
      this.city,
      this.district,
      this.street,
      this.postalCode,
      this.houseNumber});

  Address.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    countryCode = json['countryCode'];
    countryName = json['countryName'];
    county = json['county'];
    city = json['city'];
    district = json['district'];
    street = json['street'];
    postalCode = json['postalCode'];
    houseNumber = json['houseNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['countryCode'] = countryCode;
    data['countryName'] = countryName;
    data['county'] = county;
    data['city'] = city;
    data['district'] = district;
    data['street'] = street;
    data['postalCode'] = postalCode;
    data['houseNumber'] = houseNumber;
    return data;
  }
}

class Position {
  double? lat;
  double? lng;

  Position({this.lat, this.lng});

  Position.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class MapView {
  double? west;
  double? south;
  double? east;
  double? north;

  MapView({this.west, this.south, this.east, this.north});

  MapView.fromJson(Map<String, dynamic> json) {
    west = json['west'];
    south = json['south'];
    east = json['east'];
    north = json['north'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['west'] = west;
    data['south'] = south;
    data['east'] = east;
    data['north'] = north;
    return data;
  }
}

class Scoring {
  double? queryScore;
  FieldScore? fieldScore;

  Scoring({this.queryScore, this.fieldScore});

  Scoring.fromJson(Map<String, dynamic> json) {
    queryScore = json['queryScore'];
    fieldScore = json['fieldScore'] != null
        ? FieldScore.fromJson(json['fieldScore'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['queryScore'] = queryScore;
    if (fieldScore != null) {
      data['fieldScore'] = fieldScore!.toJson();
    }
    return data;
  }
}

class FieldScore {
  double? city;
  List<int>? streets;
  double? houseNumber;

  FieldScore({this.city, this.streets, this.houseNumber});

  FieldScore.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    streets = json['streets'].cast<int>();
    houseNumber = json['houseNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['streets'] = streets;
    data['houseNumber'] = houseNumber;
    return data;
  }
}
