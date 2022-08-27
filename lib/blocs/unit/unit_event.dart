import 'package:untare/blocs/abstract_event.dart';
import 'package:untare/models/unit.dart';

abstract class UnitEvent extends AbstractEvent {}

class FetchUnits extends UnitEvent {
  final String query;
  final int page;
  final int pageSize;

  FetchUnits({required this.query, required this.page, required this.pageSize});
}

class CreateUnit extends UnitEvent {
  final Unit unit;

  CreateUnit({required this.unit});
}

class UpdateUnit extends UnitEvent {
  final Unit unit;

  UpdateUnit({required this.unit});
}

class DeleteUnit extends UnitEvent {
  final Unit unit;

  DeleteUnit({required this.unit});
}