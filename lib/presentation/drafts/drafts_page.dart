import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/common/components/common_app_bar.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:provider/provider.dart';

class DraftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DraftsModel>(
      create: (context) => DraftsModel()..init(),
      child: Scaffold(
        // backgroundColor: kLightPink,
        appBar: commonAppBar(title: '下書き'),
        body: Consumer<DraftsModel>(
          builder: (context, model, child) {
            final drafts = model.posts;
            return drafts.isNotEmpty
                ? LoadingSpinner(
                    isModalLoading: model.isModalLoading,
                    child: RefreshIndicator(
                      onRefresh: () => model.getDrafts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 30, bottom: 60),
                        itemBuilder: (BuildContext context, int index) {
                          final post = drafts[index];
                          return Column(
                            children: [
                              PostCard(
                                post: post,
                                indexOfPost: index,
                                passedModel: model,
                              ),
                              post == drafts.last && model.isLoading
                                  ? const CircularProgressIndicator()
                                  : const SizedBox(),
                            ],
                          );
                        },
                        itemCount: drafts.length,
                      ),
                    ),
                  )
                : const Center(
                    child: Text('下書きはありません'),
                  );
          },
        ),
      ),
    );
  }
}
