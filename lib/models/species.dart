class Species {
  static const String tableName = 'Species';
  static const String urlCsv =
      'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0APREFIX+mtlo%3A+%3Chttp%3A%2F%2Fwww.ics.forth.gr%2Fisl%2Fontology%2FMarineTLO%2F%3E%0D%0ASELECT+DISTINCT+%3Fscientific_name+%3Fasfis_id+%3Faphia_id+%3Ffishbase_id+%3Ftsn_id+%3Fgbif_id+%3Ftaxonomic_id+%3Fiucn_id+%3Fiucn_characterization+%28GROUP_CONCAT%28%3Fcommon_name%3Bseparator%3D%22%3B%22%29+as+%3Fcommon_names%29%0D%0AFROM+%3Chttp%3A%2F%2FgrsfVocabularies%3E%0D%0AWHERE%7B%0D%0A%09++%3Fspecies_uri+a+mtlo%3ABT27_Species.%0D%0A%09++%3Fspecies_uri+mtlo%3ALX4_has_appellation+%3Fsc_name_uri.%0D%0A%09++%3Fsc_name_uri+rdfs%3Alabel+%3Fscientific_name.%0D%0A%09++%3Fsc_name_uri+mtlo%3ALX3_has_type+%3Fsc_name_type_uri.%0D%0A%09++%3Fsc_name_type_uri+rdfs%3Alabel+%3Fsc_name_type.%0D%0A%09++FILTER%28%3Fsc_name_type%3D%22scientific+name%22%29.%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Fasfis_id_uri.%0D%0A%09%09%3Fasfis_id_uri+rdfs%3Alabel+%3Fasfis_id.%0D%0A%09%09%3Fasfis_id_uri+mtlo%3ALX3_has_type%09%3Fasfis_type_uri.%0D%0A%09%09%3Fasfis_type_uri+rdfs%3Alabel+%3Fasfis_type.%0D%0A%09%09FILTER%28%3Fasfis_type%3D%22ASFIS%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Faphia_id_uri.%0D%0A%09%09%3Faphia_id_uri+rdfs%3Alabel+%3Faphia_id.%0D%0A%09%09%3Faphia_id_uri+mtlo%3ALX3_has_type%09%3Faphia_type_uri.%0D%0A%09%09%3Faphia_type_uri+rdfs%3Alabel+%3Faphia_type.%0D%0A%09%09FILTER%28%3Faphia_type%3D%22APHIA+ID%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Ffishbase_id_uri.%0D%0A%09%09%3Ffishbase_id_uri+rdfs%3Alabel+%3Ffishbase_id.%0D%0A%09%09%3Ffishbase_id_uri+mtlo%3ALX3_has_type%09%3Ffishbase_type_uri.%0D%0A%09%09%3Ffishbase_type_uri+rdfs%3Alabel+%3Ffishbase_type.%0D%0A%09%09FILTER%28%3Ffishbase_type%3D%22FishBase+ID%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Ftsn_id_uri.%0D%0A%09%09%3Ftsn_id_uri+rdfs%3Alabel+%3Ftsn_id.%0D%0A%09%09%3Ftsn_id_uri+mtlo%3ALX3_has_type+%3Ftsn_type_uri.%0D%0A%09%09%3Ftsn_type_uri+rdfs%3Alabel+%3Ftsn_type.%0D%0A%09%09FILTER%28%3Ftsn_type%3D%22TSN%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Ftaxonomic_id_uri.%0D%0A%09%09%3Ftaxonomic_id_uri+rdfs%3Alabel+%3Ftaxonomic_id.%0D%0A%09%09%3Ftaxonomic_id_uri+mtlo%3ALX3_has_type%09%3Ftaxonomic_type_uri.%0D%0A%09%09%3Ftaxonomic_type_uri+rdfs%3Alabel+%3Ftaxonomic_type.%0D%0A%09%09FILTER%28%3Ftaxonomic_type%3D%22taxonomic+code%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Fgbif_id_uri.%0D%0A%09%09%3Fgbif_id_uri+rdfs%3Alabel+%3Fgbif_id.%0D%0A%09%09%3Fgbif_id_uri+mtlo%3ALX3_has_type+%3Fgbif_type_uri.%0D%0A%09%09%3Fgbif_type_uri+rdfs%3Alabel+%3Fgbif_type.%0D%0A%09%09FILTER%28%3Fgbif_type%3D%22GBIF%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALX1_is_identified_by+%3Fiucn_id_uri.%0D%0A%09%09%3Fiucn_id_uri+rdfs%3Alabel+%3Fiucn_id.%0D%0A%09%09%3Fiucn_id_uri+mtlo%3ALX3_has_type+%3Fiucn_type_uri.%0D%0A%09%09%3Fiucn_type_uri+rdfs%3Alabel+%3Fiucn_type.%0D%0A%09%09FILTER%28%3Fiucn_type%3D%22IUCN%22%29%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09%3Fspecies_uri+mtlo%3ALT6_usually_is_subject_of+%3Fiucn_characterization_uri.%0D%0A%09%09%3Fiucn_characterization_uri+mtlo%3ALX4_has_appellation+%3Fiucn_characterization_appellation_uri.%0D%0A%09%09%3Fiucn_characterization_appellation_uri+rdfs%3Alabel+%3Fiucn_characterization.%0D%0A%09++%7D%0D%0A%09++OPTIONAL%7B%0D%0A%09%09++%3Fspecies_uri+mtlo%3ALX4_has_appellation+%3Fcm_name_uri.%0D%0A%09%09++%3Fcm_name_uri+rdfs%3Alabel+%3Fcommon_name.%0D%0A%09%09++%3Fcm_name_uri+mtlo%3ALX3_has_type+%3Fcm_name_type_uri.%0D%0A%09%09++%3Fcm_name_type_uri+rdfs%3Alabel+%3Fcm_name_type.%0D%0A%09%09++FILTER%28%3Fcm_name_type%3D%22common+name%22%29.%0D%0A%09++%7D%0D%0A%7D&format=text%2Fcsv&timeout=0';

  final int? id;
  final String scientificName;
  final String? asfisId;
  final String? aphiaId;
  final String? fishbaseId;
  final String? tsnId;
  final String? gbifId;
  final String? taxonomicId;
  final String? iucnId;
  final String? iucnCharacterization;
  final String? commonNames;

  Species({
    this.id,
    required this.scientificName,
    this.asfisId,
    this.aphiaId,
    this.fishbaseId,
    this.tsnId,
    this.gbifId,
    this.taxonomicId,
    this.iucnId,
    this.iucnCharacterization,
    this.commonNames,
  });

  factory Species.fromMap(Map<String, dynamic> map) {
    return Species(
      id: map['id'],
      scientificName: map['scientific_name'],
      asfisId: map['asfis_id'],
      aphiaId: map['aphia_id'],
      fishbaseId: map['fishbase_id'],
      tsnId: map['tsn_id'],
      gbifId: map['gbif_id'],
      taxonomicId: map['taxonomic_id'],
      iucnId: map['iucn_id'],
      iucnCharacterization: map['iucn_characterization'],
      commonNames: map['common_names'],
    );
  }

}
