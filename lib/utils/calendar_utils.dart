import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Inicializa as configurações de localização para o calendário
Future<void> initializeCalendarLocale() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
}
