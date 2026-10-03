import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/post_model.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final postController = TextEditingController();
  String? selectedChallengeId;
  String? selectedChallengeName;

  void _submitPost() async {
    final text = postController.text.trim();
    if (text.isEmpty) return;

    await ref.read(socialProvider.notifier).createPost(
          text,
          challengeId: selectedChallengeId,
          challengeName: selectedChallengeName,
        );
    postController.clear();
    setState(() {
      selectedChallengeId = null;
      selectedChallengeName = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.primary,
          content: Text('Post published to MongoDB, Redis Pub/Sub, and WebSocket clients!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(socialProvider);
    final challenges = ref.watch(socialProvider.notifier).challenges;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(socialProvider.notifier).loadFeed(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Real-time WebSocket connection status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COMMUNITY & CHALLENGES',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live /ws/feed',
                        style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Challenges Horizontal Scroll
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: challenges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, idx) => _buildChallengeCard(challenges[idx]),
                ),
              ),
              const SizedBox(height: 20),

              // Create Post Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: postController,
                            decoration: const InputDecoration(
                              hintText: 'Share a workout PR, photo, or challenge milestone...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedChallengeName != null) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Tag: $selectedChallengeName', style: const TextStyle(fontSize: 11, color: AppTheme.secondary)),
                        backgroundColor: AppTheme.secondary.withOpacity(0.15),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() {
                          selectedChallengeId = null;
                          selectedChallengeName = null;
                        }),
                      ),
                    ],
                    const Divider(color: AppTheme.surfaceBorder, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.fitness_center_rounded, color: AppTheme.secondary, size: 20),
                              tooltip: 'Tag a challenge',
                              onPressed: () => _pickChallengeToTag(challenges),
                            ),
                            IconButton(
                              icon: const Icon(Icons.image_outlined, color: AppTheme.textMuted, size: 20),
                              tooltip: 'Attach workout media (S3/MinIO)',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          onPressed: _submitPost,
                          child: const Text('Post Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Social Feed List
              const Text(
                'LIVE COMMUNITY STREAM (MONGODB)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              feedAsync.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const Center(child: Text('No community updates yet. Be the first to post!'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, idx) => _buildPostCard(posts[idx]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                error: (e, _) => Text('Error loading feed: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel ch) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ch.isJoined ? AppTheme.primary : AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(ch.category, style: const TextStyle(color: AppTheme.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Text('${ch.daysRemaining}d left', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ch.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${ch.participantsCount} joined', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ch.isJoined ? AppTheme.surfaceLight : AppTheme.primary,
                  foregroundColor: ch.isJoined ? AppTheme.primary : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: ch.isJoined
                    ? null
                    : () async {
                        await ref.read(socialProvider.notifier).joinChallenge(ch.id);
                        setState(() => ch.isJoined = true);
                      },
                child: Text(ch.isJoined ? 'Joined ✓' : 'Join', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(SocialPostModel post) {
    final dateFormat = DateFormat('h:mm a • MMM d');
    final isLiked = post.likedBy.contains('usr_demo_777');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    post.authorAvatar ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (post.challengeName != null)
                        Text(
                          'in ${post.challengeName}',
                          style: const TextStyle(color: AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                        )
                      else
                        Text(dateFormat.format(post.createdAt), style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(post.content, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
          const SizedBox(height: 10),

          // Optional Media Attachment
          if (post.mediaUrl != null)
            ClipRRect(
              child: Image.network(
                post.mediaUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

          // Actions Bar (Likes, Comments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                InkWell(
                  onTap: () => ref.read(socialProvider.notifier).toggleLike(post.id),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? AppTheme.error : AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text('${post.likesCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.textSecondary, size: 18),
                    const SizedBox(width: 6),
                    Text('${post.comments.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // Comments List
          if (post.comments.isNotEmpty) ...[
            const Divider(color: AppTheme.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post.comments
                    .take(2)
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                              children: [
                                TextSpan(text: '${c.authorName}: ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                                TextSpan(text: c.text, style: const TextStyle(color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _pickChallengeToTag(List<ChallengeModel> challenges) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Select Challenge to Tag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...challenges.map((c) => ListTile(
                title: Text(c.title),
                subtitle: Text(c.category),
                onTap: () {
                  setState(() {
                    selectedChallengeId = c.id;
                    selectedChallengeName = c.title;
                  });
                  Navigator.pop(ctx);
                },
              )),
        ],
      ),
    );
  }
}
