class SpeciesForStock {
  static const String tableName = 'SpeciesForStock';
  static const String urlCsv =
      'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0ASELECT+DISTINCT+%3Fuuid+%3Fspecies_type+%3Fspecies_code+%3Fspecies_name%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AWHERE%7B%0D%0A++%3Frecord+a+crm%3AStock.%0D%0A++%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A++%3Frecord+crm%3AP137_exemplifies+%3Fspecies_uri.%0D%0A++%3Fspecies_uri+crm%3Ahas_species_type+%3Fspecies_type.%0D%0A++%3Fspecies_uri+crm%3Ahas_species_code+%3Fspecies_code.%0D%0A++%3Fspecies_uri+rdfs%3Alabel+%3Fspecies_name.%0D%0A%7D&format=text%2Fcsv&timeout=0';

  final int? id;
  final String? uuid;
  final String? speciesType;
  final String? speciesCode;
  final String? speciesName;

  SpeciesForStock({
    this.id,
    this.uuid,
    this.speciesType,
    this.speciesCode,
    this.speciesName,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'uuid': uuid,
  //     'speciesType': speciesType,
  //     'speciesCode': speciesCode,
  //     'speciesName': speciesName,
  //   };
  // }

  factory SpeciesForStock.fromMap(Map<String, dynamic> map) {
    return SpeciesForStock(
      id: map['id'],
      uuid: map['uuid'],
      speciesType: map['species_type'],
      speciesCode: map['species_code'],
      speciesName: map['species_name'],
    );
  }

  factory SpeciesForStock.fromJson(Map<String, dynamic> json) {
    return SpeciesForStock(
      speciesType: json['species_type'],
      speciesCode: json['species_code'],
      speciesName: json['species_name'],
    );
  }

  // SpeciesForStock copyWith({
  //   int? id,
  //   String? uuid,
  //   String? speciesType,
  //   String? speciesCode,
  //   String? speciesName,
  // }) {
  //   return SpeciesForStock(
  //     id: id ?? this.id,
  //     uuid: uuid ?? this.uuid,
  //     speciesType: speciesType ?? this.speciesType,
  //     speciesCode: speciesCode ?? this.speciesCode,
  //     speciesName: speciesName ?? this.speciesName,
  //   );
  // }
}
