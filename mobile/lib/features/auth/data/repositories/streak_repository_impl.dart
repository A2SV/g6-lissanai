import 'package:dartz/dartz.dart';
import 'package:lissan_ai/core/error/failure.dart';
import 'package:lissan_ai/core/network/network_info.dart';
import 'package:lissan_ai/features/auth/data/datasources/streak_remote_data_source.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_calendar.dart';
import 'package:lissan_ai/features/auth/domain/entities/streak_info.dart';
import 'package:lissan_ai/features/auth/domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  final NetworkInfo networkInfo;
  final StreakRemoteDataSource remoteDataSource;

  StreakRepositoryImpl({
    required this.networkInfo,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Unit>> freezeStreak() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.freezeStreak();
        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, StreakCalendar>> getActivityCalendar() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getActivityCalendar();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, StreakInfo>> getStreakInfo() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getStreakInfo();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordActivity() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.recordActivity();
        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
