import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/bloc_observer/app_bloc_observer.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global BLoC observer
  Bloc.observer = AppBlocObserver();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const App());
}
