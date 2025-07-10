
class FisheryOwner {  

  static const String tableName = 'FisheryOwner';
  static const String urlCsv = 'https://isl.ics.forth.gr/grsf/sparql?default-graph-uri=&query=PREFIX+crm%3A+%3Chttp%3A%2F%2Fwww.cidoc-crm.org%2Fcidoc-crm%2F%3E%0D%0ASELECT+DISTINCT+%3Fuuid+%3Fowner+%3Fsource_name%0D%0AFROM+%3Chttp%3A%2F%2Fgrsf%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffirms%3E%0D%0AFROM+%3Chttp%3A%2F%2Fram%3E%0D%0AFROM+%3Chttp%3A%2F%2Ffishsource%3E%0D%0AFROM+%3Chttp%3A%2F%2FuserProvided%3E%0D%0AWHERE%7B%0D%0A%09++%3Frecord+a+crm%3ABC62_Capture_Activity.%0D%0A%09++%3Frecord+crm%3Ahas_uuid+%3Fuuid.%0D%0A%09++%3Frecord+crm%3Ahas_source_record+%3Fsource_record.%0D%0A%09++%3Fsource_record+crm%3Ahas_source+%3Fsource_uri.%0D%0A%09++%3Fsource_uri+rdfs%3Alabel+%3Fsource_name.%0D%0A%09++%3Fdocument_uri+crm%3AP129_is_about+%3Fsource_record.%0D%0A%09++%3Fdocument_uri+crm%3AP51_has_former_or_current_owner+%3Fowner_uri.%0D%0A%09++%3Fowner_uri+rdfs%3Alabel+%3Fowner.%0D%0A%7D&format=text%2Fcsv&timeout=0';
  final int? id;
  final String? uuid;
  final String? owner;
  final String? sourceName;

  FisheryOwner({
    this.id,
    this.uuid,
    this.owner,
    this.sourceName,
  });

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'uuid': uuid,
  //     'owner': owner,
  //     'sourceName': sourceName,
  //   };
  // }

  factory FisheryOwner.fromMap(Map<String, dynamic> map) {
    return FisheryOwner(
      id: map['id'],
      uuid: map['uuid'],
      owner: map['areas_type'],
      sourceName: map['source_name'],
    );
  }

  // FisheryOwner copyWith({
  //   int? id,
  //   String? uuid,
  //   String? owner,
  //   String? sourceName,
  // }) {
  //   return FisheryOwner(
  //     id: id ?? this.id,
  //     uuid: uuid ?? this.uuid,
  //     owner: owner ?? this.owner,
  //     sourceName: sourceName ?? this.sourceName,
  //   );
  // }
}