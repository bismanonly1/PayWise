import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/work_shift.dart';
import '../../data/shift_repository.dart';

class AddShiftScreen extends StatefulWidget {
  const AddShiftScreen({super.key});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  final locationController = TextEditingController();
  final breakController = TextEditingController(text: '0');
  final rateController = TextEditingController(text: '20');

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  bool endsNextDay = false;
  bool isSaving = false;

  WorkShift? previewShift;
  String? errorMessage;

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> selectTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    }
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> saveShift() async {
    calculateShift();

    final shift = previewShift;
    if (shift == null) return;

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    final client = http.Client();

    try {
      final saved = await ShiftRepository(client).saveShift(shift);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shift #${saved['id']} saved successfully')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      client.close();

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void calculateShift() {
    final unpaidBreak = int.tryParse(breakController.text);
    final hourlyRate = double.tryParse(rateController.text);

    if (locationController.text.trim().isEmpty ||
        unpaidBreak == null ||
        unpaidBreak < 0 ||
        hourlyRate == null ||
        !hourlyRate.isFinite ||
        hourlyRate < 0) {
      setState(() {
        previewShift = null;
        errorMessage = 'Enter a location, valid break and hourly rate.';
      });
      return;
    }

    final start = combineDateAndTime(selectedDate, startTime);
    var end = combineDateAndTime(selectedDate, endTime);

    if (endsNextDay) {
      end = end.add(const Duration(days: 1));
    }

    final totalMinutes = end.difference(start).inMinutes;

    if (totalMinutes <= 0 || unpaidBreak >= totalMinutes) {
      setState(() {
        previewShift = null;
        errorMessage = 'Check your times and unpaid break duration.';
      });
      return;
    }

    final shift = WorkShift(
      date: selectedDate,
      location: locationController.text.trim(),
      startTime: start,
      endTime: end,
      unpaidBreakMinutes: unpaidBreak,
      hourlyRate: hourlyRate,
    );

    setState(() {
      previewShift = shift;
      errorMessage = null;
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    breakController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Shift')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Work location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: selectDate,
            child: Text(
              'Date: ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => selectTime(isStart: true),
            child: Text('Start: ${startTime.format(context)}'),
          ),
          OutlinedButton(
            onPressed: () => selectTime(isStart: false),
            child: Text('End: ${endTime.format(context)}'),
          ),
          SwitchListTile(
            title: const Text('Shift ends the next day'),
            value: endsNextDay,
            onChanged: (value) {
              setState(() => endsNextDay = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: breakController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Unpaid break (minutes)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Hourly rate (CAD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: calculateShift,
            child: const Text('Calculate Shift'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isSaving ? null : saveShift,
            icon: const Icon(Icons.save),
            label: Text(isSaving ? 'Saving...' : 'Save Shift'),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (previewShift != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shift Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Paid hours: ${previewShift!.paidHours.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Gross base pay: \$${previewShift!.grossBasePay.toStringAsFixed(2)} CAD',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
