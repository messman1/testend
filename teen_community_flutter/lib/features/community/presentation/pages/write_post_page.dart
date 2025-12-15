import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/post_model.dart';
import '../../../auth/providers/auth_provider.dart';

/// 글쓰기 페이지
class WritePostPage extends ConsumerStatefulWidget {
  const WritePostPage({super.key});

  @override
  ConsumerState<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends ConsumerState<WritePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
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
        const SnackBar(content: Text('제목을 입력하세요')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력하세요')),
      );
      return;
    }

    // TODO: Supabase에 게시글 저장
    // await ref.read(postsRepositoryProvider).createPost(...)

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시글이 작성되었습니다')),
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        actions: [
          TextButton(
            onPressed: _submitPost,
            child: const Text('완료', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 타입 선택
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: '카테고리',
              ),
              items: PostType.values.map((type) {
                return DropdownMenuItem(
                  value: type.code,
                  child: Row(
                    children: [
                      Text(type.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // 제목
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '제목을 입력하세요',
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // 내용
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                hintText: '내용을 입력하세요',
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              maxLength: 1000,
            ),
            const SizedBox(height: 24),

            // 작성 안내
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '작성 시 유의사항',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 욕설, 비방, 음란물 등 부적절한 내용은 삼가주세요\n'
                    '• 개인정보(전화번호, 주소 등)는 공개하지 마세요\n'
                    '• 존중하는 마음으로 소통해요',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
