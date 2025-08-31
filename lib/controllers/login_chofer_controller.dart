import '../models/choferes.dart';
import '../services/database_service.dart';

class LoginChoferController {
  static LoginChoferController? _instance;
  static LoginChoferController get instance => _instance ??= LoginChoferController._();
  LoginChoferController._();

  Chofer? _currentChofer;
  Chofer? get currentChofer => _currentChofer;

  // Método de login - solo verifica si existe el teléfono
  Future<Map<String, dynamic>> login(String telefono) async {
    try {
      // Buscar chofer por teléfono
      final chofer = await _buscarChoferPorTelefono(telefono);
      
      if (chofer != null) {
        // Verificar si el chofer está activo
        if (!chofer.activo) {
          return {
            'success': false,
            'message': 'Tu cuenta está desactivada. Contacta al administrador.',
          };
        }

        // Guardar chofer actual
        _currentChofer = chofer;
        
        // Debug: Verificar que se guardó correctamente
        print('==> Chofer guardado en LoginChoferController: ${_currentChofer?.nombre}');
        print('==> ID: ${_currentChofer?.id}, Teléfono: ${_currentChofer?.telefono}');
        
        return {
          'success': true,
          'message': 'Login exitoso',
          'chofer': chofer,
        };
      } else {
        return {
          'success': false,
          'message': 'El número de teléfono no está registrado.',
        };
      }
    } catch (e) {
      print('Error en login chofer: $e');

      return {
        'success': false,
        'message': 'Error al verificar credenciales: $e',
      };
    }
  }

  // Buscar chofer por teléfono en la base de datos
  Future<Chofer?> _buscarChoferPorTelefono(String telefono) async {
    try {
      final choferData = await DatabaseService.getChoferByTelefono(telefono);
      
      if (choferData != null) {
        print('==> Datos del chofer desde BD: $choferData');
        return Chofer.fromMap(choferData);
      }
      return null;
    } catch (e) {
      print('Error buscando chofer: $e');
      print('Error detallado: ${e.runtimeType} - $e');
      return null;
    }
  }

  // Logout - limpiar sesión
  void logout() {
    _currentChofer = null;
  }

  // Verificar si hay chofer logueado
  bool get isLoggedIn => _currentChofer != null;

  // Obtener información del chofer actual
  String get choferName => _currentChofer?.nombre ?? '';
  String get choferTelefono => _currentChofer?.telefono ?? '';
  String get choferLicencia => _currentChofer?.licencia ?? '';
  double get saldoPendiente => _currentChofer?.saldoPendiente ?? 0.0;
  double get totalRecaudado => _currentChofer?.totalRecaudado ?? 0.0;
}
