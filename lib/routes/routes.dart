
import 'package:flutter/material.dart';
import 'package:hackathon_camballey/views/dashboard.dart';

//rutas de la aplicacion
Map<String, WidgetBuilder> getRoutes() {
  return <String, WidgetBuilder>{
    'dashboard': (BuildContext context) => const DashboardPage(),
  };
}
