import 'package:mysql_client/mysql_client.dart';
import '../config/database_config.dart';
import '../models/micro.dart';

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

  // Cerrar conexión
  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
