import 'dart:convert';
import 'package:acodemind05/models/place_location.dart';
import 'package:acodemind05/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const key = 'a8tEGEVLa2SfcwqoOUTndsMsbafmrGTA';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectedLocation});

  final void Function(PlaceLocation location) onSelectedLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return "";
    } else {
      return 'https://api.tomtom.com/map/1/staticimage?layer=basic&style=main&format=png&zoom=6&center=${_pickedLocation!.longitude},${_pickedLocation!.latitude}&width=1024&height=512&view=Unified&key=$key';
    }
  }

  Future<void> _getCurrentLocation(PlaceLocation? place) async {
    Location? location;
    location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      locationData = await location.getLocation();
      print(place?.latitude);
      print(place?.longitude);
      final url = Uri.parse(
          "https://api.tomtom.com/search/2/reverseGeocode/${place == null ? locationData.latitude : place.latitude},${place == null ? locationData.longitude : place.longitude}.json?returnSpeedLimit=false&radius=10000&returnRoadUse=false&allowFreeformNewLine=false&returnMatchType=false&view=Unified&key=$key");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        final country =
            resData['addresses'][0]['address']['country'].toString() == 'null'
                ? ""
                : "${resData['addresses'][0]['address']['country']} - ";
        final city = resData['addresses'][0]['address']
                        ['countrySecondarySubdivision']
                    .toString() ==
                'null'
            ? ""
            : "${resData['addresses'][0]['address']['countrySecondarySubdivision']} - ";
        final street =
            resData['addresses'][0]['address']['freeformAddress'].toString() ==
                    'null'
                ? ""
                : "${resData['addresses'][0]['address']['freeformAddress']}";
        final address = "$country$city$street";

        print(address);
        setState(() {
          _pickedLocation = PlaceLocation(
              latitude: place == null ? locationData.latitude : place.latitude,
              longitude:
                  place == null ? locationData.longitude : place.longitude,
              address: address);
          _isGettingLocation = false;
        });
        widget.onSelectedLocation(_pickedLocation!);
      } else {
        setState(() {
          _isGettingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: const Text('There are some problem , please reload app'),
        ));
      }
    } catch (error) {
      setState(() {
        _isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1500),
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: const Text(
            'you are not connected , please check your wifi connect'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: () {
                _getCurrentLocation(null);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: () async {
                PlaceLocation? place = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const MapScreen();
                  }),
                );
                if (place != null) {
                  _getCurrentLocation(place);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
