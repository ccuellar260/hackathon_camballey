import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/micro.dart';

class HomePasajero extends StatefulWidget {
  const HomePasajero({super.key});

  @override
  _HomePasajeroState createState() => _HomePasajeroState();
}

class _HomePasajeroState extends State<HomePasajero> {
  int? _selectedMicro; // Variable para el micro seleccionado
  double _sliderPosition = 0.0; // Posición del slider
  bool _isSliderCompleted = false; // Si el slider se completó
  List<Micro> _nearbyMicros = []; // Lista de micros desde base de datos
  bool _isLoading = true; // Estado de carga

  @override
  void initState() {
    super.initState();
    _loadNearbyMicros();
  }

  Future<void> _loadNearbyMicros() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final micros = await DatabaseService.getMicrosActivos();
      print("===> Micros cargados: $micros");
      setState(() {
        _nearbyMicros = micros;
        _isLoading = false;
      });
    } catch (e) {
      print('==> Error cargando micros: $e');
      setState(() {
        _nearbyMicros = [];
        _isLoading = false;
      });
    }
  }

  void _onSliderUpdate(double position) {
    setState(() {
      _sliderPosition = position;
      _isSliderCompleted = position >= 0.9; // 90% del camino
    });
    
    // Si se completó el deslizamiento, navegar
    if (_isSliderCompleted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pushNamed(context, 'pagos');
      });
    }
  }

  void _resetSlider() {
    setState(() {
      _sliderPosition = 0.0;
      _isSliderCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centrar el título
        title: const Text(
          'Hola, Cristian',
          style: TextStyle(
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
            child: Icon(
              Icons.location_searching,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay micros cerca',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Buscando micros en tu ubicación...\nPuede que no haya transporte disponible en este momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
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
                    color: Colors.blue[700],
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
        final maxWidth = constraints.maxWidth - 56; // Ancho disponible para deslizar
        final buttonPosition = _sliderPosition * maxWidth;
        
        return Stack(
          children: [
            // Fondo del slider
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  _isSliderCompleted 
                      ? '¡Confirmado! Procesando...'
                      : 'Desliza para pagar Micro ${_selectedMicro! + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _isSliderCompleted ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Botón deslizante
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: buttonPosition + 4,
              top: 4,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final newPosition = (buttonPosition + details.delta.dx) / maxWidth;
                  _onSliderUpdate(newPosition.clamp(0.0, 1.0));
                },
                onPanEnd: (details) {
                  if (!_isSliderCompleted) {
                    _resetSlider(); // Volver al inicio si no se completó
                  }
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: _isSliderCompleted ? Colors.green : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isSliderCompleted ? Icons.check : Icons.arrow_forward,
                    color: _isSliderCompleted ? Colors.white : Colors.blue[700],
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Slider deshabilitado
  Widget _buildDisabledSlider() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Center(
        child: Text(
          'Selecciona un micro primero',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
