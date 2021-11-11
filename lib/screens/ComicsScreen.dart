import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/config/ShadowCategories.dart';
import 'package:pikapika/basic/store/Categories.dart';
import 'package:pikapika/basic/config/ListLayout.dart';
import 'package:pikapika/basic/Method.dart';
import '../basic/Entities.dart';
import 'SearchScreen.dart';
import 'components/ComicPager.dart';

// 漫画列表
class ComicsScreen extends StatefulWidget {
  final String? category; // 指定分类
  final String? tag; // 指定标签
  final String? creatorId; // 指定上传者
  final String? creatorName; // 上传者名称 (仅显示)
  final String? chineseTeam;

  const ComicsScreen({
    Key? key,
    this.category,
    this.tag,
    this.creatorId,
    this.creatorName,
    this.chineseTeam,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends State<ComicsScreen> {
  late SearchBar _categorySearchBar = SearchBar(
    hintText: '搜索分类 - ${categoryTitle(widget.category)}',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchScreen(keyword: value, category: widget.category),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: new Text(categoryTitle(widget.category)),
        actions: [
          shadowCategoriesActionButton(context),
          chooseLayoutActionButton(context),
          _chooseCategoryAction(),
          _categorySearchBar.getSearchAction(context),
        ],
      );
    },
  );

  Widget _chooseCategoryAction() => IconButton(
        onPressed: () async {
          String? category = await chooseListDialog(context, '请选择分类', [
            categoryTitle(null),
            ...filteredList(
              storedCategories,
              (c) => !shadowCategories.contains(c),
            ),
          ]);
          if (category != null) {
            if (category == categoryTitle(null)) {
              category = null;
            }
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) {
                return ComicsScreen(
                  category: category,
                  tag: widget.tag,
                  creatorId: widget.creatorId,
                  creatorName: widget.creatorName,
                  chineseTeam: widget.chineseTeam,
                );
              },
            ));
          }
        },
        icon: Icon(Icons.category),
      );

  Future<ComicsPage> _load(String _currentSort, int _currentPage) {
    return method.comics(
      _currentSort,
      _currentPage,
      category: widget.category ?? "",
      tag: widget.tag ?? "",
      creatorId: widget.creatorId ?? "",
      chineseTeam: widget.chineseTeam ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if (widget.tag == null &&
        widget.creatorId == null &&
        widget.chineseTeam == null) {
      // 只有只传分类或不传参数时时才开放搜索
      appBar = _categorySearchBar.build(context);
    } else {
      var title = "";
      if (widget.category != null) {
        title += "${widget.category} ";
      }
      if (widget.tag != null) {
        title += "${widget.tag} ";
      }
      if (widget.creatorName != null) {
        title += "${widget.creatorName} ";
      }
      if (widget.chineseTeam != null) {
        title += "${widget.chineseTeam} ";
      }
      appBar = AppBar(
        title: Text(title),
        actions: [
          shadowCategoriesActionButton(context),
          chooseLayoutActionButton(context),
          _chooseCategoryAction(),
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      body: ComicPager(
        fetchPage: _load,
      ),
    );
  }
}
