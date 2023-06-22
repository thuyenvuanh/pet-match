class SendPassRequest {
  String? createdBy;
  String? profile;

  SendPassRequest({this.createdBy, this.profile});

  SendPassRequest.fromJson(Map<String, dynamic> json) {
    createdBy = json['created-by'];
    profile = json['profile-id'];
  }

  toJson() {
    var data = <String, dynamic>{};
    data['created-by'] = createdBy;
    data['profile-id'] = profile;
    return data;
  }
}
