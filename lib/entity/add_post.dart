import 'package:kakikomi_keijiban/common/constants.dart';

class AddPost {
  AddPost() {
    titleValue = '';
    bodyValue = '';
    nicknameValue = '';
    emotionDropdownValue = kPleaseSelect;
    selectedCategory = '';
    selectedCategories = [];
    positionDropdownValue = kPleaseSelect;
    genderDropdownValue = kPleaseSelect;
    ageDropdownValue = kPleaseSelect;
    areaDropdownValue = kPleaseSelect;
  }

  String titleValue = '';
  String bodyValue = '';
  String nicknameValue = '';
  String emotionDropdownValue = kPleaseSelect;
  String selectedCategory = '';
  List<String> selectedCategories = [];
  String positionDropdownValue = kPleaseSelect;
  String genderDropdownValue = kPleaseSelect;
  String ageDropdownValue = kPleaseSelect;
  String areaDropdownValue = kPleaseSelect;
}
