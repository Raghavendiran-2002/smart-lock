class PhoneNumberHelper {
  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 5) return phoneNumber;
    return phoneNumber.substring(0, 5) + " " + phoneNumber.substring(5);
  }

  String formatPhoneNumberWithCountryCode(
      String phoneNumber, int countryCodeLength) {
    String countryCode = phoneNumber.substring(0, countryCodeLength + 1);
    String formattedPhoneNum =
        formatPhoneNumber(phoneNumber.substring(countryCodeLength + 1));
    return countryCode + " " + formattedPhoneNum;
  }
}
