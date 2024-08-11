import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:potato/core/state/category_video_state.dart';
import 'components/anime_category_page.dart';
import 'components/year_selector.dart';

/// 浏览资源页面，用于显示不同类别的动漫资源，并支持按年份筛选
class BrowseResourcesPage extends StatefulWidget {
  const BrowseResourcesPage({super.key});

  @override
  _BrowseResourcesPageState createState() => _BrowseResourcesPageState();
}

class _BrowseResourcesPageState extends State<BrowseResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // 用于管理 TabBar 和 TabBarView 的控制器

  // 动漫类别的 URL 列表，每个类别对应一个 URL
  final List<String> _categoryUrls = [
    '/show/ribendongman', // 日本动漫
    '/show/guochandongman', // 国产动漫
    '/show/omeidongman', // 欧美动漫
    '/show/dongmandianying', // 动漫电影
  ];

  @override
  void initState() {
    super.initState();
    // 初始化 TabController，长度与类别数量一致
    _tabController = TabController(length: _categoryUrls.length, vsync: this);

    // 在页面渲染完成后自动加载第一个标签的数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryData(0); // 初始加载第一个标签的数据
    });

    // 添加 Tab 切换监听器，当切换到新标签时加载对应数据
    _tabController.addListener(() {
      // 确保只在切换完成时加载数据
      if (!_tabController.indexIsChanging) {
        _loadCategoryData(_tabController.index, forceRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    // 释放 TabController 资源
    _tabController.dispose();
    super.dispose();
  }

  /// 根据索引加载对应类别的数据
  /// @param index 类别索引
  /// @param forceRefresh 是否强制刷新数据，默认不刷新
  void _loadCategoryData(int index, {bool forceRefresh = false}) {
    final categoryUrl = _categoryUrls[index]; // 获取对应类别的 URL
    Provider.of<CategoryVideoState>(context, listen: false)
        .fetchCategoryVideos(categoryUrl); // 加载数据
  }

  /// 当用户选择了年份时调用此方法，根据年份筛选数据
  /// @param year 用户选择的年份
  void _onYearSelected(int year) {
    Provider.of<CategoryVideoState>(context, listen: false)
        .setSelectedYear(year); // 设置选中的年份
    _loadCategoryData(_tabController.index, forceRefresh: true); // 刷新当前类别数据
  }

  /// 加载更多数据，用于分页加载
  /// @param index 当前类别的索引
  void _loadMore(int index) {
    print("_categoryUrls$_categoryUrls");
    final categoryUrl = _categoryUrls[index];
    print("categoryUrl$categoryUrl");
    Provider.of<CategoryVideoState>(context, listen: false)
        .loadMoreVideos(categoryUrl); // 加载更多视频数据
  }

  /// 加载上一页数据，用于分页加载
  /// @param index 当前类别的索引
  void _loadPrevious(int index) {
    final categoryUrl = _categoryUrls[index];
    Provider.of<CategoryVideoState>(context, listen: false)
        .loadPreviousVideos(categoryUrl); // 加载上一页视频数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200], // 设置浅灰色背景
        elevation: 0, // 去除阴影效果
        title:
            const Text('浏览资源', style: TextStyle(color: Colors.black)), // 标题文字
        bottom: TabBar(
          controller: _tabController, // 绑定 TabController
          indicatorColor: Colors.black, // 选中的标签指示器颜色
          labelColor: Colors.black, // 选中的标签文字颜色
          unselectedLabelColor: Colors.grey, // 未选中的标签文字颜色
          tabs: const [
            Tab(text: '日本动漫'), // 日本动漫标签
            Tab(text: '国产动漫'), // 国产动漫标签
            Tab(text: '欧美动漫'), // 欧美动漫标签
            Tab(text: '动漫电影'), // 动漫电影标签
          ],
        ),
      ),
      body: Column(
        children: [
          YearSelector(onYearSelected: _onYearSelected), // 年份选择器组件
          Expanded(
            child: Container(
              color: Colors.grey[200], // 设置浅灰色背景
              child: TabBarView(
                controller: _tabController, // 绑定 TabController
                children: List.generate(_categoryUrls.length, (index) {
                  return AnimeCategoryPage(
                    categoryIndex: index, // 当前类别索引
                    // onLoadMore: () => _loadMore(index), // 加载更多数据的回调
                    // onLoadPrevious: () => _loadPrevious(index), // 加载上一页数据的回调
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
