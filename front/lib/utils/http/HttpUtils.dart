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

  Future<dynamic> postMultipart(
      String url, {
        Map<String, String>? headers,
        Map<String, String>? fields,
        Map<String, String>? files, // key: field name, value: file path
      });

  Future<dynamic> putData(
      String url, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      });

  Future<dynamic> deleteData(
      String url, {
        Map<String, String>? headers,
      });

}
