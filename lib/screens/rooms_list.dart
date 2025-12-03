// lib/screens/rooms_list.dart
import 'package:flutter/material.dart';
import '../supabase_service.dart';
import '../models.dart';
import 'reservation_form.dart';
import 'my_reservations.dart';
import 'login_screen.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  _RoomsListScreenState createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  late Future<List<Room>> _futureRooms;

  @override
  void initState() {
    super.initState();
    _futureRooms = SupabaseService.getRooms();
  }

  void _refresh() {
    setState(() {
      _futureRooms = SupabaseService.getRooms();
    });
  }

  void _logout() async {
    await SupabaseService.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chambres'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refresh),
          IconButton(icon: Icon(Icons.list_alt), onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyReservationsScreen()));
          }),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<Room>>(
        future: _futureRooms,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Erreur: ${snap.error}'));
          final rooms = snap.data ?? [];
          if (rooms.isEmpty) return Center(child: Text('Aucune chambre disponible'));
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (ctx, i) {
              final r = rooms[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('Chambre ${r.number} — ${r.category ?? ''}'),
                  subtitle: Text('${r.beds} lit(s) • ${r.price.toStringAsFixed(2)}€'),
                  trailing: ElevatedButton(
                    child: Text('Réserver'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReservationFormScreen(room: r))),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
