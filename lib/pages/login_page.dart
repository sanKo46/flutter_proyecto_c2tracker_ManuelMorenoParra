import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Página de Login y Registro.
/// Permite iniciar sesión o crear una cuenta.
/// Contiene formulario para email, contraseña y nombre de usuario.
/// Se comunica con AuthService para registrar o iniciar sesión en Firebase.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Servicio que gestiona autenticación con Firebase.
  final AuthService _authService = AuthService();

  /// Controladores de los inputs del formulario.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  /// Indica si la pantalla está en modo login (true) o registro (false).
  bool isLogin = true;

  /// Indica si hay una operación de Firebase en curso.
  bool isLoading = false;

  /// Ejecuta el proceso de login o registro según el modo seleccionado.
  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    /// Validación simple de campos.
    if (email.isEmpty || password.isEmpty || (!isLogin && username.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        /// Inicia sesión con email y contraseña.
        await _authService.loginUser(email, password);
      } else {
        /// Crea un usuario nuevo en Firebase.
        await _authService.registerUser(email, password, username);
      }
    } catch (e) {
      /// Muestra error si falla autenticación.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Interfaz principal de la pantalla.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      /// Centra el formulario.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          /// Contenedor con estilo.
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            /// Contenido del formulario.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "CS2 Match Tracker",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isLogin ? 'Inicia sesión' : 'Crea tu cuenta',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 30),

                /// Campo de usuario solo visible en el registro.
                if (!isLogin)
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),

                if (!isLogin) const SizedBox(height: 16),

                /// Campo de email.
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Campo de contraseña.
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Al menos 6 caracteres',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// Botón de enviar formulario.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            isLogin ? 'Entrar' : 'Registrarse',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Botón para alternar entre login y registro.
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin
                        ? '¿No tienes cuenta? Regístrate'
                        : '¿Ya tienes cuenta? Inicia sesión',
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
