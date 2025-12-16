import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../../../config/routes/route_names.dart';
import '../../../location/providers/location_provider.dart';
import '../../../places/data/kakao_place_repository.dart';
import '../../../places/providers/places_provider.dart';
import '../../../places/domain/models/place_model.dart';

/// 추천 코스 모델
class RecommendationCourse {
  final int id;
  final String title;
  final String icon;
  final List<PlaceModel> places;
  final String duration;
  final String description;

  RecommendationCourse({
    required this.id,
    required this.title,
    required this.icon,
    required this.places,
    required this.duration,
    required this.description,
  });
}

/// 추천 페이지 (위자드 형식)
class RecommendPage extends ConsumerStatefulWidget {
  const RecommendPage({super.key});

  @override
  ConsumerState<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends ConsumerState<RecommendPage> {
  int _step = 1;
  final Map<String, dynamic> _selections = {
    'mood': null,
    'people': null,
    'time': null,
  };
  bool _isLoading = false;
  List<RecommendationCourse> _recommendations = [];
  PlaceModel? _randomPlace;

  // 상수 데이터
  final Map<String, List<String>> _moodCategories = {
    'active': ['karaoke', 'escape'],
    'chill': ['cafe', 'movie'],
    'social': ['board', 'escape'],
    'adventure': ['escape', 'board'],
  };

  final Map<String, dynamic> _courseTemplates = {
    'short': {'title': '짧게 즐기기', 'duration': '1-2시간', 'placeCount': 1},
    'medium': {'title': '알차게 놀기', 'duration': '3-4시간', 'placeCount': 2},
    'long': {'title': '하루종일 코스', 'duration': '5시간+', 'placeCount': 3},
  };

  void _handleSelect(String category, String value) {
    setState(() {
      _selections[category] = value;
      if (_step < 3) {
        _step++;
      } else {
        _generateRecommendations({..._selections, category: value});
      }
    });
  }

  Future<void> _generateRecommendations(Map<String, dynamic> finalSelections) async {
    setState(() {
      _isLoading = true;
      _step = 4;
    });

    try {
      final locationState = ref.read(currentLocationProvider);
      if (!locationState.hasLocation) {
        throw Exception('위치 정보를 가져올 수 없습니다.');
      }

      final repository = ref.read(kakaoPlaceRepositoryProvider);
      final categories = _moodCategories[finalSelections['mood']] ?? ['karaoke', 'escape'];
      final template = _courseTemplates[finalSelections['time']] ?? _courseTemplates['medium'];
      final placeCount = template['placeCount'] as int;

      // 각 카테고리에서 장소 가져오기
      final List<PlaceModel> allPlaces = [];
      for (final categoryCode in categories) {
        final category = PlaceCategory.fromCode(categoryCode);
        if (category != null) {
          final places = await repository.searchByCategory(
            category: category,
            x: locationState.longitude!,
            y: locationState.latitude!,
            size: 5,
          );
          allPlaces.addAll(places);
        }
      }

      // 추천 코스 생성
      final List<RecommendationCourse> courses = [];

      // 코스 1: 메인 활동 중심
      if (allPlaces.isNotEmpty) {
        final mainCategoryCode = categories[0];
        final mainPlaces = allPlaces
            .where((p) => p.category.code == mainCategoryCode)
            .take(placeCount)
            .toList();
        
        // 만약 메인 카테고리 장소가 부족하면 다른 장소로 채움
        if (mainPlaces.length < placeCount) {
             final remaining = allPlaces.where((p) => !mainPlaces.contains(p)).take(placeCount - mainPlaces.length);
             mainPlaces.addAll(remaining);
        }

        if (mainPlaces.isNotEmpty) {
           courses.add(RecommendationCourse(
            id: 1,
            title: '${template['title']} - ${_getCategoryName(mainCategoryCode)} 코스',
            icon: _getCategoryIcon(mainCategoryCode),
            places: mainPlaces,
            duration: template['duration'],
            description: _getCourseDescription(finalSelections['mood'], mainCategoryCode),
          ));
        }
      }

      // 코스 2: 믹스 코스 (다양한 카테고리 섞기)
      if (allPlaces.length > 1) {
          final mixPlaces = <PlaceModel>[];
          // 간단하게 셔플해서 선택
          final shuffled = List<PlaceModel>.from(allPlaces)..shuffle();
          mixPlaces.addAll(shuffled.take(placeCount));

          courses.add(RecommendationCourse(
            id: 2,
            title: '${template['title']} - 믹스 코스',
            icon: '✨',
            places: mixPlaces,
            duration: template['duration'],
            description: '다양한 활동을 즐길 수 있는 코스',
          ));
      }
      
      // 코스 3: 서브 활동 중심
      if (categories.length > 1 && allPlaces.length > 2) {
          final subCategoryCode = categories[1];
          final subPlaces = allPlaces
            .where((p) => p.category.code == subCategoryCode)
            .take(placeCount)
            .toList();
            
           if (subPlaces.isNotEmpty) {
             courses.add(RecommendationCourse(
              id: 3,
              title: '${template['title']} - ${_getCategoryName(subCategoryCode)} 코스',
              icon: _getCategoryIcon(subCategoryCode),
              places: subPlaces,
              duration: template['duration'],
              description: _getCourseDescription(finalSelections['mood'], subCategoryCode),
            ));
           }
      }

      setState(() {
        _recommendations = courses;
        _isLoading = false;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('추천 생성 중 오류가 발생했습니다: $e')),
        );
         setState(() {
          _isLoading = false;
          _resetQuiz(); // 오류 시 리셋
        });
      }
    }
  }

