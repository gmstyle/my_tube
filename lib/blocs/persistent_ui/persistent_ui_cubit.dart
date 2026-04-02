import 'package:flutter_bloc/flutter_bloc.dart';

class PersistentUiState {
  final double bottomSafeArea;
  final double navBarHeight;
  final double rawLeftPadding;
  final bool isPlayerVisible;
  final bool isSearchOpen;

  double get bottomPadding {
    if (isSearchOpen) return 0.0;
    return navBarHeight + bottomSafeArea;
  }

  double get leftPadding => isSearchOpen ? 0.0 : rawLeftPadding;

  const PersistentUiState({
    this.bottomSafeArea = 0,
    this.navBarHeight = 0,
    this.rawLeftPadding = 0,
    this.isPlayerVisible = true,
    this.isSearchOpen = false,
  });

  PersistentUiState copyWith({
    double? bottomSafeArea,
    double? navBarHeight,
    double? rawLeftPadding,
    bool? isPlayerVisible,
    bool? isSearchOpen,
  }) {
    return PersistentUiState(
      bottomSafeArea: bottomSafeArea ?? this.bottomSafeArea,
      navBarHeight: navBarHeight ?? this.navBarHeight,
      rawLeftPadding: rawLeftPadding ?? this.rawLeftPadding,
      isPlayerVisible: isPlayerVisible ?? this.isPlayerVisible,
      isSearchOpen: isSearchOpen ?? this.isSearchOpen,
    );
  }
}

class PersistentUiCubit extends Cubit<PersistentUiState> {
  PersistentUiCubit() : super(const PersistentUiState());

  void setBottomLayout(double navBarHeight, double bottomSafeArea) {
    emit(state.copyWith(
      navBarHeight: navBarHeight,
      bottomSafeArea: bottomSafeArea,
    ));
  }

  void setLeftPadding(double padding) {
    if (state.rawLeftPadding == padding) return;
    emit(state.copyWith(rawLeftPadding: padding));
  }

  void setPlayerVisibility(bool visible) {
    if (state.isPlayerVisible == visible) return;
    emit(state.copyWith(isPlayerVisible: visible));
  }

  void setSearchOpen(bool isOpen) {
    if (state.isSearchOpen == isOpen) return;
    emit(state.copyWith(isSearchOpen: isOpen));
  }
}
