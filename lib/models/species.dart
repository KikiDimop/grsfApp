class Species {  
  static const String tableName = 'Species';
  static const String urlCsv = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Fspecies_code+%3Fspecies_code_type+%3Fspecies_name+count%28%3Fresource_uri%29+as+%3Ftotal_occurrences+count%28%3Fstock_resource_uri%29+as+%3Fstock_occurrences+count%28%3Ffishery_resource_uri%29+as+%3Ffishery_occurrences+%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E+%0D%0AWHERE+%7B+%0D%0A%09%7B%0D%0A%09++%3Fstock_resource_uri+rdf%3Atype+crm%3AStock.%0D%0A%09++%3Fstock_resource_uri+crm%3AP137_exemplifies+%3Fspecies_uri.%0D%0A%09++%3Fspecies_uri+crm%3Ahas_species_code+%3Fspecies_code.%0D%0A%09++%3Fspecies_uri+rdfs%3Alabel+%3Fspecies_name.%0D%0A%09++%3Fspecies_uri+crm%3Ahas_species_type+%3Fspecies_code_type.%0D%0A%09%7D%0D%0A%09UNION%0D%0A%09%7B%0D%0A%09++%3Ffishery_resource_uri+rdf%3Atype+crm%3ABC62_Capture_Activity.%0D%0A%09++%3Ffishery_resource_uri+crm%3AP137_exemplifies+%3Fspecies_uri.%0D%0A%09++%3Fspecies_uri+crm%3Ahas_species_code+%3Fspecies_code.%0D%0A%09++%3Fspecies_uri+rdfs%3Alabel+%3Fspecies_name.%0D%0A%09++%3Fspecies_uri+crm%3Ahas_species_type+%3Fspecies_code_type.%0D%0A%09%7D%0D%0A%09UNION%0D%0A%09%7B%0D%0A%09++%3Fresource_uri+crm%3AP137_exemplifies+%3Fspecies_uri.%0D%0A%09++%3Fspecies_uri+crm%3Ahas_species_code+%3Fspecies_code.%0D%0A%09++%3Fspecies_uri+rdfs%3Alabel+%3Fspecies_name.%0D%0A%09++%3Fspecies_uri+crm%3Ahas_species_type+%3Fspecies_code_type.%0D%0A%09%7D%0D%0A%7DGROUP+BY+%3Fspecies_code+%3Fspecies_code_type+%3Fspecies_name%0D%0AORDER+BY+DESC%28%3Ftotal_occurrences%29&format=text%2Fcsv&timeout=0';
  
  final int? id;
  final String? speciesCode;
  final String? speciesCodeType;
  final String? speciesName;
  final String? totalOccurrences;
  final String? stockOccurrences;
  final String? fisheryOccurrences;

  // Constructor for the Species class
  Species({
    this.id,
    this.speciesCode,
    this.speciesCodeType,
    this.speciesName,
    this.totalOccurrences,
    this.stockOccurrences,
    this.fisheryOccurrences,
  });

  // Convert a Species object to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species_code': speciesCode,
      'species_code_type': speciesCodeType,
      'species_name': speciesName,
      'total_occurrences': totalOccurrences,
      'stock_occurrences': stockOccurrences,
      'fishery_occurrences': fisheryOccurrences,
    };
  }

  // Convert a map to a Species object (used when reading data from the database)
  factory Species.fromMap(Map<String, dynamic> map) {
    return Species(
      id: map['id'],
      speciesCode: map['species_code'],
      speciesCodeType: map['species_code_type'],
      speciesName: map['species_name'],
      totalOccurrences: map['total_occurrences'],
      stockOccurrences: map['stock_occurrences'],
      fisheryOccurrences: map['fishery_occurrences'],
    );
  }

  // Copy method to create a new Species object with some modified fields
  Species copyWith({
    int? id,
    String? speciesCode,
    String? speciesCodeType,
    String? speciesName,
    String? totalOccurrences,
    String? stockOccurrences,
    String? fisheryOccurrences,
  }) {
    return Species(
      id: id ?? this.id,
      speciesCode: speciesCode ?? this.speciesCode,
      speciesCodeType: speciesCodeType ?? this.speciesCodeType,
      speciesName: speciesName ?? this.speciesName,
      totalOccurrences: totalOccurrences ?? this.totalOccurrences,
      stockOccurrences: stockOccurrences ?? this.stockOccurrences,
      fisheryOccurrences: fisheryOccurrences ?? this.fisheryOccurrences,
    );
  }
}
