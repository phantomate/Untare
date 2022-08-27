import 'package:untare/models/unit.dart';

abstract class UnitState {}

class UnitsLoading extends UnitState {}

class UnitsInitial extends UnitState {}

class UnitsFetched extends UnitState {
  final List<Unit> units;
  UnitsFetched({required this.units});
}

class UnitsFetchedFromCache extends UnitState {
  final List<Unit> units;
  UnitsFetchedFromCache({required this.units});
}

class UnitCreated extends UnitState {
  final Unit unit;
  UnitCreated({required this.unit});
}

class UnitUpdated extends UnitState {
  final Unit unit;
  UnitUpdated({required this.unit});
}

class UnitDeleted extends UnitState {
  final Unit unit;
  UnitDeleted({required this.unit});
}

class UnitsError extends UnitState {
  final String error;

  UnitsError({required this.error});

  List<Object> get props => [error];
}

class UnitsUnauthorized extends UnitState {}