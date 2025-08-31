class DatabaseConfig {
  // Configuración de MySQL Azure
  static const String host = 'arthurdatabasetestingserver.mysql.database.azure.com';
  static const int port = 3306;
  static const String database = 'transporte_publico_scz';
  static const String user = 'ahsupernatura';
  static const String password = 'Floravenceagalan2_';
  
  // Configuración SSL (requerido para Azure)
  static const bool useSSL = true;
  static const bool requireSSL = true;
  static const String sslCertPath = 'assets/certificates/DigiCertGlobalRootG2.crt.pem';
  
  // String de conexión completa con SSL
  static String get connectionString =>
      'mysql://$user:$password@$host:$port/$database?ssl-mode=REQUIRED';
}
