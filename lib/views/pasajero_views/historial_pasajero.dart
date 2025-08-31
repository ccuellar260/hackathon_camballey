import 'package:flutter/material.dart';

class HistorialPasajero extends StatelessWidget {
  const HistorialPasajero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    title: 'Micros tomados',
                    value: '42',
                    subtitle: 'viajes este mes',
                    icon: Icons.directions_bus,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReportCard(
                    title: 'Total gastado',
                    value: 'Bs. 105.00',
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
                    title: 'Línea favorita',
                    value: 'Línea A',
                    subtitle: '12 viajes',
                    icon: Icons.favorite,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReportCard(
                    title: 'Ahorro vs taxi',
                    value: 'Bs. 320.00',
                    subtitle: 'ahorrado',
                    icon: Icons.savings,
                    color: Colors.green,
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
                  'Últimas transacciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Ver filtros',
                    style: TextStyle(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista de transacciones
            _buildTransactionItem(
              'Micro 3 - Línea C',
              '- Bs. 2.50',
              'Hoy, 31 Ago 2025 - 14:30',
              Icons.directions_bus,
              Colors.red,
            ),
            _buildTransactionItem(
              'Micro 7 - Línea A',
              '- Bs. 2.50',
              'Hoy, 31 Ago 2025 - 08:15',
              Icons.directions_bus,
              Colors.red,
            ),
            _buildTransactionItem(
              'Recarga Tigo Money',
              '+ Bs. 50.00',
              'Ayer, 30 Ago 2025 - 12:00',
              Icons.add_circle,
              Colors.green,
            ),
            _buildTransactionItem(
              'Micro 1 - Línea A',
              '- Bs. 2.50',
              'Ayer, 30 Ago 2025 - 18:15',
              Icons.directions_bus,
              Colors.red,
            ),
            _buildTransactionItem(
              'Micro 5 - Línea B',
              '- Bs. 2.50',
              '29 Ago 2025 - 19:45',
              Icons.directions_bus,
              Colors.red,
            ),
            _buildTransactionItem(
              'Micro 2 - Línea A',
              '- Bs. 2.50',
              '29 Ago 2025 - 07:30',
              Icons.directions_bus,
              Colors.red,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para exportar historial o filtros
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.file_download, color: Colors.white),
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
