import 'package:flutter/material.dart';
import 'package:kakikomi_keijiban/ui/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/ui/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/entity/post.dart';
import 'package:kakikomi_keijiban/ui/drafts/index_drafts_model.dart';
import 'package:provider/provider.dart';

class IndexDraftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).popUntil(
          ModalRoute.withName('/'),
        );
        return Future.value(true);
      },
      child: ChangeNotifierProvider<IndexDraftsModel>(
        create: (context) => IndexDraftsModel()..init(),
        child: Scaffold(
          backgroundColor: kLightPink,
          appBar: AppBar(
            
            title: Text('下書き'),
          ),
          body: Consumer<IndexDraftsModel>(builder: (context, model, child) {
            final List<Post> drafts = model.posts;
            return LoadingSpinner(
              inAsyncCall: model.isModalLoading,
              child: Container(
                color: kLightPink,
                child: RefreshIndicator(
                  onRefresh: () => model.getDrafts(),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 30, bottom: 60),
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
                              ? CircularProgressIndicator()
                              : SizedBox(),
                        ],
                      );
                    },
                    itemCount: drafts.length,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
