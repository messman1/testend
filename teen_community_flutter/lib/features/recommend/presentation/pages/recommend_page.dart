import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../../../config/routes/route_names.dart';
import '../../../location/providers/location_provider.dart';
import '../../../places/providers/places_provider.dart';
import '../../../places/domain/models/place_model.dart';

/// 추천 페이지
class RecommendPage extends ConsumerStatefulWidget {
  const RecommendPage({super.key});

  @override
  ConsumerState<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends ConsumerState<RecommendPage> {
  PlaceModel? _randomPlace;
  bool _isLoading = false;

  Future<void> _getRandomPlace() async {
    final locationState = ref.read(currentLocationProvider);
    if (!locationState.hasLocation) return;

    setState(() {
      _isLoading = true;
      _randomPlace = null;
    });

    try {
      // 모든 장소 가져오기
      final places = await ref.read(popularPlacesProvider(LocationParams(
        latitude: locationState.latitude!,
        longitude: locationState.longitude!,
        sizePerCategory: 5,
      )).future);

      if (places.isNotEmpty) {
        final random = Random();
        setState(() {
          _randomPlace = places[random.nextInt(places.length)];
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '오늘 뭐하지? 🤔',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '랜덤으로 장소를 추천해드릴게요!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 랜덤 추천 버튼
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getRandomPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎲', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 12),
                        Text('랜덤으로 뽑아줘!', style: TextStyle(fontSize: 18)),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // 랜덤 결과
          if (_randomPlace != null)
            Card(
              child: InkWell(
                onTap: () {
                  context.push(
                    '${RouteNames.placeDetail}?url=${Uri.encodeComponent(_randomPlace!.url)}&name=${Uri.encodeComponent(_randomPlace!.name)}',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 타이틀
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '✨ 오늘의 추천 장소',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 아이콘
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Center(
                          child: Text(
                            _randomPlace!.category.icon,
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 장소명
                      Text(
                        _randomPlace!.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // 카테고리
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _randomPlace!.category.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 위치 정보
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📍', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            _randomPlace!.location,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            ' | ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          const Text('🚶', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            _randomPlace!.distance,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 주소
                      Text(
                        _randomPlace!.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // 상세보기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push(
                              '${RouteNames.placeDetail}?url=${Uri.encodeComponent(_randomPlace!.url)}&name=${Uri.encodeComponent(_randomPlace!.name)}',
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('상세보기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // 카테고리별 빠른 추천
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 카테고리별 추천',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PlaceCategory.values.map((category) {
                      return OutlinedButton(
                        onPressed: () {
                          context.push(
                            '${RouteNames.explore}?category=${category.code}',
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Text(category.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
