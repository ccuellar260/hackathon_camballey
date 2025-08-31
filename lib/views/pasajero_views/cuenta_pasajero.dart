import 'package:flutter/material.dart';

class CuentaPasajero extends StatelessWidget {
  const CuentaPasajero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Perfil del usuario
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Juan Pérez',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'juan.perez@tigo.com.bo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            
            // Opciones de cuenta
            _buildAccountOption(
              icon: Icons.credit_card,
              title: 'Métodos de pago',
              subtitle: 'Gestionar tarjetas y cuentas',
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.security,
              title: 'Seguridad',
              subtitle: 'PIN, biometría y verificación',
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.notifications,
              title: 'Notificaciones',
              subtitle: 'Configurar alertas y avisos',
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.help,
              title: 'Ayuda y soporte',
              subtitle: 'FAQ y contacto',
              onTap: () {},
            ),
            _buildAccountOption(
              icon: Icons.info,
              title: 'Acerca de',
              subtitle: 'Versión y términos',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            
            // Botón de cerrar sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Acción de cerrar sesión
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
