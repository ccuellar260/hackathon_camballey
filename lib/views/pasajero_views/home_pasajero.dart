import 'package:flutter/material.dart';

class HomePasajero extends StatefulWidget {
  const HomePasajero({super.key});

  @override
  _HomePasajeroState createState() => _HomePasajeroState();
}

class _HomePasajeroState extends State<HomePasajero> {
  int? _selectedMicro; // Variable para el micro seleccionado

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
      body: SingleChildScrollView(
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Número de micros
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('micro_$index'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    Navigator.pushNamed(context, 'pagos'); // Navegar a pagos
                  },
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.payment, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Resaltar selección
                      setState(() {
                        _selectedMicro = index;
                      });
                    },
                    child: Card(
                      color: _selectedMicro == index
                          ? Colors.blue[50] // Resaltar seleccionado
                          : Colors.white,
                      child: ListTile(
                        title: Text('Micro $index'),
                        subtitle: const Text('Ruta hacia el destino'),
                        trailing: const Icon(Icons.directions_bus),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
