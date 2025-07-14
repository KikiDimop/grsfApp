class Fishery {
  static const String tableName = 'Fishery';
  static const String urlCsv =
      'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Fuuid+%3Fgrsf_name+%3Fgrsf_semantic_id+%3Fshort_name+%3Ftype+%3Fstatus+%3Ftraceability_flag+%3Fspecies_type+%3Fspecies_code+%3Fspecies_name+%3Fgear_type+%3Fgear_code+%3Fflag_code+%3Fmanagement_entities+%3Fparent_areas+%3Ffirms_code+%3Ffishsource_code+%3Fsdg14_code+AS+%3FFAO_SDG14_4_1_questionnaire_code%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffirms%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffishsource%3E%0D%0AFROM+%3Chttp%3A%2F%2FuserProvided%3E%0D%0AWHERE%7B%0D%0A%09%3Frecord+a+crm%3ABC62_Capture_Activity.%0D%0A%09%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A%09%3Frecord+rdfs%3Alabel+%3Fshort_name.%0D%0A%09%3Frecord+crm%3AP1_is_identified_by+%3Fgrsf_name_uri.%0D%0A%09%3Fgrsf_name_uri+a+crm%3AE41_Appellation.%0D%0A%09%3Fgrsf_name_uri+rdfs%3Alabel+%3Fgrsf_name.%0D%0A%09%3Frecord+crm%3AP1_is_identified_by+%3Fgrsf_semantic_id_uri.%0D%0A%09%3Fgrsf_semantic_id_uri+a+crm%3AE42_Identifier.%0D%0A%09%3Fgrsf_semantic_id_uri+rdfs%3Alabel+%3Fgrsf_semantic_id.%0D%0A%09%3Frecord+crm%3Ahas_status+%3Fstatus_uri.%0D%0A%09%3Fstatus_uri+rdfs%3Alabel+%3Fstatus.%0D%0A%09%3Frecord+crm%3Ahas_traceability_flag+%3Ftraceability_flag.%0D%0A%09%3Frecord+crm%3AP2_has_type+%3Ftype_uri.%0D%0A%09%3Ftype_uri+rdfs%3Alabel+%3Ftype.%0D%0A%09%3Frecord+crm%3AP137_exemplifies+%3Fspecies_uri.%0D%0A%09%3Fspecies_uri+crm%3Ahas_species_type+%3Fspecies_type.%0D%0A%09%3Fspecies_uri+crm%3Ahas_species_code+%3Fspecies_code.%0D%0A%09%3Fspecies_uri+rdfs%3Alabel+%3Fspecies_name.%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_source_record+%3Ffirms_source_record.%0D%0A%09%09%3Ffirms_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Ffirms%2Fsource%2Ffirms%3E.%0D%0A%09%09%3Ffirms_source_record+crm%3Ahas_original_code+%3Ffirms_code%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3AP125_used_object_of_type+%3Fgear_uri.%0D%0A%09%09%3Fgear_uri+crm%3Ahas_gear_code+%3Fgear_code.%0D%0A%09%09%3Fgear_uri+crm%3Ahas_gear_type+%3Fgear_type.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_flag_state+%3Fflag_uri.%0D%0A%09%09%3Fflag_uri+crm%3Ahas_flag_code+%3Fflag_code.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_management_entities_values+%3Fmanagement_entities.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_source_record+%3Ffishsource_source_record.%0D%0A%09%09%3Ffishsource_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Ffishsource%2Fsource%2Ffishsource%3E.%0D%0A%09%09%3Ffishsource_source_record+crm%3Ahas_original_code+%3Ffishsource_code%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3Ahas_source_record+%3Fsdg14_source_record.%0D%0A%09%09%3Fsdg14_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Fsdg_14_4_1%2Fsource%2Fsdg_14_4_1%3E.%0D%0A%09%09%3Fsdg14_source_record+crm%3Ahas_original_code+%3Fsdg14_code.%0D%0A%09%7D%0D%0A%09OPTIONAL%7B%0D%0A%09%09%3Frecord+crm%3AO15_occupied_parent+%3Fparent_areas%0D%0A++++%7D%0D%0A%7D%0D%0A&format=text%2Fcsv&timeout=0';
  final int? id;
  final String? uuid;
  final String? grsfName;
  final String? grsfSemanticID;
  final String? shortName;
  final String? type;
  final String? status;
  final String? traceabilityFlag;
  final String? speciesType;
  final String? speciesCode;
  final String? speciesName;
  final String? gearType;
  final String? gearCode;
  final String? flagCode;
  final String? managementEntities;
  final String? parentAreas;
  final String? firmsCode;
  final String? fishsourceCode;
  final String? questionnaireCode;

  Fishery({
    this.id,
    this.uuid,
    this.grsfName,
    this.grsfSemanticID,
    this.shortName,
    this.type,
    this.status,
    this.traceabilityFlag,
    this.speciesCode,
    this.speciesName,
    this.speciesType,
    this.gearType,
    this.gearCode,
    this.flagCode,
    this.managementEntities,
    this.parentAreas,
    this.firmsCode,
    this.fishsourceCode,
    this.questionnaireCode,
  });

  factory Fishery.fromMap(Map<String, dynamic> map) {
    return Fishery(
      id: map['id'],
      uuid: map['uuid'],
      grsfName: map['grsf_name'],
      grsfSemanticID: map['grsf_semantic_id'],
      shortName: map['short_name'],
      type: map['type'],
      status: map['status'],
      traceabilityFlag: map['traceability_flag'],
      speciesCode: map['species_code'],
      speciesType: map['species_type'],
      speciesName: map['species_name'],
      gearType: map['gear_type'],
      gearCode: map['gear_code'],
      flagCode: map['flag_code'],
      managementEntities: map['management_entities'],
      parentAreas: map['parent_areas'],
      firmsCode: map['firms_code'],
      fishsourceCode: map['fishsource_code'],
      questionnaireCode: map['FAO_SDG14_4_1_questionnaire_code'],
    );
  }
}
