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

    // Verify that the Splash Screen displays on initial load.
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.splashTagline), findsOneWidget);

    // Pump to run the 3-second splash screen timer and complete the navigation transition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();

    // Verify that we successfully navigated to the Landing Page.
    expect(find.text(AppConstants.landingHeroTitle), findsOneWidget);
    expect(find.text(AppConstants.getStartedButton), findsOneWidget);
  });
}
