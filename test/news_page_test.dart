import 'package:flutter_tdd_widget_integration_test_mocktail/article.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_change_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_page.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test 1 Content'),
    Article(title: 'Test 2', content: 'Test 2 Content'),
    Article(title: 'Test 3', content: 'Test 3 Content'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => articlesFromService);
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return articlesFromService;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets(
    "title is displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text("News"), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2SecondWait();

      /// render widget
      await tester.pumpWidget(createWidgetUnderTest());

      /// rebuilds widgets and frames for the specified duration.
      await tester.pump(const Duration(milliseconds: 500));

      // expect(find.byType(CircularProgressIndicator), findsOneWidget);

      /// if the in the screen have same type multiple of widget
      /// use key for get specific the widget that we want to test
      expect(find.byKey(const Key('progress-indicator')), findsOneWidget);

      /// same with pump method,
      /// but is called repeatedly until there are no more frames to rebuild
      await tester.pumpAndSettle();

      /// why we use pumpAndSettle() ?
      /// Because the tests actually create a fake async zone let's call the sandbox so the future don't actually run in their true amount of time right so two seconds doesn't necessarily
      /// mean two seconds in a widget test and this brings with itself a bunch of problems like for example if we still have a future which is well running it's still waiting
      /// for something it's still in progress we could say and the test code finishes before this future has been fully awaited before it has finished then we get this kind of an error
      /// and why do we get it here well because we have a future which will exist for two seconds we are delaying execution of the arrange method by two seconds but we reach
      /// the end of this test code after just half a second right
      ///
      /// so it has one and a half spare seconds for this to run and this creates this issue we can solve this by calling await tester dot pump and settle this time pump and settle waits until
      /// there are no more rebuilds happening like animations and what is an animation in our case that is being shown in the ui well this circular progress indicator which is being displayed
      /// is actually animated right it's spinning so this counts as an animation and therefore if we await for tester.pump and settle which means we await for until there are no more
      /// animations displayed on the screen we are going to wait for exactly the time while the circular progress indicator is being shown on the screen right because it spins around
      ///
      /// so while it's spinning we're going to be waiting right here and the test will not end yet because we are waiting at the last line and then when the circular progress indicator disappears
      /// this future will be completed so the test will also end but by that point the two seconds for which we need to wait have already passed because the circular progress indicator will not disappear
      /// until right here these articles from service are actually returned from our mock this means that the delayed future has already passed
      /// so that's why we can just say pump and settle and this is going to solve our problem here so let's run this test again and it passed
    },
  );

  testWidgets(
    "articles are displayed ",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
