class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final String tipoCuenta;
  final double saldo;
  final int viajesRealizados;
  final int viajesGratisDisponibles;
  final DateTime fechaRegistro;
  final int activo;
  final String pinSeguridad;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.tipoCuenta,
    required this.saldo,
    required this.viajesRealizados,
    required this.viajesGratisDisponibles,
    required this.fechaRegistro,
    required this.activo,
    required this.pinSeguridad,
  });

  // Crear desde Map (resultado de consulta SQL)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: int.tryParse(map['id'].toString()) ?? 0,
      nombre: map['nombre']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      telefono: map['telefono']?.toString() ?? '',
      tipoCuenta: map['tipo_cuenta']?.toString() ?? '',
      saldo: double.tryParse(map['saldo'].toString()) ?? 0.0,
      viajesRealizados: int.tryParse(map['viajes_realizados'].toString()) ?? 0,
      viajesGratisDisponibles: int.tryParse(map['viajes_gratis_disponibles'].toString()) ?? 0,
      fechaRegistro: DateTime.tryParse(map['fecha_registro']?.toString() ?? '') ?? DateTime.now(),
      activo: int.tryParse(map['activo'].toString()) ?? 0,
      pinSeguridad: map['pin_seguridad']?.toString() ?? '',
    );
  }

  // Convertir a Map (para insertar/actualizar)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'tipo_cuenta': tipoCuenta,
      'saldo': saldo,
      'viajes_realizados': viajesRealizados,
      'viajes_gratis_disponibles': viajesGratisDisponibles,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'activo': activo,
      'pin_seguridad': pinSeguridad,
    };
  }

  // Verificar si el usuario está activo
  bool get estaActivo => activo == 1;

  // Verificar si tiene viajes gratis disponibles
  bool get tieneViajesGratis => viajesGratisDisponibles > 0;

  // Verificar si tiene saldo suficiente para un viaje
  bool tieneSaldoSuficiente(double tarifaViaje) => saldo >= tarifaViaje;

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre, email: $email, saldo: $saldo)';
  }
}
