class Area {
  static const String tableName = 'Area';
  static const String urlCsv = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Farea_code+%3Farea_code_type+%3Farea_name+count%28%3Fresource_uri%29+as+%3Ftotal_occurrences+count%28%3Fstock_resource_uri%29+as+%3Fstock_occurrences+count%28%3Ffishery_resource_uri%29+as+%3Ffishery_occurrences%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E+%0D%0AWHERE+%7B+%0D%0A%09%7B%0D%0A%09++%3Fstock_resource_uri+rdf%3Atype+crm%3AStock.%0D%0A%09++%3Fstock_resource_uri+crm%3AO15_occupied+%3Farea_uri.%0D%0A%09++%3Farea_uri+crm%3Ahas_area_code+%3Farea_code.%0D%0A%09++%3Farea_uri+rdfs%3Alabel+%3Farea_name.%0D%0A%09++%3Farea_uri+crm%3Ahas_area_type+%3Farea_code_type.%0D%0A%09%7D%0D%0A%09UNION%0D%0A%09%7B%0D%0A%09++%3Ffishery_resource_uri+rdf%3Atype+crm%3ABC62_Capture_Activity.%0D%0A%09++%3Ffishery_resource_uri+crm%3AO15_occupied+%3Farea_uri.%0D%0A%09++%3Farea_uri+crm%3Ahas_area_code+%3Farea_code.%0D%0A%09++%3Farea_uri+rdfs%3Alabel+%3Farea_name.%0D%0A%09++%3Farea_uri+crm%3Ahas_area_type+%3Farea_code_type.%0D%0A%09%7D%0D%0A%09UNION%0D%0A%09%7B%0D%0A%09++%3Fresource_uri+crm%3AO15_occupied+%3Farea_uri.%0D%0A%09++%3Farea_uri+crm%3Ahas_area_code+%3Farea_code.%0D%0A%09++%3Farea_uri+rdfs%3Alabel+%3Farea_name.%0D%0A%09++%3Farea_uri+crm%3Ahas_area_type+%3Farea_code_type.%0D%0A%09%7D%0D%0A%7DGROUP+BY+%3Farea_code+%3Farea_code_type+%3Farea_name+%0D%0AORDER+BY+DESC%28%3Ftotal_occurrences%29&format=text%2Fcsv&timeout=0';  

  final int id;
  final String? areaCode;
  final String? areaCodeType;
  final String? areaName;
  final String? totalOccurrences;
  final String? stockOccurrences;
  final String? fisheryOccurrences;

  // Constructor for the Area class
  Area({
    required this.id,
    this.areaCode,
    this.areaCodeType,
    this.areaName,
    this.totalOccurrences,
    this.stockOccurrences,
    this.fisheryOccurrences,
  });

  // Convert an Area object to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'area_code': areaCode,
      'area_code_type': areaCodeType,
      'area_name': areaName,
      'total_occurrences': totalOccurrences,
      'stock_occurrences': stockOccurrences,
      'fishery_occurrences': fisheryOccurrences,
    };
  }

  // Convert a map to an Area object (used when reading data from the database)
  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id'],
      areaCode: map['area_code'],
      areaCodeType: map['area_code_type'],
      areaName: map['area_name'],
      totalOccurrences: map['total_occurrences'],
      stockOccurrences: map['stock_occurrences'],
      fisheryOccurrences: map['fishery_occurrences'],
    );
  }

  // Copy method to create a new Area object with some modified fields
  Area copyWith({
    int? id,
    String? areaCode,
    String? areaCodeType,
    String? areaName,
    String? totalOccurrences,
    String? stockOccurrences,
    String? fisheryOccurrences,
  }) {
    return Area(
      id: id ?? this.id,
      areaCode: areaCode ?? this.areaCode,
      areaCodeType: areaCodeType ?? this.areaCodeType,
      areaName: areaName ?? this.areaName,
      totalOccurrences: totalOccurrences ?? this.totalOccurrences,
      stockOccurrences: stockOccurrences ?? this.stockOccurrences,
      fisheryOccurrences: fisheryOccurrences ?? this.fisheryOccurrences,
    );
  }
}
