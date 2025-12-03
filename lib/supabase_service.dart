// lib/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // -------------------------
  // AUTH
  // -------------------------
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // -------------------------
  // ROOMS
  // -------------------------
  static Future<List<Room>> getRooms() async {
    try {
      final data = await client
          .from('rooms')
          .select()
          .order('number');

      return (data as List)
          .map((e) => Room.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error loading rooms: $e");
    }
  }

  // -------------------------
  // PERSONS
  // -------------------------
  static Future<Person?> getPersonForUser(String userId) async {
    try {
      final data = await client
          .from('persons')
          .select()
          .eq('supabase_user_id', userId)
          .limit(1);

      if (data.isEmpty) return null;

      return Person.fromMap(data.first);
    } catch (e) {
      throw Exception("Error loading person: $e");
    }
  }

  static Future<Person> createPerson({
    String? supabaseUserId,
    required String firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final map = {
        'supabase_user_id': supabaseUserId,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      };

      final data = await client
          .from('persons')
          .insert(map)
          .select()
          .single();

      return Person.fromMap(data);
    } catch (e) {
      throw Exception("Error creating person: $e");
    }
  }

  // -------------------------
  // RESERVATIONS
  // -------------------------
  static Future<Reservation> createReservation({
    required String personId,
    required String roomId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final data = await client
          .from('reservations')
          .insert({
            'person_id': personId,
            'room_id': roomId,
            'start_date': start.toIso8601String().split('T')[0],
            'end_date': end.toIso8601String().split('T')[0],
            'status': 'confirmed'
          })
          .select()
          .single();

      return Reservation.fromMap(data);
    } catch (e) {
      throw Exception("Error creating reservation: $e");
    }
  }

  static Future<List<Reservation>> getReservationsForRoom(String roomId) async {
    try {
      final data = await client
          .from('reservations')
          .select()
          .eq('room_id', roomId)
          .order('start_date');

      return (data as List)
          .map((e) => Reservation.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error loading reservations: $e");
    }
  }

  static Future<List<Reservation>> getReservationsForPerson(String personId) async {
    try {
      final data = await client
          .from('reservations')
          .select('*, rooms:room_id(*)')
          .eq('person_id', personId)
          .order('start_date', ascending: false);

      return (data as List)
          .map((e) => Reservation.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Error loading user reservations: $e");
    }
  }
}
