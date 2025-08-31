import 'package:flutter/material.dart';
import 'package:hackathon_camballey/views/pasajero_views/cuenta_pasajero.dart';
import 'package:hackathon_camballey/views/pasajero_views/home_pasajero.dart';
import 'package:hackathon_camballey/views/pasajero_views/historial_pasajero.dart';
import 'package:hackathon_camballey/views/pasajero_views/billetera_pasajero.dart';

class NabavarPasajero extends StatefulWidget {
  const NabavarPasajero({super.key});

  @override
  State<NabavarPasajero> createState() => _NabavarPasajeroState();
}

class _NabavarPasajeroState extends State<NabavarPasajero> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HomePasajero(),
    const HistorialPasajero(),
    const BilleteraPasajero(),
    const CuentaPasajero(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Billetera',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}