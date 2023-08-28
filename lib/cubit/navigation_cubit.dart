import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  /// Index page:
  /// 0 -> home screen
  /// 1 -> wallet page
  /// 2 -> history page
  /// 3 -> chat page

  void setTabIndex(int index) {
    emit(index);
  }
}
