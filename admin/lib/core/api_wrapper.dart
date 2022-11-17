import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A general wrapper of http requesting.
class API {
  final FirebaseAuth auth = FirebaseAuth.instance;

  late Dio _http;
  BaseOptions httpOptions = BaseOptions(
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    connectTimeout: 180 * 1000, // 3 minutes
    receiveTimeout: 180 * 1000, // 3 minutes
    sendTimeout: 5000,
    followRedirects: false,
  );

  API() {
    _http = Dio(httpOptions);
  }

  Dio get http => _http;

  set httpBaseUrl(String url) => httpOptions.baseUrl = url;

  // Set authentification token to bearer for interceptor.
  set httpBearer(String? token) {
    if (token == null) {
      httpOptions.headers.remove('Authorization');
      return;
    }

    httpOptions.headers = {
      ...httpOptions.headers,
      'Authorization': 'Bearer $token',
    };
  }

  // Generates refresh token from authentication
  // service class. And sets it as default one.
  Future<void> reloadHttpBearer() async {
    final tokenState = await auth.currentUser?.getIdTokenResult();
    final isNotExpired = tokenState != null &&
        tokenState.expirationTime!.isAfter(DateTime.now());

    httpBearer = await auth.currentUser?.getIdToken(!isNotExpired);
  }
}

