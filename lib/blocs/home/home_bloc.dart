import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:my_tube/respositories/youtube_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final YoutubeRepository youtubeRepository;
  HomeBloc({required this.youtubeRepository})
      : super(const HomeState.initial()) {
    on<GetVideos>((event, emit) async {
      await _onGetVideos(event, emit);
    });
  }

  Future<void> _onGetVideos(GetVideos event, Emitter<HomeState> emit) async {
    emit(const HomeState.loading());
    try {
      final response = await youtubeRepository.getVideos();
      emit(HomeState.loaded(response.items!));
    } catch (error) {
      emit(HomeState.error(error.toString()));
    }
  }
}
