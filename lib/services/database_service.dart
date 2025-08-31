import 'package:mysql_client/mysql_client.dart';
import '../config/database_config.dart';
import '../models/micro.dart';
import '../models/transaction.dart';

class DatabaseService {
  static MySQLConnection? _connection;

  // Conectar a la base de datos
  static Future<MySQLConnection> _getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    _connection = await MySQLConnection.createConnection(
      host: DatabaseConfig.host,
      port: DatabaseConfig.port,
      userName: DatabaseConfig.user,
      password: DatabaseConfig.password,
      databaseName: DatabaseConfig.database,
      secure: true, // Usar SSL
    );

    await _connection!.connect();
    return _connection!;
  }

  // Probar conexión
  static Future<bool> testConnection() async {
    try {
      final conn = await _getConnection();
      final result = await conn.execute('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // Obtener todos los micros activos
  static Future<List<Micro>> getMicrosActivos() async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        'SELECT id, numero_micro, linea, ruta_descripcion, tarifa, chofer_id, activo FROM micros WHERE activo = 1'
      );
      
      return results.rows.map((row) => Micro.fromMap(row.assoc())).toList();
    } catch (e) {
      print('Error obteniendo micros: $e');
      throw Exception('Error obteniendo micros: $e');
    }
  }

  // Obtener todos los micros
  static Future<List<Micro>> getAllMicros() async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        'SELECT id, numero_micro, linea, ruta_descripcion, tarifa, chofer_id, activo FROM micros'
      );
      
      return results.rows.map((row) => Micro.fromMap(row.assoc())).toList();
    } catch (e) {
      print('Error obteniendo todos los micros: $e');
      return [];
    }
  }

  // Obtener micro por ID
  static Future<Micro?> getMicroById(int id) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        'SELECT id, numero_micro, linea, ruta_descripcion, tarifa, chofer_id, activo FROM micros WHERE id = ?',
        {'id': id}
      );
      
      if (results.rows.isNotEmpty) {
        return Micro.fromMap(results.rows.first.assoc());
      }
      return null;
    } catch (e) {
      print('Error obteniendo micro por ID: $e');
      return null;
    }
  }

  // Obtener usuario por email
  static Future<dynamic> getUserByEmail(String email) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        'SELECT * FROM usuarios WHERE email = :email',
        {'email': email}
      );
      
      if (results.rows.isNotEmpty) {
        return results.rows.first.assoc();
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario por email: $e');
      return null;
    }
  }

  // Obtener chofer por teléfono
  static Future<dynamic> getChoferByTelefono(String telefono) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        'SELECT * FROM choferes WHERE telefono = :telefono',
        {'telefono': telefono}
      );
      
      if (results.rows.isNotEmpty) {
        return results.rows.first.assoc();
      }
      return null;
    } catch (e) {
      print('Error obteniendo chofer por teléfono: $e');
      throw Exception('Error obteniendo chofer por teléfono: $e');
    }
  }

  // Obtener por usuarioId
  static Future<List<Transaction>> getTransaccionesByUsuario(int usuarioId) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        '''
           SELECT * FROM transacciones 
           WHERE usuario_id = :usuarioId 
           ORDER BY fecha_transaccion DESC
        ''',
        {'usuarioId': usuarioId}
      );

      print("resul:   ",  );

      
      return results.rows.map((row) => Transaction.fromMap(row.assoc())).toList();
   
   
   
    } catch (e) {
      print('Error obteniendo transacciones del usuario: $e');
      throw Exception('Error obteniendo transacciones: $e');
    }
  }

  // Obtener transacciones recientes de un usuario (últimas N transacciones)
  static Future<List<Transaction>> getTransaccionesRecientes(int usuarioId, {int limite = 10}) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        '''SELECT id, usuario_id, chofer_id, micro_id, monto, tipo_pago, 
                  metodo_deteccion, fecha_transaccion, estado 
           FROM transacciones 
           WHERE usuario_id = :usuarioId 
           ORDER BY fecha_transaccion DESC 
           LIMIT :limite''',
        {'usuarioId': usuarioId, 'limite': limite}
      );
      
      return results.rows.map((row) => Transaction.fromMap(row.assoc())).toList();
    } catch (e) {
      print('Error obteniendo transacciones recientes: $e');
      return [];
    }
  }

  // Obtener transacciones por rango de fechas
  static Future<List<Transaction>> getTransaccionesByFecha(
    int usuarioId, 
    DateTime fechaInicio, 
    DateTime fechaFin
  ) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        '''SELECT id, usuario_id, chofer_id, micro_id, monto, tipo_pago, 
                  metodo_deteccion, fecha_transaccion, estado 
           FROM transacciones 
           WHERE usuario_id = :usuarioId 
           AND fecha_transaccion BETWEEN :fechaInicio AND :fechaFin
           ORDER BY fecha_transaccion DESC''',
        {
          'usuarioId': usuarioId,
          'fechaInicio': fechaInicio.toIso8601String(),
          'fechaFin': fechaFin.toIso8601String()
        }
      );
      
      return results.rows.map((row) => Transaction.fromMap(row.assoc())).toList();
    } catch (e) {
      print('Error obteniendo transacciones por fecha: $e');
      return [];
    }
  }

  // Obtener estadísticas de transacciones del usuario
  static Future<Map<String, dynamic>> getEstadisticasUsuario(int usuarioId) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        '''SELECT 
             COUNT(*) as total_transacciones,
             SUM(CASE WHEN tipo_pago = 'normal' THEN monto ELSE 0 END) as total_gastado,
             COUNT(CASE WHEN tipo_pago LIKE '%gratis%' THEN 1 END) as viajes_gratis_usados,
             COUNT(CASE WHEN estado = 'completado' THEN 1 END) as viajes_completados
           FROM transacciones 
           WHERE usuario_id = :usuarioId''',
        {'usuarioId': usuarioId}
      );
      
      if (results.rows.isNotEmpty) {
        final row = results.rows.first.assoc();
        return {
          'totalTransacciones': int.tryParse(row['total_transacciones']?.toString() ?? '0') ?? 0,
          'totalGastado': double.tryParse(row['total_gastado']?.toString() ?? '0.0') ?? 0.0,
          'viajesGratisUsados': int.tryParse(row['viajes_gratis_usados']?.toString() ?? '0') ?? 0,
          'viajesCompletados': int.tryParse(row['viajes_completados']?.toString() ?? '0') ?? 0,
        };
      }
      
      return {
        'totalTransacciones': 0,
        'totalGastado': 0.0,
        'viajesGratisUsados': 0,
        'viajesCompletados': 0,
      };
    } catch (e) {
      print('Error obteniendo estadísticas del usuario: $e');
      return {
        'totalTransacciones': 0,
        'totalGastado': 0.0,
        'viajesGratisUsados': 0,
        'viajesCompletados': 0,
      };
    }
  }

 
  static Future<List<Transaction>> getTransaccionesByConductor(int choferId) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        '''SELECT t.id, t.usuario_id, t.chofer_id, t.micro_id, t.monto, t.tipo_pago, 
                  t.metodo_deteccion, t.fecha_transaccion, t.estado, u.nombre 
           FROM transacciones t
           LEFT JOIN usuarios u ON t.usuario_id = u.id
           WHERE t.chofer_id = :choferId 
           ORDER BY t.fecha_transaccion DESC''',



        {'choferId': choferId}
      );

      print(""  );
      
      return results.rows.map((row) => Transaction.fromMap(row.assoc())).toList();
    } catch (e) {
      print('Error obteniendo transacciones del conductor: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getEstadisticasConductor(int choferId) async {
    try {
      final conn = await _getConnection();
      final results = await conn.execute(
        '''SELECT 
             COUNT(*) as total_viajes,
             SUM(CASE WHEN tipo_pago = 'normal' THEN monto ELSE 0 END) as total_ingresos,
             COUNT(CASE WHEN tipo_pago LIKE '%gratis%' THEN 1 END) as viajes_gratis,
             COUNT(CASE WHEN estado = 'completado' THEN 1 END) as viajes_completados,
             COUNT(DISTINCT usuario_id) as pasajeros_unicos
           FROM transacciones 
           WHERE chofer_id = :choferId''',
        {'choferId': choferId}
      );
      
      if (results.rows.isNotEmpty) {
        final row = results.rows.first.assoc();
        return {
          'totalViajes': int.tryParse(row['total_viajes']?.toString() ?? '0') ?? 0,
          'totalIngresos': double.tryParse(row['total_ingresos']?.toString() ?? '0.0') ?? 0.0,
          'viajesGratis': int.tryParse(row['viajes_gratis']?.toString() ?? '0') ?? 0,
          'viajesCompletados': int.tryParse(row['viajes_completados']?.toString() ?? '0') ?? 0,
          'pasajerosUnicos': int.tryParse(row['pasajeros_unicos']?.toString() ?? '0') ?? 0,
        };
      }
      
      return {
        'totalViajes': 0,
        'totalIngresos': 0.0,
        'viajesGratis': 0,
        'viajesCompletados': 0,
        'pasajerosUnicos': 0,
      };
    } catch (e) {
      print('Error obteniendo estadísticas del conductor: $e');
      return {
        'totalViajes': 0,
        'totalIngresos': 0.0,
        'viajesGratis': 0,
        'viajesCompletados': 0,
        'pasajerosUnicos': 0,
      };
    }
  }

  // Insertar nueva transacción
  static Future<bool> insertarTransaccion({
    required int usuarioId,
    required int microId,
    required double monto,
  }) async {
    try {
      final conn = await _getConnection();
      
      const query = '''
        INSERT INTO transacciones (
          usuario_id, 
          chofer_id, 
          micro_id, 
          monto, 
          tipo_pago, 
          metodo_deteccion, 
          fecha_transaccion, 
          estado
        ) VALUES (:usuarioId, :choferId, :microId, :monto, :tipoPago, :metodoDeteccion, NOW(), :estado)
      ''';
      
      final result = await conn.execute(
        query,
        {
          'usuarioId': usuarioId,
          'choferId': 1, // choferId fijo
          'microId': microId,
          'monto': monto,
          'tipoPago': 'normal', // tipoPago
          'metodoDeteccion': '00:11:22:33:44:55', // metodoDeteccion (MAC address)
          'estado': 'completado', // estado
        },
      );
      
      print('==> Transacción insertada exitosamente. ID: ${result.lastInsertID}');
      return true;
      
    } catch (e) {
      print('Error insertando transacción: $e');
      return false;
    }
  }

  // Cerrar conexión
  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