  String _getCategoryName(String code) {
    return PlaceCategory.fromCode(code)?.label ?? code;
  }
  
  String _getCategoryIcon(String code) {
      return PlaceCategory.fromCode(code)?.icon ?? '❓';
  }

  String _getCourseDescription(String mood, String category) {
    const descriptions = {
      'active': {
        'karaoke': '신나는 노래로 스트레스 해소!',
        'escape': '두뇌 풀가동! 탈출에 도전해봐',
      },
      'chill': {
        'cafe': '조용한 공간에서 힐링 타임',
        'movie': '편하게 영화 한 편 어때?',
      },
      'social': {
        'board': '친구들과 함께 보드게임 대결!',
        'escape': '협동해서 방탈출 성공하기',
      },
      'adventure': {
        'escape': '새로운 테마에 도전해봐!',
        'board': '처음 해보는 보드게임 어때?',
      },
    };
    
    // mood가 맵에 있는지 확인하고, 그 다음 category가 있는지 확인
    if (descriptions.containsKey(mood)) {
        final moodMap = descriptions[mood] as Map<String, String>;
        if (moodMap.containsKey(category)) {
            return moodMap[category]!;
        }
    }
    return '재미있는 시간 보내세요!';
  }

  void _resetQuiz() {
    setState(() {
      _step = 1;
      _selections.clear();
      _recommendations = [];
      _randomPlace = null;
    });
  }
  
