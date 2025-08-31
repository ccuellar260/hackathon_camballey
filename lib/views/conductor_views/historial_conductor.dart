import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/database_service.dart';
import '../../models/transaction.dart';

class HistorialConductor extends StatefulWidget {
  const HistorialConductor({super.key});

  @override
  _HistorialConductorState createState() => _HistorialConductorState();
}

class _HistorialConductorState extends State<HistorialConductor> 
    with TickerProviderStateMixin {
  List<Transaction> _transacciones = [];
  bool _isLoading = true;
  String _error = '';
  
  // Variables para el toast
  bool _showToast = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _cargarDatosConductor();
    _initializeToastAnimation();
    _startToastTimer();
  }

  void _initializeToastAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // No ejecutar la animación inicial - el toast empieza oculto
  }

  void _startToastTimer() {
    _toastTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _toggleToast();
    });
  }

  void _toggleToast() {
    if (_showToast) {
      // Si está visible, ocultarlo
      _animationController.reverse().then((_) {
        setState(() {
          _showToast = false;
        });
        
        Timer(const Duration(seconds: 3), () {
          setState(() {
            _showToast = true;
          });
          _animationController.forward();
        });
      });
    } else {
      // Si está oculto, mostrarlo
      setState(() {
        _showToast = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosConductor() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Por simplicidad, usar ID = 1 como conductor por defecto
      const conductorId = 1;

      // Obtener transacciones donde el conductor fue el chofer
      final transacciones = await DatabaseService.getTransaccionesByConductor(conductorId);

      setState(() {
        _transacciones = transacciones;
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
        title: const Text('Últimos Pagos Realizados'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosConductor,
          ),
        ],
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
                      // Información del conductor
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person_pin, 
                                     size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Carlos Mendoza Rivera',
                                  style: TextStyle(
                                   
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ID: CNT030',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                     
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ACTIVO',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.wifi, 
                                      size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Red WiFi Asignada',
                                  style: TextStyle(
                            
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'SSID: ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'LINEA_77_INTERNO_30',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),

                                    ],
                                  ),
                                  
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Toast del último pago (aparece y desaparece cada 15 segundos)
                      if (_showToast && _transacciones.isNotEmpty)
                        AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - _fadeAnimation.value) * 20),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green[700]!, Colors.green[500]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.payment, 
                                                   color: Colors.white, size: 24),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Último Pago Realizado',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _animationController.reverse().then((_) {
                                                setState(() {
                                                  _showToast = false;
                                                });
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: _buildUltimoPagoInfo(_transacciones.first),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                      
                      // Historial de transacciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ultimos pagos realizados',
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
              onPressed: _cargarDatosConductor,
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
              Icons.directions_bus_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin viajes registrados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no has realizado ningún viaje.\n¡Empieza a conducir para ver tu historial!',
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

  Widget _buildUltimoPagoInfo(Transaction ultimaTransaccion) {
    final isGratis = ultimaTransaccion.esViajeGratis;
    final statusText = ultimaTransaccion.estaCompletada ? 'COMPLETADO' : 'PENDIENTE';
    final statusColor = ultimaTransaccion.estaCompletada ? Colors.green[200] : Colors.yellow[200];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usuario ${ultimaTransaccion.usuarioId}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
         
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGratis ? 'Viaje Gratis' : ultimaTransaccion.montoFormateado,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ultimaTransaccion.fechaFormateada,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Micro ${ultimaTransaccion.microId}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ultimaTransaccion.tipoPago,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isGratis = transaction.esViajeGratis;
    final amountColor = isGratis ? Colors.green : Colors.green;
    final icon = isGratis ? Icons.card_giftcard : Icons.monetization_on;
    final amount = isGratis ? 'Gratis' : '+ ${transaction.montoFormateado}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.1),
          child: Icon(icon, color: amountColor),
        ),
        title: Text('Usuario ${transaction.usuarioId} - ${transaction.tipoPago}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Micro ${transaction.microId} • ${transaction.fechaFormateada}'),
           
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
