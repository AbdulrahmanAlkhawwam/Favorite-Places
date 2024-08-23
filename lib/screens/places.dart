import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acodemind05/providers/user_places.dart';
import 'package:acodemind05/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'add_places.dart';

class Places extends ConsumerStatefulWidget {
  const Places({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlacesState();
  }
}

class _PlacesState extends ConsumerState<Places> {
  late Future<void> _PlacesFuture;

  @override
  void initState() {
    super.initState();
    _PlacesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddPlace(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _PlacesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
              // return Shimmer.fromColors(
              //   baseColor: Colors.grey.shade300,
              //   highlightColor: Colors.grey.shade100,
              //   enabled: true,
              //   child: ListView.builder(
              //     itemBuilder: (context, index) => Row(
              //       children: [
              //         const CircleAvatar(
              //           radius: 26,
              //         ),
              //         ],
              //     ),
              //     itemCount: 20,
              //   ),
              // );
            } else {
              return PlacesList(
                places: userPlaces,
              );
            }
          },
        ),
      ),
    );
  }
}
