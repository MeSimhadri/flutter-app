import '../../common/constants.dart';

class DeliveryUser {
  int? id;
  String? profilePicture;
  String? name;

  DeliveryUser.fromJson(json) {
    id = int.parse(json['id']?.toString() ?? '-1');
    name = json['name'] ?? '';
    profilePicture = json['profile_picture'] ?? kDefaultImage;
  }
}
