import 'package:smart_planner/core/utils/json.dart';

/// A single activity within a trip day.
class ItineraryItem {
  const ItineraryItem({
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.aktivitas,
  });

  /// Start time — "HH:MM" (24-hour).
  final String waktuMulai;

  /// End time — "HH:MM" (24-hour).
  final String waktuSelesai;

  final String aktivitas;

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      waktuMulai: readString(json, 'waktu_mulai'),
      waktuSelesai: readString(json, 'waktu_selesai'),
      aktivitas: readString(json, 'aktivitas'),
    );
  }

  Map<String, dynamic> toJson() => {
        'waktu_mulai': waktuMulai,
        'waktu_selesai': waktuSelesai,
        'aktivitas': aktivitas,
      };
}

/// One day within the multi-day trip plan.
class TripDay {
  const TripDay({required this.date, required this.itinerary});

  /// ISO date string "YYYY-MM-DD".
  final String date;
  final List<ItineraryItem> itinerary;

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      date: readString(json, 'date'),
      itinerary: readList(json, 'itinerary', ItineraryItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'itinerary': itinerary.map((e) => e.toJson()).toList(),
      };
}

/// Complete trip plan returned by the AI Edge Function.
class TripPlan {
  const TripPlan({
    required this.namaTempat,
    required this.deskripsi,
    required this.estimasiBiaya,
    required this.days,
    this.assumptions = const [],
    this.warnings = const [],
  });

  final String namaTempat;
  final String deskripsi;

  /// Estimated total cost for the trip (IDR or user currency).
  final int estimasiBiaya;

  final List<TripDay> days;

  /// Assumptions the AI made when filling in missing details.
  final List<String> assumptions;

  /// Warnings about potentially unsafe, missing, or uncertain data.
  final List<String> warnings;

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      namaTempat: readString(json, 'nama_tempat'),
      deskripsi: readString(json, 'deskripsi'),
      estimasiBiaya: readInt(json, 'estimasi_biaya'),
      days: readList(json, 'days', TripDay.fromJson),
      assumptions: ((json['assumptions'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      warnings: ((json['warnings'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_tempat': namaTempat,
        'deskripsi': deskripsi,
        'estimasi_biaya': estimasiBiaya,
        'days': days.map((d) => d.toJson()).toList(),
        'assumptions': assumptions,
        'warnings': warnings,
      };
}
