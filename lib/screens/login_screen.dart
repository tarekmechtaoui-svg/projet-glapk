// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../supabase_service.dart';
import 'rooms_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool loading = false;

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> signIn() async {
    setState(() => loading = true);
    try {
      final res = await SupabaseService.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      if (res.session != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RoomsListScreen()));
      } else {
        _showMsg('Vérifie ton email (confirmation requise) ou erreur.');
      }
    } catch (e) {
      _showMsg('Erreur: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> signUp() async {
    setState(() => loading = true);
    try {
      final res = await SupabaseService.signUp(_emailCtrl.text.trim(), _passCtrl.text);
      _showMsg('Inscription terminée. Vérifie ton email pour confirmer.');
    } catch (e) {
      _showMsg('Erreur inscription: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            SizedBox(height: 20),
            loading ? CircularProgressIndicator() : Column(
              children: [
                ElevatedButton(onPressed: signIn, child: Text('Se connecter')),
                TextButton(onPressed: signUp, child: Text('S\'inscrire')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
