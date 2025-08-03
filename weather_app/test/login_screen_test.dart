import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/screens/login_screen.dart';
import 'package:weather_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: LoginScreen(authService: mockAuthService, useSimpleGoogleButton: true),
      ),
    );
  }

  testWidgets('LoginScreen shows Google and email fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
  });

  testWidgets('Shows error for invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('Shows error for short password', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Min 6 characters'), findsOneWidget);
  });

  testWidgets('Tapping Google sign-in calls AuthService', (WidgetTester tester) async {
    when(mockAuthService.signInWithGoogle()).thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();

    verify(mockAuthService.signInWithGoogle()).called(1);
  });
}