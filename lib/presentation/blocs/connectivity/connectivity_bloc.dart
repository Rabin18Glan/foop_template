import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/network/network_info.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity connectivity;
  final NetworkInfo networkInfo;
  StreamSubscription? connectivitySubscription;
  
  ConnectivityBloc({
    required this.connectivity,
    required this.networkInfo,
  }) : super(ConnectivityInitial()) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityChanged>(_onChanged);
  }
  
  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (result) => add(ConnectivityChanged(result)),
    );
    
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      emit(const ConnectivityOnline(wasOffline: false));
    } else {
      emit(const ConnectivityOffline());
    }
  }
  
  Future<void> _onChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    if (event.result == ConnectivityResult.none) {
      emit(const ConnectivityOffline());
    } else {
      final wasOffline = state is ConnectivityOffline;
      emit(ConnectivityOnline(wasOffline: wasOffline));
    }
  }
  
  @override
  Future<void> close() {
    connectivitySubscription?.cancel();
    return super.close();
  }
}
