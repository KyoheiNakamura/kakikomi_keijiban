import 'package:kakikomi_keijiban/common/constants.dart';

class AddPost {
  AddPost() {
    this.titleValue = '';
    this.bodyValue = '';
    this.nicknameValue = '';
    this.emotionDropdownValue = kPleaseSelect;
    this.selectedCategory = '';
    this.selectedCategories = [];
    this.positionDropdownValue = kPleaseSelect;
    this.genderDropdownValue = kPleaseSelect;
    this.ageDropdownValue = kPleaseSelect;
    this.areaDropdownValue = kPleaseSelect;
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
