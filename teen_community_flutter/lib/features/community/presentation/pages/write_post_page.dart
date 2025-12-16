import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/post_model.dart';
import '../../providers/community_provider.dart';

class WritePostPage extends ConsumerStatefulWidget {
  const WritePostPage({super.key});

  @override
  ConsumerState<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends ConsumerState<WritePostPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  PostType _selectedType = PostType.normal;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PostModel creation for submission
      // ID, counts, createdAt will be handled by DB or ignored by insert
      final newPost = PostModel(
        id: '', 
        title: title,
        content: content,
        authorNickname: '', // Backend handles this or we fetch profile
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        type: _selectedType,
      );

      await ref.read(communityControllerProvider.notifier).createPost(newPost);

      if (mounted) {
        context.pop(); // Go back to Community Page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 등록되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('글쓰기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isLoading ? Colors.grey : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PostType.values.map((type) {
                  // Don't allow creating 'new' types randomly if strictly managed, 
                  // but allowing all for now as requested.
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getTypeLabel(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = type);
                      },
                      selectedColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Title Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            const Divider(height: 32),

            // Content Input
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '나누고 싶은 이야기를 적어보세요.',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyLarge,
              maxLines: null,
              minLines: 10,
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(PostType type) {
    switch (type) {
      case PostType.normal:
        return '자유';
      case PostType.newOpen:
        return '신규 오픈';
      case PostType.review:
        return '후기';
      case PostType.event:
        return '이벤트';
    }
  }
}
