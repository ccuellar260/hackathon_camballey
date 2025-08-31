
import 'package:flutter/material.dart';
import 'package:hackathon_camballey/views/pasajero_views/nabavar_pasajero.dart';

//rutas de la aplicacion
Map<String, WidgetBuilder> getRoutes() {
  return <String, WidgetBuilder>{
    'dashboard': (BuildContext context) => const NabavarPasajero(),
  };
}