  Future<void> _handleRandomRecommend() async {
     setState(() {
      _isLoading = true;
      _randomPlace = null;
    });

    try {
      final locationState = ref.read(currentLocationProvider);
      final repository = ref.read(kakaoPlaceRepositoryProvider);
      
      final categories = PlaceCategory.values;
      final randomCategory = categories[Random().nextInt(categories.length)];
      
       final places = await repository.searchByCategory(
            category: randomCategory,
            x: locationState.longitude!,
            y: locationState.latitude!,
            size: 10,
          );
      
      if (places.isNotEmpty) {
          setState(() {
              _randomPlace = places[Random().nextInt(places.length)];
          });
      }
    } catch(e) {
         // 에러 처리 무시 또는 로그
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                  '몇 가지만 선택하면 딱 맞는 곳을 추천해줄게!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          if (_step <= 3) ...[
            // 진행 바
            LinearProgressIndicator(
              value: _step / 3,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),

            // 질문 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_step == 1) ...[
                      Text('🎯 오늘 기분이 어때?', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 24),
                      _buildOptionBtn('🎤 신나게 놀고 싶어!', () => _handleSelect('mood', 'active')),
                      _buildOptionBtn('😌 조용히 쉬고 싶어', () => _handleSelect('mood', 'chill')),
                      _buildOptionBtn('👥 친구들이랑 어울리고 싶어', () => _handleSelect('mood', 'social')),
                      _buildOptionBtn('🌟 새로운 거 해보고 싶어!', () => _handleSelect('mood', 'adventure')),
                    ] else if (_step == 2) ...[
                      Text('👥 몇 명이서 놀아?', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 24),
                      _buildOptionBtn('👫 2명', () => _handleSelect('people', '2')),
                      _buildOptionBtn('👨‍👩‍👧 3-4명', () => _handleSelect('people', '3-4')),
                      _buildOptionBtn('👨‍👩‍👧‍👦 5명 이상', () => _handleSelect('people', '5+')),
                    ] else if (_step == 3) ...[
                      Text('⏰ 시간은 얼마나 있어?', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 24),
                      _buildOptionBtn('⚡ 1-2시간', () => _handleSelect('time', 'short')),
                      _buildOptionBtn('🕐 반나절 (3-4시간)', () => _handleSelect('time', 'medium')),
                      _buildOptionBtn('🌅 하루종일!', () => _handleSelect('time', 'long')),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            // 결과 화면
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text('✨ 추천 코스', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                        onPressed: _resetQuiz,
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 선택'),
                    )
                ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else ...[ 
                if (_recommendations.isEmpty)
                     const Center(child: Text('추천 가능한 장소를 찾지 못했습니다.')),
                     
                ..._recommendations.map((course) => _buildCourseCard(course)),
                
                const SizedBox(height: 32),
                
                 Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            children: [
                                Text('🎲 아직도 못 정하겠어?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: FilledButton.tonal(
                                        onPressed: _handleRandomRecommend,
                                        child: const Text('랜덤으로 뽑아줘!'),
                                    ),
                                ),
                                if (_randomPlace != null) ...[
                                    const SizedBox(height: 16),
                                     ListTile(
                                        leading: Text(_randomPlace!.category.icon, style: const TextStyle(fontSize: 30)),
                                        title: Text(_randomPlace!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text('${_randomPlace!.location} · ${_randomPlace!.distance}'),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                        onTap: () {
                                             context.push(
                                                '${RouteNames.placeDetail}?url=${Uri.encodeComponent(_randomPlace!.url)}&name=${Uri.encodeComponent(_randomPlace!.name)}',
                                            );
                                        },
                                        tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                ]
                            ]
                        )
                    )
                 )
            ]
          ],
        ],
      ),
    );
  }

  Widget _buildOptionBtn(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
  
  Widget _buildCourseCard(RecommendationCourse course) {
      final theme = Theme.of(context);
      
      return Card(
          margin: const EdgeInsets.only(bottom: 24),
          clipBehavior: Clip.antiAlias,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // 헤더
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      ),
                      child: Row(
                          children: [
                              Text(course.icon, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          Text(course.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          Text(course.description, style: theme.textTheme.bodySmall),
                                      ],
                                  ),
                              ),
                          ],
                      ),
                  ),
                  
                  // 장소 리스트
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          children: course.places.asMap().entries.map((entry) {
                              final index = entry.key;
                              final place = entry.value;
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                       onTap: () {
                                          context.push(
                                            '${RouteNames.placeDetail}?url=${Uri.encodeComponent(place.url)}&name=${Uri.encodeComponent(place.name)}',
                                          );
                                        },
                                      child: Row(
                                          children: [
                                              Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                      color: theme.colorScheme.primary,
                                                      shape: BoxShape.circle,
                                                  ),
                                                  child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                          Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                          Text('${place.location} · ${place.distance}', style: theme.textTheme.bodySmall),
                                                      ],
                                                  ),
                                              ),
                                               if (place.thumbnail != null && place.thumbnail!.isNotEmpty)
                                                 ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Image.network(place.thumbnail!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
                                                 ),
                                          ],
                                      ),
                                  ),
                              );
                          }).toList(),
                      ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // 액션
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text('⏱️ 소요시간: ${course.duration}', style: theme.textTheme.bodyMedium),
                              FilledButton(
                                  onPressed: () {
                                      // 모임 만들기 페이지로 이동 (코스 데이터 전달)
                                      // go_router의 extra를 통해 객체 전달
                                      context.go(RouteNames.meetingCreate, extra: course);
                                  },
                                  child: const Text('모임 만들기'),
                              ),
                          ],
                      ),
                  ),
              ],
          ),
      );
  }
}
