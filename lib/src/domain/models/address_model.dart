import 'package:pet_match/src/api/here_map_api.dart';

class Address {
  String? id;
  String? address;
  double? longitude;
  double? latitude;
  String? geohash;

  Address({this.id, this.address, this.longitude, this.latitude, this.geohash});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    geohash = json['geohash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['geoHash'] = geohash;
    return data;
  }

  Address.fromHereMapApi(HereMapResponse response) {
    address = response.address!.label;
    latitude = response.position!.lat;
    longitude = response.position!.lng;
  }
}
