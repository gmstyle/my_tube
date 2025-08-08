import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_tube/models/resource_mt.dart';
import 'package:my_tube/respositories/youtube_explode_repository.dart';

part 'test_youtube_explode_event.dart';
part 'test_youtube_explode_state.dart';

/// Bloc di test per verificare il funzionamento di YoutubeExplodeRepository
/// Questo è un esempio di come migrare i bloc esistenti
class TestYoutubeExplodeBloc
    extends Bloc<TestYoutubeExplodeEvent, TestYoutubeExplodeState> {
  final YoutubeExplodeRepository youtubeExplodeRepository;

  TestYoutubeExplodeBloc({required this.youtubeExplodeRepository})
      : super(const TestYoutubeExplodeState.initial()) {
    on<TestGetVideo>((event, emit) async {
      await _onTestGetVideo(event, emit);
    });

    on<TestSearchVideos>((event, emit) async {
      await _onTestSearchVideos(event, emit);
    });

    on<TestGetTrending>((event, emit) async {
      await _onTestGetTrending(event, emit);
    });
  }

  Future<void> _onTestGetVideo(
      TestGetVideo event, Emitter<TestYoutubeExplodeState> emit) async {
    emit(const TestYoutubeExplodeState.loading());
    try {
      final video = await youtubeExplodeRepository.getVideo(event.videoId);
      emit(TestYoutubeExplodeState.success([video]));
    } catch (e) {
      emit(TestYoutubeExplodeState.failure(e.toString()));
    }
  }

  Future<void> _onTestSearchVideos(
      TestSearchVideos event, Emitter<TestYoutubeExplodeState> emit) async {
    emit(const TestYoutubeExplodeState.loading());
    try {
      final response =
          await youtubeExplodeRepository.searchContents(query: event.query);
      emit(TestYoutubeExplodeState.success(response.resources));
    } catch (e) {
      emit(TestYoutubeExplodeState.failure(e.toString()));
    }
  }

  Future<void> _onTestGetTrending(
      TestGetTrending event, Emitter<TestYoutubeExplodeState> emit) async {
    emit(const TestYoutubeExplodeState.loading());
    try {
      final response = await youtubeExplodeRepository.getTrending('now');
      emit(TestYoutubeExplodeState.success(response.resources));
    } catch (e) {
      emit(TestYoutubeExplodeState.failure(e.toString()));
    }
  }
}
