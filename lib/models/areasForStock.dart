class AreasForStock {
  static const String tableName = 'AreasForStock';
  static const String urlCsv =
      'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0ASELECT+DISTINCT+%3Fuuid+%3Farea_type+%3Farea_code+%3Farea_name%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AWHERE%7B%0D%0A++%3Frecord+a+crm%3AStock.%0D%0A++%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A++%3Frecord+crm%3AO15_occupied+%3Farea_uri.%0D%0A++%3Farea_uri+rdfs%3Alabel+%3Farea_name.%0D%0A++%3Farea_uri+crm%3Ahas_area_code+%3Farea_code.%0D%0A++%3Farea_uri+crm%3Ahas_area_type+%3Farea_type.%0D%0A%7D&format=text%2Fcsv&timeout=0';

  final int? id;
  final String? uuid;
  final String? areaType;
  final String? areaCode;
  final String? areaName;

  AreasForStock({
    this.id,
    this.uuid,
    this.areaType,
    this.areaCode,
    this.areaName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'area_type': areaType,
      'area_code': areaCode,
      'area_name': areaName,
    };
  }

  factory AreasForStock.fromMap(Map<String, dynamic> map) {
    return AreasForStock(
      id: map['id'],
      uuid: map['uuid'],
      areaType: map['area_type'],
      areaCode: map['area_code'],
      areaName: map['area_name'],
    );
  }

  factory AreasForStock.fromJson(Map<String, dynamic> json) {
    return AreasForStock(
      areaType: json['assessment_area_type'],
      areaCode: json['assessment_area_code'],
      areaName: json['assessment_area_name'],
    );
  }
  AreasForStock copyWith({
    int? id,
    String? uuid,
    String? areasType,
    String? areasCode,
    String? areasName,
  }) {
    return AreasForStock(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      areaType: areasType ?? areaType,
      areaCode: areasCode ?? areaCode,
      areaName: areasName ?? areaName,
    );
  }
}
