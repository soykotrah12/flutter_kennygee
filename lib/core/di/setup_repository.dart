import 'package:get/get.dart';

import '../../feature/auth/data/repo/auth_repo_impl.dart';
import '../../feature/auth/domain/repo/auth_repo.dart';
import '../network/api_client.dart';

void setupRepository() {
  Get.lazyPut<AuthRepository>(
    () => AuthRepositoryImpl(apiClient: Get.find<ApiClient>()),
    fenix: true,
  );
}
