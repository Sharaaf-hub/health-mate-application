
import 'package:flutter_test/flutter_test.dart';
import 'package:health_mate_application/main.dart';

void main() {
  testWidgets('HealthMate login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthMateApp());

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
