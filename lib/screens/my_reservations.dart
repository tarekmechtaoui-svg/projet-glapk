// lib/screens/my_reservations.dart
import 'package:flutter/material.dart';
import '../supabase_service.dart';
import '../models.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  _MyReservationsScreenState createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  bool loading = true;
  List<Reservation> reservations = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw 'Utilisateur non connecté';
      final person = await SupabaseService.getPersonForUser(user.id);
      if (person == null) {
        reservations = [];
      } else {
        reservations = await SupabaseService.getReservationsForPerson(person.id);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes réservations'),
        actions: [ IconButton(icon: Icon(Icons.refresh), onPressed: _load) ],
      ),
      body: loading ? Center(child: CircularProgressIndicator()) :
        error != null ? Center(child: Text('Erreur: $error')) :
        reservations.isEmpty ? Center(child: Text('Aucune réservation')) :
        ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (ctx, i) {
            final r = reservations[i];
            return ListTile(
              title: Text('Chambre ${r.roomId}'), // si tu veux details room, adapte select join dans service
              subtitle: Text('${r.startDate.toIso8601String().split("T")[0]} → ${r.endDate.toIso8601String().split("T")[0]}'),
              trailing: Text(r.status),
            );
          },
        ),
    );
  }
}
