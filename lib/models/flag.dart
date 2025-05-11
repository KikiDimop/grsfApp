class FlagStates {
  final String? flagType;
  final String? flagCode;
  final String? flagName;

  FlagStates({
    this.flagType,
    this.flagCode,
    this.flagName,
  });


  factory FlagStates.fromJson(Map<String, dynamic> json) {
    return FlagStates(
      flagType: json['flag_state_type'],
      flagCode: json['flag_state_code'],
      flagName: json['flag_state_name'],
    );
  }
}
