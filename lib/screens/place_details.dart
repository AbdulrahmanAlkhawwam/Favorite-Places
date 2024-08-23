import 'package:flutter/material.dart';
import 'package:acodemind05/models/place.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_places.dart';

const key = 'a8tEGEVLa2SfcwqoOUTndsMsbafmrGTA';

class PlaceDetail extends ConsumerWidget {
  const PlaceDetail({super.key, required this.place});

  final Place place;

  String get locationImage {
    return 'https://api.tomtom.com/map/1/staticimage?layer=basic&style=main&format=png&zoom=6&center=${place.location.longitude}%2C%20${place.location.latitude}&width=1024&height=512&view=Unified&key=$key';
  }

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(userPlacesProvider.notifier).deletePlace(place);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (place.location.longitude == null ||
                        place.location.latitude == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(milliseconds: 1500),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        content: const Text(
                            "we can't display this location , check if the location is really "),
                      ));
                    } else {
                      await showSimplePickerLocation(
                        initPosition: GeoPoint(
                            latitude: place.location.latitude!,
                            longitude: place.location.longitude!),
                        context: context,
                        isDismissible: false,
                        radius: 15,
                        zoomOption: const ZoomOption(initZoom: 8),
                        title: place.location.address,
                        contentPadding: const EdgeInsets.all(10),
                        textCancelPicker: "back",
                        textConfirmPicker: "Ok",
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(locationImage),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    textAlign: TextAlign.center,
                    place.location.address ?? "place location address",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
