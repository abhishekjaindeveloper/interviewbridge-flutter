import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    developer.log('BlocCreated: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    developer.log('BlocEvent: ${bloc.runtimeType}, Event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    developer.log('BlocChanged: ${bloc.runtimeType}, Change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    developer.log('BlocTransition: ${bloc.runtimeType}, Transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    developer.log('BlocError: ${bloc.runtimeType}, Error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    developer.log('BlocClosed: ${bloc.runtimeType}');
  }
}
