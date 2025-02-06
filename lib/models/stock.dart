import 'dart:ui';

import 'package:flutter/material.dart';

class Stock {
  static const String tableName = 'Stock';
  static const String urlCsv = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0A%0D%0ASELECT+DISTINCT+%3Fuuid+%3Fgrsf_name+%3Fgrsf_semantic_id+%3Fshort_name+%3Ftype+%3Fstatus+%3Fparent_areas+%3Fsdg_flag+%3Fjurisdictional_distribution+%3Ffirms_code+%3Fram_code+%3Ffishsource_code+%3Fsdg14_code+AS+%3FFAO_SDG14_4_1_questionnaire_code%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffirms%3E%0D%0AFROM+%3Chttp%3A%2F%2Fram%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffishsource%3E%0D%0AFROM+%3Chttp%3A%2F%2FuserProvided%3E%0D%0A%0D%0AWHERE%7B%0D%0A++%3Frecord+a+crm%3AStock.%0D%0A++%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A++%3Frecord+rdfs%3Alabel+%3Fshort_name.++%0D%0A++%3Frecord+crm%3AP1_is_identified_by+%3Fgrsf_name_uri.%0D%0A++%3Fgrsf_name_uri+a+crm%3AE41_Appellation.%0D%0A++%3Fgrsf_name_uri+rdfs%3Alabel+%3Fgrsf_name.%0D%0A++%3Frecord+crm%3AP1_is_identified_by+%3Fgrsf_semantic_id_uri.%0D%0A++%3Fgrsf_semantic_id_uri+a+crm%3AE42_Identifier.%0D%0A++%3Fgrsf_semantic_id_uri+rdfs%3Alabel+%3Fgrsf_semantic_id.%0D%0A++%3Frecord+crm%3Ahas_status+%3Fstatus_uri.%0D%0A++%3Fstatus_uri+rdfs%3Alabel+%3Fstatus.%0D%0A++%3Frecord+crm%3Ahas_sdg+%3Fsdg_flag.%0D%0A++%3Frecord+crm%3Ahas_stock_type_value+%3Ftype.%0D%0A++OPTIONAL%7B%0D%0A++++%3Frecord+crm%3Ahas_source_record+%3Ffirms_source_record.%0D%0A++++%3Ffirms_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Ffirms%2Fsource%2Ffirms%3E.%0D%0A++++%3Ffirms_source_record+crm%3Ahas_original_code+%3Ffirms_code%0D%0A++%7D%0D%0A++OPTIONAL%7B%0D%0A++++%3Frecord+crm%3Ahas_source_record+%3Fram_source_record.%0D%0A++++%3Fram_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Fram%2Fsource%2Fram%3E.%0D%0A++++%3Fram_source_record+crm%3Ahas_original_code+%3Fram_code%0D%0A++%7D%0D%0A++OPTIONAL%7B%0D%0A++++%3Frecord+crm%3Ahas_source_record+%3Ffishsource_source_record.%0D%0A++++%3Ffishsource_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Ffishsource%2Fsource%2Ffishsource%3E.%0D%0A++++%3Ffishsource_source_record+crm%3Ahas_original_code+%3Ffishsource_code%0D%0A++%7D%0D%0A++OPTIONAL%7B%0D%0A%09%3Frecord+crm%3Ahas_source_record+%3Fsdg14_source_record.%0D%0A%09%3Fsdg14_source_record+crm%3Ahas_source+%3Chttps%3A%2F%2Fgithub.com%2Fgrsf%2Fresource%2Fsdg_14_4_1%2Fsource%2Fsdg_14_4_1%3E.%0D%0A%09%3Fsdg14_source_record+crm%3Ahas_original_code+%3Fsdg14_code.%0D%0A++%7D%0D%0A++OPTIONAL%7B%0D%0A%09%3Frecord+crm%3AO15_occupied_parent+%3Fparent_areas%0D%0A++%7D%0D%0A++OPTIONAL%7B%0D%0A%09%3Frecord+crm%3Ahas_jurisdictional_distribution+%3Fjurisdictional_distribution_uri.%0D%0A%09%3Fjurisdictional_distribution_uri+rdfs%3Alabel+%3Fjurisdictional_distribution.%0D%0A++%7D%0D%0A%7D&format=text%2Fcsv&timeout=0';
  
  final int? id;
  final String? uuid;
  final String? grsfName;
  final String? grsfSemanticID;
  final String? shortName;
  final String? type;
  final String? status;
  final String? parentAreas;
  final String? sdgFlag;
  final String? jurisdictionalDistribution;
  final String? firmsCode;
  final String? ramCode;
  final String? fishsourceCode;
  final String? questionnaireCode;

  Stock({
    this.id,
    this.uuid,
    this.grsfName,
    this.grsfSemanticID,
    this.shortName,
    this.type,
    this.status,
    this.parentAreas,
    this.sdgFlag,
    this.jurisdictionalDistribution,
    this.firmsCode,
    this.ramCode,
    this.fishsourceCode,
    this.questionnaireCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'grsfName': grsfName,
      'grsfSemanticID': grsfSemanticID,
      'shortName': shortName,
      'type': type,
      'status': status,
      'parentAreas': parentAreas,
      'sdgFlag': sdgFlag,
      'jurisdictionalDistribution': jurisdictionalDistribution,
      'firmsCode': firmsCode,
      'ramCode': ramCode,
      'fishsourceCode': fishsourceCode,
      'questionnaireCode': questionnaireCode,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      uuid: map['uuid'],
      grsfName: map['grsf_name'],
      grsfSemanticID: map['grsf_semantic_id'],
      shortName: map['short_name'],
      type: map['type'],
      status: map['status'],
      parentAreas: map['parent_areas'],
      sdgFlag: map['sdg_flag'],
      jurisdictionalDistribution: map['jurisdictional_distribution'],
      firmsCode: map['firms_code'],
      ramCode: map['ram_code'],
      fishsourceCode: map['fishsource_code'],
      questionnaireCode: map['FAO_SDG14_4_1_questionnaire_code'],
    );
  }

  Stock copyWith({
    int? id,
    String? uuid,
    String? grsfName,
    String? grsfSemanticID,
    String? shortName,
    String? type,
    String? status,
    String? parentAreas,
    String? sdgFlag,
    String? jurisdictionalDistribution,
    String? firmsCode,
    String? ramCode,
    String? fishsourceCode,
    String? questionnaireCode,
  }) {
    return Stock(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      grsfName: grsfName ?? this.grsfName,
      grsfSemanticID: grsfSemanticID ?? this.grsfSemanticID,
      shortName: shortName ?? this.shortName,
      type: type ?? this.type,
      status: status ?? this.status,
      parentAreas: parentAreas ?? this.parentAreas,
      sdgFlag: sdgFlag ?? this.sdgFlag,
      jurisdictionalDistribution: jurisdictionalDistribution ?? this.jurisdictionalDistribution,
      firmsCode: firmsCode ?? this.firmsCode,
      ramCode: ramCode ?? this.ramCode,
      fishsourceCode: fishsourceCode ?? this.fishsourceCode,
      questionnaireCode: questionnaireCode ?? this.questionnaireCode,
    );
  }
}