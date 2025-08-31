
import 'package:flutter/material.dart';
import 'package:hackathon_camballey/views/login_views/login_chofer.dart';
import 'package:hackathon_camballey/views/login_views/login_view.dart';
import 'package:hackathon_camballey/views/pasajero_views/nabavar_pasajero.dart';
import 'package:hackathon_camballey/views/pasajero_views/historial_pasajero.dart';
import 'package:hackathon_camballey/views/conductor_views/navbar_choferes.dart';

//rutas de la aplicacion
Map<String, WidgetBuilder> getRoutes() {
  return <String, WidgetBuilder>{
    'dashboard': (BuildContext context) => const NabavarPasajero(),
    'pagos': (BuildContext context) => const HistorialPasajero(),
    'login': (BuildContext context) => const LoginView(),
    'login_chofer': (BuildContext context) => const LoginChoferView(),
    'dashboard_chofer': (BuildContext context) => const NavbarChoferes(),
  };
}
