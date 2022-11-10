import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/article.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_change_notifier.dart';
import 'package:flutter_tdd_widget_integration_test_mocktail/news_service.dart';
import 'package:mocktail/mocktail.dart';

/// This approach is bad because it is tightly coupled to the implementation
/// This is hard to maintain and refactor for testing purposes
// class BadMockNewsService implements NewsService {
//   bool getArticleCalled = false;

//   @override
//   Future<List<Article>> getArticles() async {
//     getArticleCalled = true;
//     return [
//       Article(title: 'Test 1', content: 'Test 1 Content'),
//       Article(title: 'Test 2', content: 'Test 2 Content'),
//       Article(title: 'Test 3', content: 'Test 3 Content'),
//     ];
//   }
// }

/// So we use mock technique to decouple the implementation
/// Create mock class for NewsService with mocktail
/// Mocktail is a mocking library for Dart and Flutter
/// Mocking is a technique for replacing a dependency with a fake implementation
/// With mocktail we don't have any actual implementation return in the class itself
/// We're going to setup implementation in the individual test
class MockNewsService extends Mock implements NewsService {}

void main() {
  /// defining sut (system under test)
  /// System under test refers to a system that is being tested for correct operation.
  /// init class NewsChangeNotifier with name sut because we are testing exactly this class
  late NewsChangeNotifier sut;
  // create object mockNewsService
  late MockNewsService mockNewsService;

  /// arrange
  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test('initial values are correct', () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group('getArticles', () {
    final articlesFromService = [
      Article(title: 'Test 1', content: 'Test 1 Content'),
      Article(title: 'Test 2', content: 'Test 2 Content'),
      Article(title: 'Test 3', content: 'Test 3 Content'),
    ];

    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => articlesFromService);
    }

    test(
      "gets articles using the NewsService",
      () async {
        // arrange
        // provide an implementation getArticles in the mockNewsService with this exact functionality
        arrangeNewsServiceReturns3Articles();
        // act
        await sut.getArticles();
        // assert
        // verify that getArticles method is called 1 time
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      """
        indicates loading of data, sets articles to the one from the services,
        indicates that data is not being load anymore
      """,
      () async {
        /// arrange
        arrangeNewsServiceReturns3Articles();

        /// act
        final future = sut.getArticles();

        /// assert
        expect(sut.isLoading, true);
        //act
        await future;
        // assert
        expect(
          sut.articles,
          articlesFromService,
        );
        expect(sut.isLoading, false);
      },
    );
  });
}
