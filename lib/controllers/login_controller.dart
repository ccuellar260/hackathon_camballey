import '../models/usuario.dart';
import '../services/database_service.dart';

class LoginController {
  static LoginController? _instance;
  static LoginController get instance => _instance ??= LoginController._();
  LoginController._();

  Usuario? _currentUser;
  Usuario? get currentUser => _currentUser;

  // Método de login - solo verifica si existe el email
  Future<Map<String, dynamic>> login(String email) async {
    try {
      // Buscar usuario por email
      final usuario = await _buscarUsuarioPorEmail(email);
      
      if (usuario != null) {
        // Verificar si el usuario está activo
        if (!usuario.estaActivo) {
          return {
            'success': false,
            'message': 'Tu cuenta está desactivada. Contacta al soporte.',
          };
        }

        // Guardar usuario actual
        _currentUser = usuario;
        
        // Debug: Verificar que se guardó correctamente
        print('==> Usuario guardado en LoginController: ${_currentUser?.nombre}');
        print('==> ID: ${_currentUser?.id}, Email: ${_currentUser?.email}');
        
        return {
          'success': true,
          'message': 'Login exitoso',
          'usuario': usuario,
        };
      } else {
        return {
          'success': false,
          'message': 'El correo electrónico no está registrado.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al verificar credenciales: $e',
      };
    }
  }

  // Buscar usuario por email en la base de datos
  Future<Usuario?> _buscarUsuarioPorEmail(String email) async {
    try {
      final userData = await DatabaseService.getUserByEmail(email);
      
      if (userData != null) {
        return Usuario.fromMap(userData);
      }
      return null;
    } catch (e) {
      print('Error buscando usuario: $e');
      return null;
    }
  }

  // Logout - limpiar sesión
  void logout() {
    _currentUser = null;
  }

  // Verificar si hay usuario logueado
  bool get isLoggedIn => _currentUser != null;

  // Obtener información del usuario actual
  String get userName => _currentUser?.nombre ?? '';
  String get userEmail => _currentUser?.email ?? '';
  double get userBalance => _currentUser?.saldo ?? 0.0;
  int get userTrips => _currentUser?.viajesRealizados ?? 0;
}
