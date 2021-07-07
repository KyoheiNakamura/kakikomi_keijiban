import 'package:kakikomi_keijiban/common/constants.dart';

class AddReply {
  AddReply() {
    bodyValue = '';
    nicknameValue = '';
    positionDropdownValue = kPleaseSelect;
    genderDropdownValue = kPleaseSelect;
    ageDropdownValue = kPleaseSelect;
    areaDropdownValue = kPleaseSelect;
  }

  String bodyValue = '';
  String nicknameValue = '';
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;
}
