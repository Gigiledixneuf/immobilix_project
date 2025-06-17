

import 'package:get_storage/get_storage.dart';

import '../../../utils/localManager.dart';


class GetStorageImpl implements LocalManager {
  GetStorage box = GetStorage();

  @override
  Future<String?> readData(String path) async{
   return await box.read(path);
  }

  @override
  Future<bool> writeData(String path, String data) async{
    await box.write(path, data);
    return true;
  }

  @override
  Future<bool> deleteData(String path) async {
    await box.remove(path);
    return true;
  }
}
