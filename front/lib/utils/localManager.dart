abstract class LocalManager {
  Future<String?> readData(String path);
  Future<bool> writeData(String path, String data);
  Future<bool> deleteData(String path);
}
