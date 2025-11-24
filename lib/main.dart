import 'package:flutter/material.dart';
import 'package:perfilpublico/src/app/app_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:perfilpublico/src/services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await AdService().initializeAds();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env carregado com sucesso!");
  } catch (e) {
    debugPrint("❌ Erro ao carregar .env: $e");
  }

  // Inicializando Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    debugPrint("✅ Supabase conectado com sucesso!");
  } catch (e) {
    debugPrint("❌ Erro ao conectar Supabase: $e");
  }

  runApp(const AppWidget());
}