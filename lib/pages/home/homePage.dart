import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/models/article/article.dart';
import '../../main.dart';
import '../../utils/navigationUtils.dart';
import 'homeCtrl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var navigation = getIt<NavigationUtils>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var ctrl = ref.read(homeCtrlProvider.notifier);
      ctrl.fetchArticles();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeCtrlProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    var state = ref.watch(homeCtrlProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            navigation.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Articles (${state.articles?.length ?? 0})'),
        actions: [
          IconButton(
            onPressed: () {
              var ctrl = ref.read(homeCtrlProvider.notifier);
              ctrl.fetchArticles();
            },
            icon: Icon(Icons.sync),
          ),
        ],
      ),
      body:
          state.isLoading == true
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: state.articles?.length ?? 0,
                itemBuilder: (context, index) {
                  var article = state.articles?[index];
                  return _buildArticle(article);
                },
              ),
    );
  }

  Widget _buildArticle(Article? article) {
    if (article == null) {
      return Container();
    }
    return ListTile(title: Text(article.title!), leading: Icon(Icons.article));
  }
}
