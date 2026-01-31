import 'package:flutter_bloc/flutter_bloc.dart';

class PersistentUiState {
  final double bottomPadding;

  const PersistentUiState({
    this.bottomPadding = 0,
  });

  PersistentUiState copyWith({
    double? bottomPadding,
  }) {
    return PersistentUiState(
      bottomPadding: bottomPadding ?? this.bottomPadding,
    );
  }
}

class PersistentUiCubit extends Cubit<PersistentUiState> {
  PersistentUiCubit() : super(const PersistentUiState());

  void setBottomPadding(double padding) {
    if (state.bottomPadding == padding) return;
    emit(state.copyWith(bottomPadding: padding));
  }
}
