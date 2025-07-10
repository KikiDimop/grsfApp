class Gear {
  static const String tableName = 'Gear';
  static const String urlCsv =
      'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0APREFIX+mtlo%3A+%3Chttp%3A%2F%2Fwww.ics.forth.gr%2Fisl%2Fontology%2FMarineTLO%2F%3E%0D%0ASELECT+DISTINCT+%3Ffishing_gear_type+%3Ffishing_gear_id+%3Ffishing_gear_abbreviation+%3Ffishing_gear_name+%3Ffishing_gear_group_type+%3Ffishing_gear_group_id+%3Ffishing_gear_group_name%0D%0AFROM+%3Chttp%3A%2F%2FgrsfVocabularies%3E%0D%0AWHERE%7B%0D%0A%09++%3Ffishing_gear_uri+a+mtlo%3ABT11_Equipment_Type.%0D%0A%09++%3Ffishing_gear_uri+mtlo%3ALX1_is_identified_by+%3Ffishing_gear_id_uri.%0D%0A%09++%3Ffishing_gear_id_uri+rdfs%3Alabel+%3Ffishing_gear_id.%0D%0A%09++%3Ffishing_gear_id_uri+mtlo%3ALX3_has_type+%3Ffishing_gear_type_uri.%0D%0A%09++%3Ffishing_gear_type_uri+rdfs%3Alabel+%3Ffishing_gear_type.%0D%0A%09++FILTER%28%3Ffishing_gear_type%21%3D%22abbreviation%22+%26%26+%3Ffishing_gear_type%21%3D%22current%22%29.%0D%0A%09++OPTIONAL%7B+%0D%0A%09%09++%3Ffishing_gear_uri+mtlo%3ALX1_is_identified_by+%3Ffishing_gear_abbr_uri.%0D%0A%09%09++%3Ffishing_gear_abbr_uri+rdfs%3Alabel+%3Ffishing_gear_abbreviation.%0D%0A%09%09++%3Ffishing_gear_abbr_uri+mtlo%3ALX3_has_type+%3Ffishing_gear_abbr_type_uri.%0D%0A%09%09++%3Ffishing_gear_abbr_type_uri+rdfs%3Alabel+%3Ffishing_gear_abbr_type.%0D%0A%09%09++FILTER%28%3Ffishing_gear_abbr_type%3D%22abbreviation%22%29.%0D%0A%09++%7D%0D%0A%09++%3Ffishing_gear_uri+mtlo%3ALX4_has_appellation+%3Ffishing_gear_name_uri.%0D%0A%09++%3Ffishing_gear_name_uri+rdfs%3Alabel+%3Ffishing_gear_name.%0D%0A%09++%3Ffishing_gear_name_uri+mtlo%3ALX8_has_language+%3Flanguage_uri.%0D%0A%09++%3Flanguage_uri+rdfs%3Alabel+%3Flanguage.%0D%0A%09++FILTER%28%3Flanguage%3D%22english%22%29%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Ffishing_gear_uri+mtlo%3ALT8_usually_belongs_to+%3Ffishing_gear_group_uri.%0D%0A%09%09%3Ffishing_gear_group_uri+mtlo%3ALX1_is_identified_by+%3Ffishing_gear_group_id_uri.%0D%0A%09++++%3Ffishing_gear_group_id_uri+rdfs%3Alabel+%3Ffishing_gear_group_id.%0D%0A%09%09%3Ffishing_gear_group_id_uri+mtlo%3ALX3_has_type+%3Ffishing_gear_group_type_uri.%0D%0A%09%09%3Ffishing_gear_group_type_uri+rdfs%3Alabel+%3Ffishing_gear_group_type.%0D%0A%09%09%3Ffishing_gear_group_uri+mtlo%3ALX4_has_appellation+%3Ffishing_gear_group_name_uri.%0D%0A%09%09%3Ffishing_gear_group_name_uri+rdfs%3Alabel+%3Ffishing_gear_group_name.%0D%0A%09%09%3Ffishing_gear_group_name_uri+mtlo%3ALX8_has_language+%3Fgroup_language_uri.%0D%0A%09%09%3Fgroup_language_uri+rdfs%3Alabel+%3Flanguage.%0D%0A%09++%7D%0D%0A%7D&format=text%2Fcsv&timeout=0';
  final int? id;
  final String? fishingGearType;
  final String? fishingGearId;
  final String? fishingGearAbbreviation;
  final String? fishingGearName;
  final String? fishingGearGroupType;
  final String? fishingGearGroupId;
  final String? fishingGearGroupName;

  // Constructor for the Gear class
  Gear({
    this.id,
    this.fishingGearType,
    this.fishingGearId,
    this.fishingGearAbbreviation,
    this.fishingGearName,
    this.fishingGearGroupType,
    this.fishingGearGroupId,
    this.fishingGearGroupName,
  });

  // Convert a Gear object to a map for database operations
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'fishing_gear_type': fishingGearType,
  //     'fishing_gear_id': fishingGearId,
  //     'fishing_gear_abbreviation': fishingGearAbbreviation,
  //     'fishing_gear_name': fishingGearName,
  //     'fishing_gear_group_type': fishingGearGroupType,
  //     'fishing_gear_group_id': fishingGearGroupId,
  //     'fishing_gear_group_name': fishingGearGroupName,
  //   };
  // }

  // Convert a map to a Gear object (used when reading data from the database)
  factory Gear.fromMap(Map<String, dynamic> map) {
    return Gear(
      id: map['id'],
      fishingGearType: map['fishing_gear_type'],
      fishingGearId: map['fishing_gear_id'],
      fishingGearAbbreviation: map['fishing_gear_abbreviation'],
      fishingGearName: map['fishing_gear_name'],
      fishingGearGroupType: map['fishing_gear_group_type'],
      fishingGearGroupId: map['fishing_gear_group_id'],
      fishingGearGroupName: map['fishing_gear_group_name'],
    );
  }

  factory Gear.fromJson(Map<String, dynamic> json) {
    return Gear(
      fishingGearType: json['fishing_gear_type'],
      fishingGearId: json['fishing_gear_code'],
      fishingGearName: json['fishing_gear_name'],
    );
  }

  // Copy method to create a new Gear object with some modified fields
  // Gear copyWith({
  //   int? id,
  //   String? fishingGearType,
  //   String? fishingGearId,
  //   String? fishingGearAbbreviation,
  //   String? fishingGearName,
  //   String? fishingGearGroupType,
  //   String? fishingGearGroupId,
  //   String? fishingGearGroupName,
  // }) {
  //   return Gear(
  //     id: id ?? this.id,
  //     fishingGearType: fishingGearType ?? this.fishingGearType,
  //     fishingGearId: fishingGearId ?? this.fishingGearId,
  //     fishingGearAbbreviation:
  //         fishingGearAbbreviation ?? this.fishingGearAbbreviation,
  //     fishingGearName: fishingGearName ?? this.fishingGearName,
  //     fishingGearGroupType: fishingGearGroupType ?? this.fishingGearGroupType,
  //     fishingGearGroupId: fishingGearGroupId ?? this.fishingGearGroupId,
  //     fishingGearGroupName: fishingGearGroupName ?? this.fishingGearGroupName,
  //   );
  // }
}
