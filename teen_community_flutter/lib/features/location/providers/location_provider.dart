import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/location_repository.dart';

/// LocationRepository Provider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

/// 위치 상태 클래스
class LocationState {
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.address,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
}

/// 위치 상태 관리 Controller
class LocationController extends StateNotifier<LocationState> {
  final LocationRepository _repository;

  LocationController(this._repository) : super(const LocationState()) {
    // 초기화 시 자동으로 위치 가져오기
    _initializeLocation();
  }

  /// 초기 위치 가져오기
  Future<void> _initializeLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final locationData = await _repository.getCurrentLocationWithAddress();

      state = LocationState(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      // 위치 가져오기 실패 시 기본 위치 사용
      final defaultLocation = _repository.getDefaultLocation();

      state = LocationState(
        latitude: defaultLocation.latitude,
        longitude: defaultLocation.longitude,
        address: defaultLocation.address,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 위치 새로고침
  Future<void> refreshLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final locationData = await _repository.getCurrentLocationWithAddress();

      state = LocationState(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 특정 좌표로 위치 설정 (테스트용)
  void setLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    state = LocationState(
      latitude: latitude,
      longitude: longitude,
      address: address ?? state.address,
      isLoading: false,
      error: null,
    );
  }
}

/// LocationController Provider
final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return LocationController(repository);
});

/// 현재 위치 Provider (간편하게 사용)
final currentLocationProvider = Provider<LocationState>((ref) {
  return ref.watch(locationControllerProvider);
});
