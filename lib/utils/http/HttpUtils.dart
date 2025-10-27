abstract class HttpUtils {

  Future<String> getData(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParams,
      });

  Future<dynamic> postData(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      });

  Future<dynamic> putData(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      });


}
