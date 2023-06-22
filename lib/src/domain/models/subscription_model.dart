// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:pet_match/src/utils/extensions.dart';

enum SubscriptionName {
  PREMIUM("PREMIUM"),
  STANDARD("STANDARD");

  final String name;
  const SubscriptionName(this.name);

  static SubscriptionName fromString(String name) {
    return SubscriptionName.values
        .firstWhere((element) => element.name == name);
  }
}

class Subscription extends Equatable {
  String? id;
  Duration? duration;
  SubscriptionName? name;
  DateTime? startFrom;
  String? status;

  Subscription({
    this.id,
    this.duration,
    this.name,
    this.startFrom,
    this.status,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    duration = Duration(days: json['duration']);
    name = SubscriptionName.fromString(json['name']);
    startFrom = DateFormat().parsePetMatch(json['start-from']);
    status = json['status'];
  }

  toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    if (duration != null) {
      data['duration'] = data['duration'] = duration!.inDays;
    }
    data['name'] = name!.name;
    data['start-from'] = DateFormat().formatPetMatch(startFrom!);
    data['status'] = status;
    return data;
  }

  bool isActive() {
    if (startFrom == null) return false;
    if (duration == null) return false;
    final endDate = startFrom!.add(duration!);
    final currentTime = DateTime.now();
    if (endDate.isAfter(currentTime) && name == SubscriptionName.PREMIUM) {
      return true;
    } else {
      return false;
    }
  }

  @override
  List<Object?> get props => [id, duration, name, startFrom, status];
}
