import 'package:chat_app/features/auth/presentation/pages/splash/splash_screen.dart';
import 'package:chat_app/features/auth/presentation/widgets/ecom_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen', () {
    Future<void> pumpSplashScreen(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    }

    testWidgets('renders all required widgets', (WidgetTester tester) async {
      await pumpSplashScreen(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byKey(const Key('splash_screen_main_stack')), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(EcomLogoWidget), findsOneWidget);
      expect(find.text('ECOMMERCE APP'), findsOneWidget);
    });

    testWidgets('displays the correct background image', (
      WidgetTester tester,
    ) async {
      await pumpSplashScreen(tester);

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        'images/splash_screen_image.png',
      );
      expect(image.fit, BoxFit.cover);
      expect(image.width, double.infinity);
      expect(image.height, double.infinity);
    });

    testWidgets('has a gradient overlay', (WidgetTester tester) async {
      await pumpSplashScreen(tester);

      final decoratedBox = tester.widget<Container>(
        find.byKey(const Key('gradient_overlay')),
      );

      final boxDecoration = decoratedBox.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isA<LinearGradient>());
    });

    testWidgets('centers the logo and app name', (WidgetTester tester) async {
      await pumpSplashScreen(tester);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });
  });
}
