class Transaction {
  final int id;
  final int usuarioId;
  final int choferId;
  final int microId;
  final double monto;
  final String tipoPago;
  final String metodoDeteccion;
  final DateTime fechaTransaccion;
  final String estado;

  Transaction({
    required this.id,
    required this.usuarioId,
    required this.choferId,
    required this.microId,
    required this.monto,
    required this.tipoPago,
    required this.metodoDeteccion,
    required this.fechaTransaccion,
    required this.estado,
  });

  // Crear desde Map (resultado de consulta SQL)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: int.tryParse(map['id'].toString()) ?? 0,
      usuarioId: int.tryParse(map['usuario_id'].toString()) ?? 0,
      choferId: int.tryParse(map['chofer_id'].toString()) ?? 0,
      microId: int.tryParse(map['micro_id'].toString()) ?? 0,
      monto: double.tryParse(map['monto'].toString()) ?? 0.0,
      tipoPago: map['tipo_pago']?.toString() ?? '',
      metodoDeteccion: map['metodo_deteccion']?.toString() ?? '',
      fechaTransaccion: DateTime.tryParse(map['fecha_transaccion']?.toString() ?? '') ?? DateTime.now(),
      estado: map['estado']?.toString() ?? '',
    );
  }

  // Convertir a Map (para insertar/actualizar)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'chofer_id': choferId,
      'micro_id': microId,
      'monto': monto,
      'tipo_pago': tipoPago,
      'metodo_deteccion': metodoDeteccion,
      'fecha_transaccion': fechaTransaccion.toIso8601String(),
      'estado': estado,
    };
  }

  // Verificar si la transacción está completada
  bool get estaCompletada => estado.toLowerCase() == 'completado';

  // Verificar si es un viaje gratis
  bool get esViajeGratis => tipoPago.toLowerCase().contains('gratis') || monto == 0.0;

  // Verificar si es pago normal
  bool get esPagoNormal => tipoPago.toLowerCase().contains('normal') && monto > 0.0;

  // Formatear fecha para mostrar
  String get fechaFormateada {
    final now = DateTime.now();
    final difference = now.difference(fechaTransaccion);
    
    if (difference.inDays == 0) {
      return 'Hoy ${fechaTransaccion.hour.toString().padLeft(2, '0')}:${fechaTransaccion.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${fechaTransaccion.hour.toString().padLeft(2, '0')}:${fechaTransaccion.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final dias = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
      return '${dias[fechaTransaccion.weekday % 7]} ${fechaTransaccion.hour.toString().padLeft(2, '0')}:${fechaTransaccion.minute.toString().padLeft(2, '0')}';
    } else {
      return '${fechaTransaccion.day.toString().padLeft(2, '0')}/${fechaTransaccion.month.toString().padLeft(2, '0')}/${fechaTransaccion.year}';
    }
  }

  // Formatear monto para mostrar
  String get montoFormateado {
    if (esViajeGratis) {
      return 'Gratis';
    }
    return 'Bs. ${monto.toStringAsFixed(2)}';
  }

  // Obtener color según el tipo de pago
  String get colorTipoPago {
    if (esViajeGratis) return 'green';
    if (esPagoNormal) return 'blue';
    return 'grey';
  }

  // Obtener icono según el tipo de pago
  String get iconoTipoPago {
    if (esViajeGratis) return 'gift';
    if (esPagoNormal) return 'payment';
    return 'help';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, usuarioId: $usuarioId, microId: $microId, monto: $monto, estado: $estado)';
  }

  // Método para comparar transacciones (útil para ordenamiento)
  int compareTo(Transaction other) {
    return other.fechaTransaccion.compareTo(fechaTransaccion); // Más recientes primero
  }
}
