part of 'connectivity_bloc.dart';

@immutable
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
  
  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {
  final bool wasOffline;
  
  const ConnectivityOnline({required this.wasOffline});
  
  @override
  List<Object> get props => [wasOffline];
}

class ConnectivityOffline extends ConnectivityState {
  const ConnectivityOffline();
}
