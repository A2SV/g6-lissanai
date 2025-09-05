part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateConnectivityEvent extends ConnectivityEvent {
  final InternetStatus status;
  UpdateConnectivityEvent(this.status);

  @override
  List<Object?> get props => [status];
}
