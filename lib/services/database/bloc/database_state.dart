part of 'database_bloc.dart';

abstract class DatabaseState extends Equatable {
  const DatabaseState();

  @override
  List<Object> get props => [];
}

class DatabaseUninitialised extends DatabaseState {}

class DatabaseInitialised extends DatabaseState {}
