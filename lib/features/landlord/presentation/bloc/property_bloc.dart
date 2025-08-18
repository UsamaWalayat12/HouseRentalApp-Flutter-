import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/property_model.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  PropertyBloc() : super(PropertyInitial()) {
    on<AddProperty>(_onAddProperty);
    on<UpdateProperty>(_onUpdateProperty);
    on<DeleteProperty>(_onDeleteProperty);
  }

  Future<void> _onAddProperty(AddProperty event, Emitter<PropertyState> emit) async {
    try {
      emit(PropertyLoading());
      // Add property logic here
      emit(PropertySuccess());
    } catch (e) {
      emit(PropertyError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProperty(UpdateProperty event, Emitter<PropertyState> emit) async {
    try {
      emit(PropertyLoading());
      // Update property logic here
      emit(PropertySuccess());
    } catch (e) {
      emit(PropertyError(message: e.toString()));
    }
  }

  Future<void> _onDeleteProperty(DeleteProperty event, Emitter<PropertyState> emit) async {
    try {
      emit(PropertyLoading());
      // Delete property logic here
      emit(PropertySuccess());
    } catch (e) {
      emit(PropertyError(message: e.toString()));
    }
  }
} 