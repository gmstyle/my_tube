import 'package:flutter_bloc/flutter_bloc.dart';

class PersistentUiState {
  final double bottomPadding;
  final bool isPlayerVisible;

  const PersistentUiState({
    this.bottomPadding = 0,
    this.isPlayerVisible = true,
  });

  PersistentUiState copyWith({
    double? bottomPadding,
    bool? isPlayerVisible,
  }) {
    return PersistentUiState(
      bottomPadding: bottomPadding ?? this.bottomPadding,
      isPlayerVisible: isPlayerVisible ?? this.isPlayerVisible,
    );
  }
}

class PersistentUiCubit extends Cubit<PersistentUiState> {
  PersistentUiCubit() : super(const PersistentUiState());

  void setBottomPadding(double padding) {
    if (state.bottomPadding == padding) return;
    emit(state.copyWith(bottomPadding: padding));
  }

  void setPlayerVisibility(bool visible) {
    if (state.isPlayerVisible == visible) return;
    emit(state.copyWith(isPlayerVisible: visible));
  }
}
