// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/story_card.dart';
import '../story/add_edit_story_screen.dart';
import '../story/view_story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoryProvider>().fetchAllStories();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }
    setState(() => _isSearching = true);
    await context.read<StoryProvider>().searchStories(query.trim());
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _isSearching = false);
    context.read<StoryProvider>().fetchAllStories();
  }

  Future<void> _signout() async {
    await context.read<AuthProvider>().signout();
  }

  @override
  Widget build(BuildContext context) {
    final stories = context.watch<StoryProvider>().stories;
    final loading = context.watch<StoryProvider>().loading;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.flight_takeoff, color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Memory Miles',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // User avatar
          if (user != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(user.username,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textDark)),
                ],
              ),
            ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textMid),
            onPressed: _signout,
            tooltip: 'Sign Out',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                if (val.isEmpty) _clearSearch();
              },
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search stories...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMid),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMid),
                        onPressed: _clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: AppTheme.background,
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : stories.isEmpty
              ? _emptyState(context)
              : RefreshIndicator(
                  onRefresh: () => context.read<StoryProvider>().fetchAllStories(),
                  color: AppTheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return StoryCard(
                          story: story,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ViewStoryScreen(story: story)),
                          ),
                          onFavorite: () =>
                              context.read<StoryProvider>().toggleFavorite(story),
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddEditStoryScreen(story: story)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditStoryScreen()),
        ),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://images.pexels.com/photos/5706021/pexels-photo-5706021.jpeg?auto=compress&cs=tinysrgb&w=400',
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.flight, size: 80, color: AppTheme.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Stories Yet!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start creating your first travel story!\nTap the + button to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMid, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditStoryScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Story'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 46)),
          ),
        ],
      ),
    );
  }
}
