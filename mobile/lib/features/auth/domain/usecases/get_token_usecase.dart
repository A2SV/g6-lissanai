import 'package:lissan_ai/features/auth/domain/repositories/auth_repository.dart';

class GetTokenUsecase {
  final AuthRepository repository;
  GetTokenUsecase({required this.repository});

  Future<bool> call() async {
    return repository.isTokenValid();
  }
}
