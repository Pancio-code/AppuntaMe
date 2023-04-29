// @dart=2.9

class HelperFunctions {
  static String getValidPhoneNumber(Iterable phoneNumbers) {
    if (phoneNumbers != null && phoneNumbers.toList().isNotEmpty) {
      List phoneNumbersList = phoneNumbers.toList();
      // This takes first available number. Can change this to display all
      // numbers first and let the user choose which one use.
      return phoneNumbersList[0].value;
    }
    return null;
  }
}