// lib/screens/reservation_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../supabase_service.dart';

class ReservationFormScreen extends StatefulWidget {
  final Room room;
  const ReservationFormScreen({super.key, required this.room});

  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  DateTime? _start;
  DateTime? _end;
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  String fmt(DateTime? d) => d == null ? 'Choisir' : DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: DateTime(now.year + 2));
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final start = _start ?? DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: start.add(Duration(days:1)), firstDate: start, lastDate: DateTime(start.year + 2));
    if (picked != null) setState(() => _end = picked);
  }

  bool _datesValid() => _start != null && _end != null && !_end!.isBefore(_start!);

  bool _overlaps(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    // overlap if s1 <= e2 && s2 <= e1
    return ! (e1.isBefore(s2) || e2.isBefore(s1));
  }

  Future<void> _submit() async {
    if (!_datesValid()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Choisis des dates valides')));
      return;
    }
    if (_firstNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Prénom requis')));
      return;
    }

    setState(() => _loading = true);

    try {
      // 1) récupère toutes les réservations existantes pour la chambre
      final existing = await SupabaseService.getReservationsForRoom(widget.room.id);

      // 2) vérifie recoupement
      final conflict = existing.any((r) => _overlaps(_start!, _end!, r.startDate, r.endDate));
      if (conflict) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La chambre n\'est pas disponible pour ces dates')));
        setState(() => _loading = false);
        return;
      }

      // 3) crée la personne (lier supabase_user_id si connecté)
      final user = SupabaseService.currentUser;
      final person = await SupabaseService.createPerson(
        supabaseUserId: user?.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );

      // 4) crée la réservation
      final resv = await SupabaseService.createReservation(
        personId: person.id,
        roomId: widget.room.id,
        start: _start!,
        end: _end!,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Réservation créée !')));
      Navigator.of(context).pop(); // retourne à la liste
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.room;
    return Scaffold(
      appBar: AppBar(title: Text('Réserver chambre ${r.number}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Détails', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Chambre ${r.number} • ${r.category ?? ''} • ${r.beds} lit(s)'),
            SizedBox(height: 16),
            Text('Dates', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _pickStart, child: Text('Début: ${fmt(_start)}'))),
                SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: _pickEnd, child: Text('Fin: ${fmt(_end)}'))),
              ],
            ),
            SizedBox(height: 16),
            Text('Informations client', style: TextStyle(fontSize: 16)),
            TextField(controller: _firstNameCtrl, decoration: InputDecoration(labelText: 'Prénom')),
            TextField(controller: _lastNameCtrl, decoration: InputDecoration(labelText: 'Nom (facultatif)')),
            TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: 'Téléphone (facultatif)')),
            SizedBox(height: 20),
            _loading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: Text('Confirmer la réservation')),
          ],
        ),
      ),
    );
  }
}
