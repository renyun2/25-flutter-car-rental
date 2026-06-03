import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../data/repositories/car_rental_repository.dart';
import '../application/rental_draft_provider.dart';

class RentalDatesPage extends ConsumerStatefulWidget {
  const RentalDatesPage({super.key});

  @override
  ConsumerState<RentalDatesPage> createState() => _RentalDatesPageState();
}

class _RentalDatesPageState extends ConsumerState<RentalDatesPage> {
  DateTime _focused = DateTime.now();
  DateTime? _pickupDay;
  DateTime? _returnDay;
  Set<String> _unavailable = {};
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    final draft = ref.read(rentalDraftProvider);
    final v = draft.vehicle;
    final loc = draft.pickupLocation;
    if (v == null || loc == null) return;
    final end = DateTime.now().add(const Duration(days: 30));
    final cal = await ref.read(carRentalRepositoryProvider).getAvailability(
          vehicleId: v.id,
          locationId: loc.id,
          start: _fmt(DateTime.now()),
          end: _fmt(end),
        );
    setState(() {
      _unavailable = cal.where((d) => d['available'] != true).map((d) => d['date'] as String).toSet();
    });
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _merge(DateTime day, TimeOfDay t) =>
      DateTime(day.year, day.month, day.day, t.hour, t.minute);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选日期')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focused,
            enabledDayPredicate: (day) => !_unavailable.contains(_fmt(day)),
            calendarStyle: CalendarStyle(
              disabledTextStyle: TextStyle(color: Colors.grey.shade400),
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                _focused = focused;
                if (_pickupDay == null || (_pickupDay != null && _returnDay != null)) {
                  _pickupDay = selected;
                  _returnDay = null;
                } else {
                  _returnDay = selected.isBefore(_pickupDay!) ? selected : selected;
                  if (selected.isBefore(_pickupDay!)) {
                    _returnDay = _pickupDay;
                    _pickupDay = selected;
                  }
                }
              });
            },
          ),
          ListTile(
            title: Text('取车时间: ${_pickupTime.format(context)}'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _pickupTime);
              if (t != null) setState(() => _pickupTime = t);
            },
          ),
          ListTile(
            title: Text('还车时间: ${_returnTime.format(context)}'),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _returnTime);
              if (t != null) setState(() => _returnTime = t);
            },
          ),
          FilledButton(
            onPressed: _pickupDay == null
                ? null
                : () {
                    final pickup = _merge(_pickupDay!, _pickupTime);
                    final returnDay = _returnDay ?? _pickupDay!;
                    final ret = _merge(returnDay, _returnTime);
                    if (!ret.isAfter(pickup)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('还车时间须晚于取车时间')),
                      );
                      return;
                    }
                    ref.read(rentalDraftProvider.notifier).state =
                        ref.read(rentalDraftProvider).copyWith(pickupAt: pickup, returnAt: ret);
                    context.push('/quote');
                  },
            child: const Text('下一步：报价'),
          ),
        ],
      ),
    );
  }
}
