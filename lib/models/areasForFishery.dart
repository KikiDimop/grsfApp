class AreasForFishery {
  static const String tableName = 'AreasForFishery';
  static const String urlCsv =
      'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0ASELECT+DISTINCT+%3Fuuid+%3Farea_type+%3Farea_code+%3Farea_name%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AWHERE%7B%0D%0A++%3Frecord+a+crm%3ABC62_Capture_Activity.%0D%0A++%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A++%3Frecord+crm%3AO15_occupied+%3Farea_uri.%0D%0A++%3Farea_uri+rdfs%3Alabel+%3Farea_name.%0D%0A++%3Farea_uri+crm%3Ahas_area_code+%3Farea_code.%0D%0A++%3Farea_uri+crm%3Ahas_area_type+%3Farea_type.%0D%0A%7D&format=text%2Fcsv&timeout=0';
  final int? id;
  final String? uuid;
  final String? areaType;
  final String? areaCode;
  final String? areaName;

  AreasForFishery({
    this.id,
    this.uuid,
    this.areaType,
    this.areaCode,
    this.areaName,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'uuid': uuid,
  //     'areaType': areaType,
  //     'areaCode': areaCode,
  //     'areaName': areaName,
  //   };
  // }

  factory AreasForFishery.fromMap(Map<String, dynamic> map) {
    return AreasForFishery(
      id: map['id'],
      uuid: map['uuid'],
      areaType: map['area_type'],
      areaCode: map['area_code'],
      areaName: map['area_name'],
    );
  }

  factory AreasForFishery.fromJson(Map<String, dynamic> json) {
    return AreasForFishery(
      areaType: json['assessment_area_type'],
      areaCode: json['assessment_area_code'],
      areaName: json['assessment_area_name'],
    );
  }

  // AreasForFishery copyWith({
  //   int? id,
  //   String? uuid,
  //   String? areaType,
  //   String? areaCode,
  //   String? areaName,
  // }) {
  //   return AreasForFishery(
  //     id: id ?? this.id,
  //     uuid: uuid ?? this.uuid,
  //     areaType: areaType ?? this.areaType,
  //     areaCode: areaCode ?? this.areaCode,
  //     areaName: areaName ?? this.areaName,
  //   );
  // }
}
