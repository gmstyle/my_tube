part of 'test_youtube_explode_bloc.dart';

enum TestYoutubeExplodeStatus { initial, loading, success, failure }

class TestYoutubeExplodeState extends Equatable {
  final TestYoutubeExplodeStatus status;
  final List<ResourceMT> resources;
  final String? errorMessage;

  const TestYoutubeExplodeState._({
    this.status = TestYoutubeExplodeStatus.initial,
    this.resources = const <ResourceMT>[],
    this.errorMessage,
  });

  const TestYoutubeExplodeState.initial() : this._();

  const TestYoutubeExplodeState.loading()
      : this._(status: TestYoutubeExplodeStatus.loading);

  const TestYoutubeExplodeState.success(List<ResourceMT> resources)
      : this._(status: TestYoutubeExplodeStatus.success, resources: resources);

  const TestYoutubeExplodeState.failure(String errorMessage)
      : this._(
          status: TestYoutubeExplodeStatus.failure,
          errorMessage: errorMessage,
        );

  @override
  List<Object?> get props => [status, resources, errorMessage];
}
