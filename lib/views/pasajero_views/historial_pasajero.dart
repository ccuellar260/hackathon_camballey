import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../controllers/login_controller.dart';
import '../../models/transaction.dart';

class HistorialPasajero extends StatefulWidget {
  const HistorialPasajero({super.key});

  @override
  _HistorialPasajeroState createState() => _HistorialPasajeroState();
}

class _HistorialPasajeroState extends State<HistorialPasajero> {
  List<Transaction> _transacciones = [];
  Map<String, dynamic> _estadisticas = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    
  print("==> Entramoa averifiacr x xd x");

    // Verificar inmediatamente si hay usuario logueado
    if (!LoginController.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          'login', 
          (route) => false,
        );
      });
      return;
    }
    
  print("==> Salidmos de veriicar xd xd x");



    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final usuarioId = LoginController.instance.currentUser?.id;
      
      // Debug: Verificar si el usuario está en memoria
      print('==> Usuario en memoria: ${LoginController.instance.currentUser?.nombre}');
      print('==> ID del usuario: $usuarioId');
      
      if (usuarioId == null) {
        setState(() {
          _error = 'No hay usuario logueado. Por favor inicia sesión nuevamente.';
          _isLoading = false;
        });
        
        // Opcional: Redirigir al login si no hay usuario
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            'login', 
            (route) => false,
          );
        });
        return;
      }

      // Cargar transacciones y estadísticas en paralelo
      final futures = await Future.wait([
        DatabaseService.getTransaccionesByUsuario(usuarioId),
        DatabaseService.getEstadisticasUsuario(usuarioId),
      ]);

      setState(() {
        _transacciones = futures[0] as List<Transaction>;
        _estadisticas = futures[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text(
          'Hola, ${LoginController.instance.userName.isNotEmpty ? LoginController.instance.userName : "Usuario"}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reportes mensuales
                      const Text(
                        'Resumen del mes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Primera fila de reportes
                      Row(
                        children: [
                          Expanded(
                            child: _buildReportCard(
                              title: 'Total viajes',
                              value: '${_estadisticas['totalTransacciones'] ?? 0}',
                              subtitle: 'transacciones',
                              icon: Icons.directions_bus,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildReportCard(
                              title: 'Total gastado',
                              value: 'Bs. ${(_estadisticas['totalGastado'] ?? 0.0).toStringAsFixed(2)}',
                              subtitle: 'en transporte',
                              icon: Icons.monetization_on,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Segunda fila de reportes
                      Row(
                        children: [
                          Expanded(
                            child: _buildReportCard(
                              title: 'Viajes gratis',
                              value: '${_estadisticas['viajesGratisUsados'] ?? 0}',
                              subtitle: 'usados',
                              icon: Icons.card_giftcard,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildReportCard(
                              title: 'Completados',
                              value: '${_estadisticas['viajesCompletados'] ?? 0}',
                              subtitle: 'exitosos',
                              icon: Icons.check_circle,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Últimas transacciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Historial de transacciones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_transacciones.isNotEmpty)
                            Text(
                              '${_transacciones.length} registros',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Lista de transacciones
                      _transacciones.isEmpty
                          ? _buildEmptyTransactions()
                          : Column(
                              children: _transacciones
                                  .map((transaction) => _buildTransactionItem(transaction))
                                  .toList(),
                            ),
                    ],
                  ),
                ),
     
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cargarDatosUsuario,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin transacciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no has realizado ningún viaje.\n¡Comienza a usar el transporte público!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isGratis = transaction.esViajeGratis;
    final amountColor = isGratis ? Colors.green : Colors.red;
    final icon = isGratis ? Icons.card_giftcard : Icons.directions_bus;
    final amount = isGratis ? 'Gratis' : '- ${transaction.montoFormateado}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(icon, color: amountColor),
        ),
        title: Text('Micro ${transaction.microId} - ${transaction.tipoPago}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.fechaFormateada),
            Text(
              'Estado: ${transaction.estado}',
              style: TextStyle(
                color: transaction.estaCompletada ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
            fontSize: 16,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
