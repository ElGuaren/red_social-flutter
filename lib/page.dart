import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuariosDebugPage extends StatefulWidget {
  const UsuariosDebugPage({super.key});

  @override
  State<UsuariosDebugPage> createState() => _UsuariosDebugPageState();
}

class _UsuariosDebugPageState extends State<UsuariosDebugPage> {
  Map<String, String> nombresUsuarios = {};
  Map<String, Set<String>> conexiones = {};

  @override
  void initState() {
    super.initState();
    cargarConexiones();
  }

  Future<void> cargarConexiones() async {
    final usuariosSnap = await FirebaseFirestore.instance.collection('users').get();

    Map<String, String> nombresTemp = {};
    Map<String, Set<String>> conexionesTemp = {};

    for (var doc in usuariosSnap.docs) {
      final uid = doc.id;
      final data = doc.data();
      final nombre = data['username'] ?? uid;

      nombresTemp[uid] = nombre;
      conexionesTemp[uid] = {};

      final siguiendoSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('siguiendo')
          .get();

      for (var seguido in siguiendoSnap.docs) {
        conexionesTemp[uid]!.add(seguido.id);
      }
    }

    setState(() {
      nombresUsuarios = nombresTemp;
      conexiones = conexionesTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grafo de conexiones")),
      body: conexiones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: conexiones.entries.map((entry) {
                final uid = entry.key;
                final nombre = nombresUsuarios[uid] ?? uid;
                final seguidos = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: seguidos.isEmpty
                        ? const Text("No sigue a nadie")
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: seguidos.map((otroUid) {
                              final otroNombre = nombresUsuarios[otroUid] ?? otroUid;
                              return Text("→ $otroNombre");
                            }).toList(),
                          ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
