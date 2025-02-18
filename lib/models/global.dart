import 'dart:ui';

class SearchStock {
  final String selectedSpeciesSystem,
      speciesCode,
      speciesName,
      selectedAreaSystem,
      areaCode,
      areaName,
      selectedFAOMajorArea,
      selectedResourceType,
      selectedResourceStatus;

  SearchStock(
      this.selectedSpeciesSystem,
      this.speciesCode,
      this.speciesName,
      this.selectedAreaSystem,
      this.areaCode,
      this.areaName,
      this.selectedFAOMajorArea,
      this.selectedResourceType,
      this.selectedResourceStatus);
}

class SearchStockForSpecies {
  final String /* asfisId,
      aphiaId,
      fishbaseId,
      tsnId,
      gbifId,
      taxonomicId,
      iucnId, */
      speciesName;

  SearchStockForSpecies( /*this.asfisId, this.aphiaId, this.fishbaseId, this.tsnId,
      this.gbifId, this.taxonomicId, this.iucnId, */ this.speciesName);
}

class SearchFishery {
  final String selectedSpeciesSystem,
      speciesCode,
      speciesName,
      selectedAreaSystem,
      areaCode,
      areaName,
      selectedGearSystem,
      gearCode,
      gearName,
      selectedFAOMajorArea,
      selectedResourceType,
      selectedResourceStatus;

  SearchFishery(
      this.selectedSpeciesSystem,
      this.speciesCode,
      this.speciesName,
      this.selectedAreaSystem,
      this.areaCode,
      this.areaName,
      this.selectedGearSystem,
      this.gearCode,
      this.gearName,
      this.selectedFAOMajorArea,
      this.selectedResourceType,
      this.selectedResourceStatus);
}

Color getColor(String? status) {
  return status == 'pending'
      ? const Color(0xff5779A9)
      : status == 'approved'
          ? const Color(0xff138A36)
          : status == 'rejected'
              ? const Color(0xffB3001B)
              : const Color(0xffA9A9A9);
}
