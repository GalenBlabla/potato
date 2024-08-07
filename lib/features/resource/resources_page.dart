import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:potato/core/state/category_video_state.dart';
import 'components/anime_category_page.dart';
import 'components/year_selector.dart';

class BrowseResourcesPage extends StatefulWidget {
  const BrowseResourcesPage({super.key});

  @override
  _BrowseResourcesPageState createState() => _BrowseResourcesPageState();
}

class _BrowseResourcesPageState extends State<BrowseResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categoryUrls = [
    '/show/ribendongman',
    '/show/guochandongman',
    '/show/omeidongman',
    '/show/dongmandianying',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryUrls.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始加载第一个标签的数据
      _loadCategoryData(0);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadCategoryData(_tabController.index, forceRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCategoryData(int index, {bool forceRefresh = false}) {
    final categoryUrl = _categoryUrls[index];
    Provider.of<CategoryVideoState>(context, listen: false)
        .fetchCategoryVideos(categoryUrl, forceRefresh: forceRefresh);
  }

  void _onYearSelected(int year) {
    Provider.of<CategoryVideoState>(context, listen: false)
        .setSelectedYear(year);
    _loadCategoryData(_tabController.index, forceRefresh: true);
  }

  void _loadMore(int index) {
    final categoryUrl = _categoryUrls[index];
    Provider.of<CategoryVideoState>(context, listen: false)
        .loadMoreVideos(categoryUrl);
  }

  void _loadPrevious(int index) {
    final categoryUrl = _categoryUrls[index];
    Provider.of<CategoryVideoState>(context, listen: false)
        .loadPreviousVideos(categoryUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200], // 浅灰色背景
        elevation: 0,
        title: const Text('浏览资源', style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '日本动漫'),
            Tab(text: '国产动漫'),
            Tab(text: '欧美动漫'),
            Tab(text: '动漫电影'),
          ],
        ),
      ),
      body: Column(
        children: [
          YearSelector(onYearSelected: _onYearSelected),
          Expanded(
            child: Container(
              color: Colors.grey[200], // 浅灰色背景
              child: TabBarView(
                controller: _tabController,
                children: List.generate(_categoryUrls.length, (index) {
                  return AnimeCategoryPage(
                    categoryIndex: index,
                    onLoadMore: () => _loadMore(index),
                    onLoadPrevious: () => _loadPrevious(index),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
