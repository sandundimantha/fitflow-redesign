import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitflow_app/main.dart';

// 1x1 transparent pixel png for headless test network images
final List<int> _kTransparentImage = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void close({bool force = false}) {}
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _TestHttpClientRequest();
  @override
  Future<HttpClientRequest> postUrl(Uri url) async => _TestHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  int contentLength = 0;

  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _TestHttpClientResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  final HttpHeaders headers = _TestHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('FitFlow app launches and displays Dashboard with Today Scheduled Workout above the fold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FitFlowApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Brand
    expect(find.text('FitFlow'), findsOneWidget);

    // Verify Today's Scheduled Workout heading
    expect(find.text("TODAY'S SCHEDULED WORKOUT"), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Workout History'), findsOneWidget);
    expect(find.text('Progress Chart'), findsOneWidget);
    expect(find.text('Nutrition Tracker'), findsOneWidget);
    expect(find.text('Community Feed'), findsOneWidget);

    // Verify Bottom Navigation items
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('AI Plan'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });

  testWidgets('Switching tabs navigates directly in 1 tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FitFlowApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on AI Plan tab
    await tester.tap(find.text('AI Plan'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AI Workout Architect screen appears
    expect(find.text('AI Workout Architect'), findsOneWidget);
    expect(find.text('Generate AI Workout Protocol'), findsOneWidget);
  });
}
