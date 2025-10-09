import 'dart:convert';

class PlusCode {
  PlusCode({required this.compoundCode, required this.globalCode});

  String compoundCode;
  String globalCode;

  factory PlusCode.fromJson(String str) => PlusCode.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PlusCode.fromMap(Map<String, dynamic> json) => PlusCode(
    compoundCode: json["compound_code"],
    globalCode: json["global_code"],
  );

  Map<String, dynamic> toMap() => {
    "compound_code": compoundCode,
    "global_code": globalCode,
  };
}
