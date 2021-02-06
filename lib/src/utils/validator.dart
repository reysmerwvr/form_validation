bool isNumeric(String str) {
  if (str.isEmpty) return false;
  final numb = num.tryParse(str);
  return (numb != null) ? true : false;
}
