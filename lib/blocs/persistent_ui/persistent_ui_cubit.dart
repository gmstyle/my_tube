import 'package:flutter_bloc/flutter_bloc.dart';

class PersistentUiState {
  final double bottomPadding;
  final double leftPadding;
  final bool isPlayerVisible;

  const PersistentUiState({
    this.bottomPadding = 0,
    this.leftPadding = 0,
    this.isPlayerVisible = true,
  });

  PersistentUiState copyWith({
    double? bottomPadding,
    double? leftPadding,
    bool? isPlayerVisible,
  }) {
    return PersistentUiState(
      bottomPadding: bottomPadding ?? this.bottomPadding,
      leftPadding: leftPadding ?? this.leftPadding,
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

  void setLeftPadding(double padding) {
    if (state.leftPadding == padding) return;
    emit(state.copyWith(leftPadding: padding));
  }

  void setPaddings({double? bottom, double? left}) {
    emit(state.copyWith(
      bottomPadding: bottom ?? state.bottomPadding,
      leftPadding: left ?? state.leftPadding,
    ));
  }

  void setPlayerVisibility(bool visible) {
    if (state.isPlayerVisible == visible) return;
    emit(state.copyWith(isPlayerVisible: visible));
  }
}
