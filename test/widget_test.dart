//import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_bridge_app/app.dart';
import 'package:interview_bridge_app/injection_container.dart' as di;
import 'package:interview_bridge_app/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock MethodChannel for flutter_secure_storage
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    // ignore: deprecated_member_use
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'readAll') {
        return <String, String>{};
      }
      return null;
    });
    
    await di.init();
  });

  testWidgets('App landing screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Pump to trigger AuthStarted and transition states
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that our login page displays the title 'Welcome Back'.
    expect(find.text(AppConstants.loginTitle), findsOneWidget);
  });
}
