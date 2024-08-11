import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:potato/core/state/home_page_state.dart';
import 'components/recommended_section.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await Provider.of<HomePageState>(context, listen: false)
        .fetchHomePageData(); // 不强制刷新数据
  }

  Future<void> _onRefresh() async {
    await Provider.of<HomePageState>(context, listen: false)
        .fetchHomePageData(forceRefresh: true); // 强制刷新数据
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      context.go('/search', extra: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 1.0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage:
                const NetworkImage('https://api.multiavatar.com/tom.png'),
          ),
        ),
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: _onSearchSubmitted,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<HomePageState>(
        builder: (context, homePageState, child) {
          if (homePageState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (homePageState.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecommendedSection(
                        recommendedVideos: homePageState.recommendedVideos),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
