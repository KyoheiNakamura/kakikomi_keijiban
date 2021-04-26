import 'package:kakikomi_keijiban/common/constants.dart';

class AddReply {
  AddReply() {
    this.bodyValue = '';
    this.nicknameValue = '';
    this.positionDropdownValue = kPleaseSelect;
    this.genderDropdownValue = kPleaseSelect;
    this.ageDropdownValue = kPleaseSelect;
    this.areaDropdownValue = kPleaseSelect;
  }

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;
}
