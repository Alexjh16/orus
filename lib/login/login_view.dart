import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_model.dart';
import 'login_service.dart';
import '../map/map_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loginModel = LoginModel(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      print('Intentando login con usuario: ${loginModel.username}');
      final response = await _loginService.login(loginModel);
      print('Respuesta del login: $response');

      // Verificar si el login fue exitoso basado en la respuesta
      if (response['success'] == true ||
          response.containsKey('csrfToken') ||
          response.containsKey('token')) {
        // Login exitoso
        final message = response['message'] ?? '¡Inicio de sesión exitoso!';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar al mapa
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                name: response['name'] ?? 'Usuario',
                lastName: response['last_name'] ?? '',
                estado: response['estado'] ?? 'Desconocido',
              ),
            ),
          );
        }
      } else {
        throw Exception(
            'Credenciales incorrectas o respuesta inesperada del servidor');
      }
    } catch (e) {
      print('Error en login: $e');
      String errorMessage = 'Ocurrió un error. Inténtalo de nuevo.';
      if (e.toString().contains('401')) {
        errorMessage =
            'Credenciales incorrectas. Verifica tu usuario y contraseña.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Problema de conexión. Revisa tu internet.';
      } else if (e.toString().contains('Credenciales incorrectas')) {
        errorMessage = 'Usuario o contraseña incorrectos.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getRandomUser() async {
    try {
      print('Obteniendo usuario aleatorio...');
      final userData = await _loginService.getRandomUser();
      print('Datos del usuario aleatorio: $userData');

      final username = userData['username'] ?? 'N/A';
      final email = userData['email'] ?? 'N/A';

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Usuario Aleatorio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: $username'),
                  Text('Email: $email'),
                  const SizedBox(height: 16),
                  Text('Contraseña por defecto: 123456789a'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _usernameController.text = username;
                    _passwordController.text = '123456789a';
                    Navigator.of(context).pop();
                  },
                  child: const Text('Usar'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error al obtener usuario aleatorio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener usuario aleatorio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4052B6),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4052B6), Color(0xFF6A82FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please log in to continue',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF4052B6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF4052B6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A82FB),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Log In',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _getRandomUser,
              child: Text(
                'Get Random User',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
