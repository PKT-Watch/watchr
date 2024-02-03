part of 'database_bloc.dart';

abstract class DatabaseEvent extends Equatable {
  const DatabaseEvent();

  @override
  List<Object> get props => [];
}

class DatabaseInitialize extends DatabaseEvent {
  const DatabaseInitialize();

  @override
  List<Object> get props => [];
}
