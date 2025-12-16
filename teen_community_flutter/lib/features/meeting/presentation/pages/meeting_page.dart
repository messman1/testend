import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meeting_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/meetings_provider.dart';
import '../../../places/providers/places_provider.dart';
import '../../../places/domain/models/place_model.dart';
import '../../../location/providers/location_provider.dart';
import '../../../recommend/presentation/pages/recommend_page.dart';

/// 모임 목록 페이지
class MeetingPage extends ConsumerStatefulWidget {
  final Object? extra;

  const MeetingPage({super.key, this.extra});

  @override
  ConsumerState<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends ConsumerState<MeetingPage> {
  bool _isCreating = false;
  String _selectedCategory = 'all';

  // 폼 컨트롤러
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'karaoke'; // 기본값 변경
  int _maxParticipants = 4;
  DateTime _meetingDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    // 추천 코스로부터 생성된 경우 처리
    if (widget.extra is RecommendationCourse) {
      final course = widget.extra as RecommendationCourse;
      _isCreating = true;
      _titleController.text = course.title;
      _descriptionController.text = '${course.description}\n\n[코스 상세]\n${course.places.asMap().entries.map((e) => '${e.key + 1}. ${e.value.name}').join('\n')}';
      
      if (course.places.isNotEmpty) {
        // 첫 번째 장소 기준
        final firstPlace = course.places.first;
        // 카테고리 매핑 (MeetingCategory와 PlaceCategory가 호환된다고 가정)
        // 만약 호환되지 않는다면 추가 로직 필요하지만, 앞서 통일했으므로 그대로 사용 시도
        // 다만 MeetingCategory에 없는 코드가 올 수 있으므로 안전하게 처리
         if (MeetingCategory.fromCode(firstPlace.category.code) != null) {
            _category = firstPlace.category.code;
         }
         
        _locationController.text = firstPlace.name;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _toggleCreateMode() {
    setState(() {
      _isCreating = !_isCreating;
      if (!_isCreating) {
        // 폼 초기화
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _category = 'karaoke';
        _maxParticipants = 4;
        _meetingDate = DateTime.now().add(const Duration(days: 1));
      }
    });
  }

  Future<void> _createMeeting() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 제목을 입력하세요')),
      );
      return;
    }

    final controller = ref.read(meetingsControllerProvider.notifier);
    await controller.createMeeting(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      location: _locationController.text.trim(),
      meetingDate: _meetingDate,
      maxParticipants: _maxParticipants,
      creatorNickname: user.nickname,
    );

    final state = ref.read(meetingsControllerProvider);
    if (!mounted) return;

    state.when(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임이 생성되었습니다')),
        );
        setState(() {
          _toggleCreateMode();
        });
      },
      loading: () {},
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${error.toString()}')),
        );
      },
    );
  }

  Future<void> _joinMeeting(MeetingModel meeting) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    if (!meeting.canJoin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('참가 인원이 가득 찼습니다')),
      );
      return;
    }

    if (meeting.participants.contains(user.id)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 참가한 모임입니다')),
      );
      return;
    }

    final controller = ref.read(meetingsControllerProvider.notifier);
    await controller.joinMeeting(meeting.id);

    final state = ref.read(meetingsControllerProvider);
    if (!mounted) return;

    state.when(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모임에 참가했습니다')),
        );
      },
      loading: () {},
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${error.toString()}')),
        );
      },
    );
  }
  
  // 장소 검색 다이얼로그
  void _showPlaceSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _PlaceSearchDialog(
        selectedCategory: _category,
        onPlaceSelected: (placeName) {
          _locationController.text = placeName;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 상단 바
        _buildTopBar(theme),

        // 카테고리 필터
        _buildCategoryFilter(theme),

        // 목록 또는 생성 폼
        Expanded(
          child: _isCreating
              ? _buildCreateForm(theme)
              : _buildMeetingList(theme),
        ),
      ],
    );
  }

  /// 상단 바
  Widget _buildTopBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isCreating ? '모임 만들기' : '모임',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: _toggleCreateMode,
            icon: Icon(_isCreating ? Icons.close : Icons.add),
            label: Text(_isCreating ? '취소' : '모임 만들기'),
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터
  Widget _buildCategoryFilter(ThemeData theme) {
    if (_isCreating) return const SizedBox.shrink();

    final categories = [
      {'id': 'all', 'icon': '🌟', 'name': '전체'},
      ...MeetingCategory.values.map((cat) => {
            'id': cat.code,
            'icon': cat.icon,
            'name': cat.label,
          }),
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category['icon'] as String,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(category['name'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id'] as String;
                });
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  /// 모임 목록
  Widget _buildMeetingList(ThemeData theme) {
    final meetingsAsync = ref.watch(meetingsProvider(_selectedCategory == 'all' ? null : _selectedCategory));

    return meetingsAsync.when(
      data: (meetings) {
        if (meetings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('👥', style: theme.textTheme.displayLarge),
                const SizedBox(height: 16),
                Text(
                  '아직 모임이 없습니다',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '첫 모임을 만들어보세요!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: meetings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildMeetingCard(theme, meetings[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⚠️', style: theme.textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              '모임 목록을 불러오는데 실패했습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 카드
  Widget _buildMeetingCard(ThemeData theme, MeetingModel meeting) {
    final category = MeetingCategory.fromCode(meeting.category);
    final isPast = meeting.meetingDate.isBefore(DateTime.now());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isPast
            ? null
            : () {
                _showMeetingDetail(meeting);
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  // 카테고리 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category?.icon ?? '💬',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 제목 및 작성자
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '주최: ${meeting.creatorNickname}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 참가 인원
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: meeting.canJoin
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meeting.participantInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: meeting.canJoin
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 설명
              if (meeting.description.isNotEmpty) ...[
                Text(
                  meeting.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // 정보
              Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    meeting.location.isEmpty ? '장소 미정' : meeting.location,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  const Text('📅', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.meetingDate.month}/${meeting.meetingDate.day} ${meeting.meetingDate.hour}:${meeting.meetingDate.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              if (isPast) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '⏰ 종료된 모임',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 생성 폼
  Widget _buildCreateForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '모임 제목',
              hintText: '예: 함께 보드게임 하실 분!',
            ),
          ),
          const SizedBox(height: 16),

          // 설명
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '모임 설명',
              hintText: '모임에 대해 자유롭게 설명해주세요',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // 카테고리
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: '카테고리',
            ),
            items: MeetingCategory.values.map((cat) {
              return DropdownMenuItem(
                value: cat.code,
                child: Row(
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(cat.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _category = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // 장소
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: '모임 장소',
                    hintText: '예: 강남역 근처 보드게임 카페',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _showPlaceSearchDialog,
                icon: const Icon(Icons.search),
                label: const Text('장소 검색'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 최대 인원
          Row(
            children: [
              Expanded(
                child: Text(
                  '최대 인원: $_maxParticipants명',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _maxParticipants > 2
                    ? () {
                        setState(() {
                          _maxParticipants--;
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _maxParticipants < 10
                    ? () {
                        setState(() {
                          _maxParticipants++;
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 모임 날짜
          ListTile(
            title: const Text('모임 날짜'),
            subtitle: Text(
              '${_meetingDate.year}/${_meetingDate.month}/${_meetingDate.day} ${_meetingDate.hour}:${_meetingDate.minute.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _meetingDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_meetingDate),
                );
                if (time != null) {
                  setState(() {
                    _meetingDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // 생성 버튼
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _createMeeting,
              child: const Text('모임 만들기', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  /// 모임 상세 다이얼로그
  void _showMeetingDetail(MeetingModel meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meeting.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meeting.description.isNotEmpty) ...[
              Text(meeting.description),
              const SizedBox(height: 16),
            ],
            Text('카테고리: ${MeetingCategory.fromCode(meeting.category)?.label ?? '기타'}'),
            Text('장소: ${meeting.location.isEmpty ? '미정' : meeting.location}'),
            Text(
              '날짜: ${meeting.meetingDate.year}/${meeting.meetingDate.month}/${meeting.meetingDate.day} ${meeting.meetingDate.hour}:${meeting.meetingDate.minute.toString().padLeft(2, '0')}',
            ),
            Text('참가 인원: ${meeting.participantInfo}'),
            Text('주최자: ${meeting.creatorNickname}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          if (meeting.canJoin)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _joinMeeting(meeting);
              },
              child: const Text('참가하기'),
            ),
        ],
      ),
    );
  }
}

/// 장소 검색 다이얼로그
class _PlaceSearchDialog extends ConsumerStatefulWidget {
  final String selectedCategory;
  final Function(String) onPlaceSelected;

  const _PlaceSearchDialog({
    required this.selectedCategory,
    required this.onPlaceSelected,
  });

  @override
  ConsumerState<_PlaceSearchDialog> createState() => _PlaceSearchDialogState();
}

class _PlaceSearchDialogState extends ConsumerState<_PlaceSearchDialog> {
  final _searchController = TextEditingController();
  List<PlaceModel> _places = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 초기 검색 (카테고리명으로)
    final category = MeetingCategory.fromCode(widget.selectedCategory);
    if (category != null) {
      _searchController.text = category.label;
      _searchPlaces();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locationState = ref.read(currentLocationProvider);
      final repository = ref.read(kakaoPlaceRepositoryProvider);

      if (locationState.latitude == null || locationState.longitude == null) {
        throw Exception('위치 정보를 가져올 수 없습니다.');
      }

      final places = await repository.searchPlaces(
        keyword: keyword,
        x: locationState.longitude!,
        y: locationState.latitude!,
        size: 15,
      );

      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: 500, // 고정 높이
        child: Column(
          children: [
            const Text(
              '장소 검색',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '장소 이름 검색',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchPlaces(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _searchPlaces,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _places.isEmpty
                          ? const Center(child: Text('검색 결과가 없습니다.'))
                          : ListView.separated(
                              itemCount: _places.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final place = _places[index];
                                return ListTile(
                                  title: Text(place.name),
                                  subtitle: Text('${place.distance} | ${place.address}'),
                                  onTap: () {
                                    widget.onPlaceSelected(place.name);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }
}
