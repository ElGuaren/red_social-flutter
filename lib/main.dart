import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Social Simple',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthWrapper(),
    );
  }
}

// ---------- DETERMINAR PANTALLA INICIAL ----------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

// ---------------- LOGIN ----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
      await asegurarUsuarioEnFirestore();
    } catch (e) {
      _show("Error: $e");
    }
  }

  Future<void> asegurarUsuarioEnFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': user.email?.split('@')[0],
        'email': user.email,
      });
    }
  }

  Future<void> _recover() async {
    if (_email.text.isEmpty) {
      _show("Ingresa tu correo");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      _show("Correo de recuperación enviado");
    } catch (e) {
      _show("Error: $e");
    }
  }

  void _goToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo')),
          const SizedBox(height: 12),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _login, child: const Text("Ingresar")),
          TextButton(onPressed: _recover, child: const Text("¿Olvidaste tu contraseña?")),
          TextButton(onPressed: _goToRegister, child: const Text("Registrarse")),
        ]),
      ),
    );
  }
}

// ---------------- REGISTRO ----------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _repeat = TextEditingController();

  Future<void> _register() async {
    if (_pass.text != _repeat.text) {
      _show("Las contraseñas no coinciden");
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': _email.text.trim().split('@')[0],
        'email': _email.text.trim(),
      });

      Navigator.pop(context);
    } catch (e) {
      _show("Error: $e");
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo')),
          const SizedBox(height: 12),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
          const SizedBox(height: 12),
          TextField(controller: _repeat, obscureText: true, decoration: const InputDecoration(labelText: 'Repetir contraseña')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _register, child: const Text("Registrarse")),
        ]),
      ),
    );
  }
}
// ---------------- HOME / FEED ----------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController();
  String? _imageUrl;  // Almacena la URL de la imagen
  bool _isUploading = false;  // Controlador para mostrar el progreso de la carga

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed de Publicaciones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final postId = doc.id;
              final likes = data['likes'] ?? [];
              final isLiked = likes.contains(user?.uid);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen ajustada
                    if (data['imageUrl'] != null)
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(data['imageUrl']),
                            fit: BoxFit.cover, // Ajusta la imagen sin distorsionarla
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data['text'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Sección de like
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () async {
                              await _toggleLike(postId, user!.uid, likes);
                            },
                          ),
                          Text('Likes: ${likes.length}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _toggleLike(String postId, String uid, List likes) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (likes.contains(uid)) {
      // Si ya ha dado like, eliminarlo
      await postRef.update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      // Si no ha dado like, agregarlo
      await postRef.update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva publicación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(hintText: 'Pega la URL de la imagen'),
              onChanged: (url) {
                setState(() {
                  _imageUrl = url;  // Almacena la URL proporcionada
                });
              },
            ),
            // Muestra la previsualización de la imagen si se ingresó una URL
            if (_imageUrl != null && _imageUrl!.isNotEmpty)
              Image.network(_imageUrl!, width: 100, height: 100),
            TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Escribe algo...')),
            if (_isUploading) const CircularProgressIndicator(), // Mostrar indicador de carga
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty || _imageUrl == null || _imageUrl!.isEmpty) return;

              final uid = FirebaseAuth.instance.currentUser?.uid;

              setState(() {
                _isUploading = true; // Inicia la carga
              });

              await FirebaseFirestore.instance.collection('posts').add({
                'text': text,
                'imageUrl': _imageUrl,  // Almacena la URL de la imagen
                'timestamp': FieldValue.serverTimestamp(),
                'likes': [],
                'author': uid,
              });

              setState(() {
                _isUploading = false;  // Termina la carga
              });

              Navigator.pop(context);
            },
            child: const Text("Publicar"),
          ),
        ],
      ),
    );
  }
}









// ---------------- PERFIL ----------------

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> seguirUsuario(String miUid, String otroUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(miUid)
        .collection('siguiendo')
        .doc(otroUid)
        .set({});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(otroUid)
        .collection('seguidores')
        .doc(miUid)
        .set({});
  }

  Future<void> dejarDeSeguirUsuario(String miUid, String otroUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(miUid)
        .collection('siguiendo')
        .doc(otroUid)
        .delete();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(otroUid)
        .collection('seguidores')
        .doc(miUid)
        .delete();
  }

  Future<Set<String>> obtenerUsuariosSeguidos(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('siguiendo')
        .get();

    return snap.docs.map((doc) => doc.id).toSet();
  }

  Future<List<Map<String, dynamic>>> obtenerTodosMenosYo() async {
    if (user == null) return [];
    final miUid = user!.uid;

    final usuariosSnap = await FirebaseFirestore.instance.collection('users').get();
    final seguidos = await obtenerUsuariosSeguidos(miUid);

    List<Map<String, dynamic>> resultado = [];

    for (var doc in usuariosSnap.docs) {
      final uid = doc.id;
      final data = doc.data();
      if (uid == miUid) continue;

      resultado.add({
        'uid': uid,
        'username': data['username'] ?? uid,
        'yaSeguido': seguidos.contains(uid),
      });
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Correo: ${user?.email ?? 'Desconocido'}"),
            Text("UID: ${user?.uid ?? 'Desconocido'}"),
            const SizedBox(height: 20),
            const Text("Usuarios sugeridos:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuariosDebugPage()));
              },
              icon: const Icon(Icons.group),
              label: const Text("Ver grafo"),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: obtenerTodosMenosYo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final sugerencias = snapshot.data ?? [];
                if (sugerencias.isEmpty) {
                  return const Text("No hay usuarios disponibles.");
                }

                return Column(
                  children: sugerencias.map((usuario) {
                    return ListTile(
                      title: Text(usuario['username']),
                      subtitle: Text(usuario['uid']),
                      trailing: usuario['yaSeguido']
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text("Dejar de seguir"),
                              onPressed: () async {
                                await dejarDeSeguirUsuario(user!.uid, usuario['uid']);
                                setState(() {});
                              },
                            )
                          : ElevatedButton(
                              child: const Text("Seguir"),
                              onPressed: () async {
                                await seguirUsuario(user!.uid, usuario['uid']);
                                setState(() {});
                              },
                            ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
