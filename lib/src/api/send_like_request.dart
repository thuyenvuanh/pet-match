class ReactionRequest {
  String? comment;
  String? createdBy;
  String? profileId;

  ReactionRequest(
      {required this.createdBy, required this.profileId, this.comment,});

  ReactionRequest.fromJson(Map<String, dynamic> json) {
    comment = json['comment'];
    createdBy = json['created-by']!;
    profileId = json['profile-id']!;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['created-by'] = createdBy;
    data['profile-id'] = profileId;
    if (comment != null && comment!.trim().isNotEmpty) {
      data['comment'] = comment;
    }
    return data;
  }
}
