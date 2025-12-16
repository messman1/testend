import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final userStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return {'postCount': 0, 'meetingCount': 0};

  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserStats(user.id);
});
