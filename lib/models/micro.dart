class Micro {
  final int id;
  final String numeroMicro;
  final int linea;
  final String rutaDescripcion;
  final double tarifa;
  final int choferId;
  final int activo;

  Micro({
    required this.id,
    required this.numeroMicro,
    required this.linea,
    required this.rutaDescripcion,
    required this.tarifa,
    required this.choferId,
    required this.activo,
  });

  // Crear desde Map (resultado de consulta SQL)
  factory Micro.fromMap(Map<String, dynamic> map) {
    return Micro(
        id: int.tryParse(map['id'].toString()) ?? 0,
      numeroMicro: map['numero_micro']?.toString() ?? '',
      linea: int.tryParse(map['linea'].toString()) ?? 0,
      rutaDescripcion: map['ruta_descripcion']?.toString() ?? '',
      tarifa: double.tryParse(map['tarifa'].toString()) ?? 0.0,
      choferId: int.tryParse(map['chofer_id'].toString()) ?? 0,
      activo: int.tryParse(map['activo'].toString()) ?? 0,
    );
  }

  // Convertir a Map (para insertar/actualizar)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_micro': numeroMicro,
      'linea': linea,
      'ruta_descripcion': rutaDescripcion,
      'tarifa': tarifa,
      'chofer_id': choferId,
      'activo': activo,
    };
  }

  @override
  String toString() {
    return 'Micro(id: $id, numero: $numeroMicro, linea: $linea, ruta: $rutaDescripcion)';
  }
}
