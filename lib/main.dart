import 'package:flutter/material.dart';
import 'package:perfilpublico/src/app/app_widget.dart';
import 'package:perfilpublico/src/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().initializeAds();
  runApp(const AppWidget());
}