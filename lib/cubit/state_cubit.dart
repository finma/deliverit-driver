import 'package:flutter_bloc/flutter_bloc.dart';

class StateCubit<T> extends Cubit<T> {
  StateCubit(T initialValue) : super(initialValue);

  void setSelectedValue(T value) {
    emit(value);
  }
}
