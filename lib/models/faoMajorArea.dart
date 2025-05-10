class FaoMajorArea {
  static const String tableName = 'FaoMajorArea';
  static const String urlCsv = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0APREFIX+mtlo%3A+%3Chttp%3A%2F%2Fwww.ics.forth.gr%2Fisl%2Fontology%2FMarineTLO%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Ffao_major_area_concat+%3Ffao_major_area_code+%3Ffao_major_area_name%0D%0AFROM+%3Chttp%3A%2F%2FgrsfVocabularies%3E+%0D%0AWHERE+%7B+%0D%0A%09++%3Fwater_area_uri+rdf%3Atype+mtlo%3ABC15_Water_Area.%0D%0A%09++%3Fwater_area_uri+rdf%3Atype+mtlo%3ABC15_Water_Area.%0D%0A%09++%3Fwater_area_uri+mtlo%3ALC1_is_identified_by+%3Fwater_area_code_uri.%0D%0A%09++%3Fwater_area_code_uri+rdf%3Atype+mtlo%3ABC32_Identifier.%0D%0A%09++%3Fwater_area_code_uri+mtlo%3ALX3_has_type+%3Fwater_area_code_type_uri.%0D%0A%09++%3Fwater_area_code_type_uri+rdfs%3Alabel+%22fao%22.%0D%0A%09++%3Fwater_area_code_uri+rdfs%3Alabel+%3Ffao_major_area_code.%0D%0A%09++%3Fwater_area_uri+rdfs%3Alabel+%3Ffao_major_area_name%0D%0A%09++FILTER%28%21CONTAINS%28%3Ffao_major_area_code%2C%22.%22%29%29%0D%0A%09++FILTER%28%21CONTAINS%28%3Ffao_major_area_code%2C%22-%22%29%29%0D%0A%09++BIND%28CONCAT%28%22fao%3A%22%2C%3Ffao_major_area_code%29+as+%3Ffao_major_area_concat%29%0D%0A%7D%0D%0AORDER+BY+ASC%28%3Ffao_major_area_code%29&format=text%2Fcsv&timeout=0';
  final int id;
  final String? faoMajorAreaConcat;
  final String? faoMajorAreaCode;
  final String? faoMajorAreaName;

  FaoMajorArea({
    required this.id,
    this.faoMajorAreaConcat,
    this.faoMajorAreaCode,
    this.faoMajorAreaName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'area_code': faoMajorAreaConcat,
      'area_code_type': faoMajorAreaCode,
      'area_name': faoMajorAreaName,
    };
  }

  factory FaoMajorArea.fromMap(Map<String, dynamic> map) {
    return FaoMajorArea(
      id: map['id'],
      faoMajorAreaConcat: map['fao_major_area_concat'],
      faoMajorAreaCode: map['fao_major_area_code'],
      faoMajorAreaName: map['fao_major_area_name'],
    );
  }

  FaoMajorArea copyWith({
    int? id,
    String? faoMajorAreaConcat,
    String? faoMajorAreaCode,
    String? faoMajorAreaName,
  }) {
    return FaoMajorArea(
      id: id ?? this.id,
      faoMajorAreaConcat: faoMajorAreaConcat ?? this.faoMajorAreaConcat,
      faoMajorAreaCode: faoMajorAreaCode ?? this.faoMajorAreaCode,
      faoMajorAreaName: faoMajorAreaName ?? this.faoMajorAreaName,
    );
  }
}
