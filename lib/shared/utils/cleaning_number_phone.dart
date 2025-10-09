String cleaningNumberPhone(String phone) {
  RegExp exp = RegExp(r"[^0-9]");
  return phone.replaceAll(exp, '');
}
