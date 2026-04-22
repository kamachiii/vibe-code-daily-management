import 'package:flutter_test/flutter_test.dart';
import 'package:smart_planner/features/trip_ai/domain/trip_plan.dart';

void main() {
  group('TripPlan', () {
    test('fromJson parses a valid multi-day plan', () {
      final json = {
        'nama_tempat': 'Yogyakarta',
        'deskripsi': 'City of culture and tradition.',
        'estimasi_biaya': 1500000,
        'days': [
          {
            'date': '2026-06-01',
            'itinerary': [
              {
                'waktu_mulai': '08:00',
                'waktu_selesai': '10:00',
                'aktivitas': 'Visit Borobudur',
              },
            ],
          },
        ],
        'assumptions': ['Budget is per-person.'],
        'warnings': [],
      };

      final plan = TripPlan.fromJson(json);

      expect(plan.namaTempat, 'Yogyakarta');
      expect(plan.estimasiBiaya, 1500000);
      expect(plan.days.length, 1);
      expect(plan.days.first.date, '2026-06-01');
      expect(plan.days.first.itinerary.length, 1);
      expect(plan.days.first.itinerary.first.aktivitas, 'Visit Borobudur');
      expect(plan.assumptions, ['Budget is per-person.']);
      expect(plan.warnings, isEmpty);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final plan = TripPlan.fromJson({
        'nama_tempat': 'Bali',
        'deskripsi': '',
        'estimasi_biaya': 0,
        'days': <dynamic>[],
      });

      expect(plan.namaTempat, 'Bali');
      expect(plan.days, isEmpty);
      expect(plan.assumptions, isEmpty);
      expect(plan.warnings, isEmpty);
    });
  });

  group('ItineraryItem', () {
    test('fromJson parses correctly', () {
      final item = ItineraryItem.fromJson({
        'waktu_mulai': '09:30',
        'waktu_selesai': '11:00',
        'aktivitas': 'Sunrise at Bromo',
      });

      expect(item.waktuMulai, '09:30');
      expect(item.waktuSelesai, '11:00');
      expect(item.aktivitas, 'Sunrise at Bromo');
    });
  });
}
