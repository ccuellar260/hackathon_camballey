import 'package:flutter/material.dart';

class PagosPasajero extends StatelessWidget {
  const PagosPasajero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas transacciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionItem(
                    'Transporte Público - Línea 1',
                    'Bs. 2.50',
                    '31 Ago 2025 - 08:30',
                    Icons.directions_bus,
                    Colors.red,
                  ),
                  _buildTransactionItem(
                    'Transporte Público - Línea 3',
                    'Bs. 2.50',
                    '30 Ago 2025 - 18:15',
                    Icons.directions_bus,
                    Colors.red,
                  ),
                  _buildTransactionItem(
                    'Recarga de saldo',
                    '+ Bs. 50.00',
                    '30 Ago 2025 - 12:00',
                    Icons.add_circle,
                    Colors.green,
                  ),
                  _buildTransactionItem(
                    'Transporte Público - Línea 2',
                    'Bs. 2.50',
                    '29 Ago 2025 - 19:45',
                    Icons.directions_bus,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para nuevo pago
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String amount,
    String date,
    IconData icon,
    Color amountColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
