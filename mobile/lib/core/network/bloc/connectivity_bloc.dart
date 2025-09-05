import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {

  late final StreamSubscription _subscription;
  InternetConnection connection;

  ConnectivityBloc({required this.connection}) : super(ConnectivityInitial()) {

    _subscription = connection.onStatusChange.listen((status) {
      add(UpdateConnectivityEvent(status));
    });

    on<UpdateConnectivityEvent>((event, emit) {
      if (event.status == InternetStatus.connected) {
        emit(ConnectivityConnected());
      } else {
        emit(ConnectivityDisconnected());
      }
    });

  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  
}
