class Chofer {
  final int id;
  final String nombre;
  final String cedula;
  final String telefono;
  final String licencia;
  final String macAddress;
  final double saldoPendiente;
  final double totalRecaudado;
  final DateTime fechaRegistro;
  final bool activo;

  Chofer({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.telefono,
    required this.licencia,
    required this.macAddress,
    required this.saldoPendiente,
    required this.totalRecaudado,
    required this.fechaRegistro,
    required this.activo,
  });

  // Factory constructor para crear desde Map (base de datos)
  factory Chofer.fromMap(Map<String, dynamic> map) {
    return Chofer(
      id: _parseToInt(map['id'] ?? 0),
      nombre: map['nombre']?.toString() ?? '',
      cedula: map['cedula']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      licencia: map['licencia']?.toString() ?? '',
      macAddress: map['mac_address']?.toString() ?? '',
      saldoPendiente: _parseToDouble(map['saldo_pendiente'] ?? 0.0),
      totalRecaudado: _parseToDouble(map['total_recaudado'] ?? 0.0),
      fechaRegistro: map['fecha_registro'] != null 
          ? DateTime.parse(map['fecha_registro'].toString())
          : DateTime.now(),
      activo: _parseToBool(map['activo']),
    );
  }

  // Métodos auxiliares para conversión segura de tipos
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static bool _parseToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  // Convertir a Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
      'licencia': licencia,
      'mac_address': macAddress,
      'saldo_pendiente': saldoPendiente,
      'total_recaudado': totalRecaudado,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'activo': activo ? 1 : 0,
    };
  }

  // Método para crear copia con cambios
  Chofer copyWith({
    int? id,
    String? nombre,
    String? cedula,
    String? telefono,
    String? licencia,
    String? macAddress,
    double? saldoPendiente,
    double? totalRecaudado,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return Chofer(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cedula: cedula ?? this.cedula,
      telefono: telefono ?? this.telefono,
      licencia: licencia ?? this.licencia,
      macAddress: macAddress ?? this.macAddress,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      totalRecaudado: totalRecaudado ?? this.totalRecaudado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }

  // Getters útiles
  String get saldoPendienteFormateado => 'Bs. ${saldoPendiente.toStringAsFixed(2)}';
  String get totalRecaudadoFormateado => 'Bs. ${totalRecaudado.toStringAsFixed(2)}';
  String get fechaRegistroFormateada => '${fechaRegistro.day.toString().padLeft(2, '0')}/${fechaRegistro.month.toString().padLeft(2, '0')}/${fechaRegistro.year}';
  String get estadoTexto => activo ? 'Activo' : 'Inactivo';
  
  // Método para validar si tiene saldo pendiente
  bool get tieneSaldoPendiente => saldoPendiente > 0;
  
  // Método toString para debugging
  @override
  String toString() {
    return 'Chofer{id: $id, nombre: $nombre, cedula: $cedula, telefono: $telefono, licencia: $licencia, macAddress: $macAddress, saldoPendiente: $saldoPendiente, totalRecaudado: $totalRecaudado, fechaRegistro: $fechaRegistro, activo: $activo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chofer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}