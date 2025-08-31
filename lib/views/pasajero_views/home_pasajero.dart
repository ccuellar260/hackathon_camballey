import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/database_service.dart';
import '../../models/micro.dart';
import '../../controllers/login_controller.dart';

class HomePasajero extends StatefulWidget {
  const HomePasajero({super.key});

  @override
  _HomePasajeroState createState() => _HomePasajeroState();
}

class _HomePasajeroState extends State<HomePasajero> {
  int? _selectedMicro; // Variable para el micro seleccionado
  double _sliderPosition = 0.0; // Posición del slider
  bool _isSliderCompleted = false; // Si el slider se completó
  bool _isPaymentProcessing = false; // Para evitar múltiples pagos
  List<Micro> _nearbyMicros = []; // Lista de micros desde base de datos
  List<Micro> _allMicros = []; // Lista completa de micros disponibles
  bool _isDetecting = false; // Estado de detección de micros
  Timer? _detectionTimer; // Timer para la simulación

  @override
  void initState() {
    super.initState();
    _loadAllMicros();
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllMicros() async {
    try {
      final micros = await DatabaseService.getMicrosActivos();
      print("===> Micros cargados: $micros");
      setState(() {
        _allMicros = micros;
      });
      
      // Iniciar simulación de detección
      _startDetectionSimulation();
    } catch (e) {
      print('==> Error cargando micros: $e');
      setState(() {
        _allMicros = [];
      });
    }
  }

  void _startDetectionSimulation() {
    _simulateDetection();
  }

  void _simulateDetection() {
    if (_allMicros.isEmpty) return;
    
    setState(() {
      _isDetecting = true;
    });
    
    // Fase 1: Mostrar micros por 15 segundos
    _showRandomMicros();
    
    _detectionTimer = Timer(const Duration(seconds: 15), () {
      // Verificar si el micro seleccionado estaba en la lista anterior
      final microSeleccionadoAnterior = _selectedMicro != null ? _nearbyMicros[_selectedMicro!] : null;
      
      // Fase 2: No mostrar micros por 6 segundos
      setState(() {
        _nearbyMicros = [];
        _selectedMicro = null; // Deseleccionar siempre cuando desaparecen
        _isDetecting = false;
        _isPaymentProcessing = false; // Resetear procesamiento también
      });
      
      // Mostrar mensaje si había un micro seleccionado
      if (microSeleccionadoAnterior != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('El Micro ${microSeleccionadoAnterior.numeroMicro} se alejó de tu ubicación'),
              ],
            ),
            backgroundColor: Colors.orange[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 50,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
      
      _detectionTimer = Timer(const Duration(seconds: 6), () {
        // Repetir el ciclo
        _simulateDetection();
      });
    });
  }

  void _showRandomMicros() {
    final random = Random();
    final cantidadMicros = random.nextInt(3) + 1; // De 1 a 3 micros
    final microsSeleccionados = <Micro>[];
    
    // Seleccionar micros aleatorios sin repetir
    final allMicrosCopy = List<Micro>.from(_allMicros);
    
    for (int i = 0; i < cantidadMicros && allMicrosCopy.isNotEmpty; i++) {
      final index = random.nextInt(allMicrosCopy.length);
      microsSeleccionados.add(allMicrosCopy[index]);
      allMicrosCopy.removeAt(index);
    }
    
    // Verificar si el micro previamente seleccionado sigue disponible
    final microSeleccionadoAnterior = _selectedMicro != null ? _nearbyMicros[_selectedMicro!] : null;
    bool microSigueDisponible = false;
    int nuevoIndice = -1;
    
    if (microSeleccionadoAnterior != null) {
      for (int i = 0; i < microsSeleccionados.length; i++) {
        if (microsSeleccionados[i].id == microSeleccionadoAnterior.id) {
          microSigueDisponible = true;
          nuevoIndice = i;
          break;
        }
      }
    }
    
    setState(() {
      _nearbyMicros = microsSeleccionados;
      
      // Si el micro anterior sigue disponible, mantener la selección
      // Si no, deseleccionar
      if (microSigueDisponible && nuevoIndice >= 0) {
        _selectedMicro = nuevoIndice;
      } else {
        _selectedMicro = null;
        
        // Mostrar notificación si había un micro seleccionado que ya no está
        if (microSeleccionadoAnterior != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Micro ${microSeleccionadoAnterior.numeroMicro} ya no está disponible'),
                  ],
                ),
                backgroundColor: Colors.amber[700],
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(
                  bottom: 50,
                  left: 16,
                  right: 16,
                ),
              ),
            );
          });
        }
      }
    });
    
    print('==> Simulación: Mostrando ${microsSeleccionados.length} micros cercanos');
    if (microSeleccionadoAnterior != null) {
      print('==> Micro anterior: ${microSeleccionadoAnterior.numeroMicro}, sigue disponible: $microSigueDisponible');
    }
  }

  void _onSliderUpdate(double position) {
    if (_isPaymentProcessing) return; // No permitir cambios si ya se está procesando
    
    setState(() {
      _sliderPosition = position;
      _isSliderCompleted = position >= 0.65; // Reducir a 85% para que sea más fácil
    });
    
    // Si se completó el deslizamiento y no se está procesando ya, mostrar toast y procesar pago
    if (_isSliderCompleted && !_isPaymentProcessing) {
      _procesarPago();
    }
  }

  void _procesarPago() async {
    if (_selectedMicro == null || _isPaymentProcessing) return;
    
    // Activar bandera para evitar múltiples procesamientos
    setState(() {
      _isPaymentProcessing = true;
    });
    
    final microSeleccionado = _nearbyMicros[_selectedMicro!];
    
    // Mostrar toast de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('¡Pago realizado! Bs. ${microSeleccionado.tarifa.toStringAsFixed(2)} - Micro ${microSeleccionado.numeroMicro}'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 50,  // Elevar el toast para que se vea arriba
          left: 16,
          right: 16,
        ),
      ),
    );
    
    // Resetear el slider después de un delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _resetSlider();
      setState(() {
        _selectedMicro = null; // Limpiar selección
        _isPaymentProcessing = false; // Desactivar bandera
      });
    });
    
    // Guardar transacción en la base de datos
    try {
      final usuarioId = LoginController.instance.currentUser?.id;
      
      if (usuarioId != null) {
        final exito = await DatabaseService.insertarTransaccion(
          usuarioId: usuarioId,
          microId: microSeleccionado.id,
          monto: microSeleccionado.tarifa,
        );
        
        if (exito) {
          print('==> Transacción guardada exitosamente en la BD');
        } else {
          print('==> Error al guardar la transacción en la BD');
          // Mostrar mensaje de error al usuario
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Error al registrar el pago. Contacta soporte.'),
                  ],
                ),
                backgroundColor: Colors.orange[600],
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        print('==> Error: No hay usuario logueado');
      }
    } catch (e) {
      print('==> Error guardando transacción: $e');
    }
    
    print('==> Pago procesado para micro: ${microSeleccionado.numeroMicro}, tarifa: ${microSeleccionado.tarifa}');
  }

  void _resetSlider() {
    // Animación suave de retorno al inicio
    const steps = 10;
    const stepDuration = Duration(milliseconds: 30);
    
    for (int i = 1; i <= steps; i++) {
      Future.delayed(stepDuration * i, () {
        if (mounted) {
          setState(() {
            _sliderPosition = _sliderPosition * (1 - i / steps);
            if (i == steps) {
              _sliderPosition = 0.0;
              _isSliderCompleted = false;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centrar el título
         title: Text(
          'Hola, ${LoginController.instance.userName.isNotEmpty ? LoginController.instance.userName : "Usuario"}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona un micro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_nearbyMicros.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${_nearbyMicros.length} micro${_nearbyMicros.length > 1 ? 's' : ''} detectado${_nearbyMicros.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: _nearbyMicros.isEmpty 
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _nearbyMicros.length,
                            itemBuilder: (context, index) {
                              return _buildMicroCard(index);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Slider de pago al final de la pantalla
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              top: false,
              child: _selectedMicro != null 
                  ? _buildSliderToPay() 
                  : _buildDisabledSlider(),
            ),
          ),
        ],
      ),
    );
  }

  // Estado vacío cuando no hay micros cercanos
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: _isDetecting 
                ? const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : Icon(
                    Icons.location_searching,
                    size: 64,
                    color: Colors.grey[400],
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            _isDetecting ? 'Buscando micros...' : 'No hay micros cerca',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isDetecting 
                ? 'Detectando transporte público en tu área...\nEspera un momento.'
                : 'No hay transporte disponible en este momento.\nEsperando próximos micros...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (_isDetecting) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar, color: Colors.blue[600], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Detección activa',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Construir tarjeta de micro (método extraído)
  Widget _buildMicroCard(int index) {
    final micro = _nearbyMicros[index];
    
    return GestureDetector(
      onTap: () {
        // Resaltar selección
        setState(() {
          _selectedMicro = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _selectedMicro == index
              ? Colors.blue[50] // Fondo seleccionado
              : Colors.white,
          border: Border.all(
            color: _selectedMicro == index
                ? Colors.blue // Borde azul cuando está seleccionado
                : Colors.grey.shade300,
            width: _selectedMicro == index ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícono del micro
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMicro == index
                      ? Colors.blue[100]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_bus,
                  size: 32,
                  color: _selectedMicro == index
                      ? Colors.blue[700]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              // Información del micro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Micro ${micro.numeroMicro}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: _selectedMicro == index
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: _selectedMicro == index
                            ? Colors.blue[700]
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Línea ${micro.linea} - ${micro.rutaDescripcion}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bs. ${micro.tarifa.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Indicador de selección
              if (_selectedMicro == index)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Slider arrastrable para confirmar pago
  Widget _buildSliderToPay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - 64; // Más espacio para el botón
        final buttonPosition = _sliderPosition * maxWidth;
        
        return Container(
          height: 60, // Aumentar altura para mejor área de toque
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Fondo del slider con progreso
              Container(
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: _sliderPosition,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isSliderCompleted 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1)
                    ),
                  ),
                ),
              ),
              // Texto del slider
              Center(
                child: Text(
                  _isSliderCompleted 
                      ? '¡Confirmado! Procesando...'
                      : 'Desliza para pagar Bs. ${_nearbyMicros[_selectedMicro!].tarifa.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isSliderCompleted ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Botón deslizante mejorado
              AnimatedPositioned(
                duration: Duration(milliseconds: _isSliderCompleted ? 300 : 100),
                left: buttonPosition + 4,
                top: 4,
                child: GestureDetector(
                  onPanStart: (details) {
                    // Agregar feedback háptico al iniciar
                    // HapticFeedback.lightImpact();
                  },
                  onPanUpdate: (details) {
                    if (_isPaymentProcessing) return;
                    
                    // Calcular nueva posición basada en el movimiento del dedo
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(details.globalPosition);
                    final newPosition = (localPosition.dx - 32) / maxWidth; // Centrar en el botón
                    
                    _onSliderUpdate(newPosition.clamp(0.0, 1.0));
                  },
                  onPanEnd: (details) {
                    if (!_isSliderCompleted && !_isPaymentProcessing) {
                      // Animación de retorno más suave
                      _resetSlider();
                    }
                  },
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: _isSliderCompleted ? Colors.green[600] : Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isSliderCompleted ? Icons.check : Icons.arrow_forward,
                      color: _isSliderCompleted ? Colors.white : Colors.blue[700],
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Slider deshabilitado
  Widget _buildDisabledSlider() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(
              Icons.lock,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Selecciona un micro primero',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
