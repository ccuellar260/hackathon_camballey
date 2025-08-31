import 'package:flutter/material.dart';
import 'package:hackathon_camballey/views/conductor_views/home_conductor.dart';
import 'package:hackathon_camballey/views/conductor_views/historial_conductor.dart';
import 'package:hackathon_camballey/views/conductor_views/cuenta_conductor.dart';

class NavbarChoferes extends StatefulWidget {
  const NavbarChoferes({super.key});

  @override
  State<NavbarChoferes> createState() => _NavbarChoferesState();
}

class _NavbarChoferesState extends State<NavbarChoferes> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    
    const HistorialConductor(),
    const HomeConductor(),
    const CuentaConductor(),
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
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey[600],
        items: const [
            BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Últimos Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Mi Micro',
          ),
        
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
