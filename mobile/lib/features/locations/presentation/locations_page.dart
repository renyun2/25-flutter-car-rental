import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/car_rental_repository.dart';
import '../../rental/application/rental_draft_provider.dart';
import '../../shared/presentation/widgets.dart';

class LocationsPage extends ConsumerStatefulWidget {
  const LocationsPage({super.key});

  @override
  ConsumerState<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends ConsumerState<LocationsPage> {
  String? _city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选网点')),
      body: Column(
        children: [
          FutureBuilder<List<String>>(
            future: ref.read(carRentalRepositoryProvider).listCities(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('全部'),
                      selected: _city == null,
                      onSelected: (_) => setState(() => _city = null),
                    ),
                    ...snap.data!.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(c),
                          selected: _city == c,
                          onSelected: (_) => setState(() => _city = c),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Location>>(
              future: ref.read(carRentalRepositoryProvider).listLocations(city: _city),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) return loadingBox();
                if (snap.hasError) return errorBox('${snap.error}');
                return ListView.builder(
                  itemCount: snap.data!.length,
                  itemBuilder: (_, i) {
                    final loc = snap.data![i];
                    return ListTile(
                      title: Text('${loc.city} ${loc.name}'),
                      subtitle: Text(loc.address),
                      onTap: () {
                        final draft = ref.read(rentalDraftProvider);
                        ref.read(rentalDraftProvider.notifier).state = draft.copyWith(
                          pickupLocation: loc,
                          returnLocation: loc,
                        );
                        context.push('/rental/dates');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
