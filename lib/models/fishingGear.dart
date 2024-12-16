class Gear {
  static const String tableName = 'Gear';
  static const String urlCsv = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Ffishing_gear_code+%3Ffishing_gear_code_type+%3Ffishing_gear_name+count%28%3Fresource_uri%29+as+%3Foccurrences%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E+%0D%0AWHERE+%7B+%0D%0A++%3Fresource_uri+crm%3AP125_used_object_of_type+%3Ffishing_gear_uri.%0D%0A++%3Ffishing_gear_uri+crm%3Ahas_gear_code+%3Ffishing_gear_code.%0D%0A++%3Ffishing_gear_uri+rdfs%3Alabel+%3Ffishing_gear_name.%0D%0A++%3Ffishing_gear_uri+crm%3Ahas_gear_type+%3Ffishing_gear_code_type.%0D%0A%7DGROUP+BY+%3Ffishing_gear_code+%3Ffishing_gear_code_type+%3Ffishing_gear_name%0D%0AORDER+BY+DESC%28%3Foccurrences%29&format=text%2Fcsv&timeout=0';  

  final int? id;
  final String? fishingGearCode;
  final String? fishingGearCodeType;
  final String? fishingGearName;
  final String? occurrences;

  // Constructor for the Gear class
  Gear({
    this.id,
    this.fishingGearCode,
    this.fishingGearCodeType,
    this.fishingGearName,
    this.occurrences,
  });

  // Convert a Gear object to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishing_gear_code': fishingGearCode,
      'fishing_gear_code_type': fishingGearCodeType,
      'fishing_gear_name': fishingGearName,
      'occurrences': occurrences,
    };
  }

  // Convert a map to a Gear object (used when reading data from the database)
  factory Gear.fromMap(Map<String, dynamic> map) {
    return Gear(
      id: map['id'],
      fishingGearCode: map['fishing_gear_code'],
      fishingGearCodeType: map['fishing_gear_code_type'],
      fishingGearName: map['fishing_gear_name'],
      occurrences: map['occurrences'],
    );
  }

  // Copy method to create a new Gear object with some modified fields
  Gear copyWith({
    int? id,
    String? fishingGearCode,
    String? fishingGearCodeType,
    String? fishingGearName,
    String? occurrences,
  }) {
    return Gear(
      id: id ?? this.id,
      fishingGearCode: fishingGearCode ?? this.fishingGearCode,
      fishingGearCodeType: fishingGearCodeType ?? this.fishingGearCodeType,
      fishingGearName: fishingGearName ?? this.fishingGearName,
      occurrences: occurrences ?? this.occurrences,
    );
  }
}
