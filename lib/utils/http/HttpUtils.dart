abstract class HttpUtils {

   Future<String> getData(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? token,
  });

  Future<dynamic> postData(
    String url, {
    Map<String, String>? headers,
    String? token,
    Map<String, dynamic>? body,
  });

  Future<dynamic> putData(
    String url, {
    Map<String, String>? headers,
    String? token,
    Map<String, dynamic>? body,
  });
  
  
}
