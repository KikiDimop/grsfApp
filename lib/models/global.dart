import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

const String urlStockPng =
    'https://www.fao.org/fishery/geoserver/wms?service=WMS&version=1.1.0&request=GetMap&layers=grsf%3Agrsf_resource_polygons,fifao:UN_CONTINENT2&bbox=-180.0%2C-60.0%2C180.0%2C90.0&width=768&height=330&srs=EPSG%3A4326&styles=&format=image%2Fpng&cql_filter=uuid=%27';
const String urlStockPngEnding = ' %27;INCLUDE';

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

  SearchStockForSpecies(
      /*this.asfisId, this.aphiaId, this.fishbaseId, this.tsnId,
      this.gbifId, this.taxonomicId, this.iucnId, */
      this.speciesName);
}

class SearchFisheryForSpecies {
  final String speciesName;

  SearchFisheryForSpecies(this.speciesName);
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


