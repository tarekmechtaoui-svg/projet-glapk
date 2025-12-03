// lib/models.dart
class Room {
  final String id;
  final String number;
  final String? category;
  final int beds;
  final double price;

  Room({
    required this.id,
    required this.number,
    this.category,
    required this.beds,
    required this.price,
  });

  factory Room.fromMap(Map<String, dynamic> m) => Room(
        id: m['id'].toString(),
        number: m['number'] ?? '',
        category: m['category'],
        beds: m['beds'] is num ? (m['beds'] as num).toInt() : 0,
        price: m['price'] is num ? (m['price'] as num).toDouble() : 0.0,
      );
}


class Person {
  final String id;
  final String? supabaseUserId;
  final String firstName;
  final String? lastName;
  final String? phone;

  Person({required this.id, this.supabaseUserId, required this.firstName, this.lastName, this.phone});

  factory Person.fromMap(Map<String, dynamic> m) => Person(
    id: m['id'],
    supabaseUserId: m['supabase_user_id']?.toString(),
    firstName: m['first_name'],
    lastName: m['last_name'],
    phone: m['phone'],
  );
}

class Reservation {
  final String id;
  final String personId;
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  Reservation({
    required this.id,
    required this.personId,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Reservation.fromMap(Map<String, dynamic> m) => Reservation(
    id: m['id'],
    personId: m['person_id'],
    roomId: m['room_id'],
    startDate: DateTime.parse(m['start_date']),
    endDate: DateTime.parse(m['end_date']),
    status: m['status'] ?? 'confirmed',
  );
}
