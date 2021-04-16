import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/post_card/post_card.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/domain/post.dart';
import 'package:kakikomi_keijiban/presentation/drafts/drafts_model.dart';
import 'package:provider/provider.dart';

class DraftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //   onWillPop: () {
    //     Navigator.of(context).popUntil(
    //       ModalRoute.withName('/'),
    //     );
    //     return Future.value(true);
    //   },
    return ChangeNotifierProvider<DraftsModel>(
      create: (context) => DraftsModel()..init(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            elevation: 0,
            centerTitle: true,
            title: Text(
              '下書き',
              style: kAppBarTextStyle,
            ),
          ),
          body: Consumer<DraftsModel>(builder: (context, model, child) {
            final List<Post> drafts = model.posts;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Theme.of(context).primaryColorDark),
              child: SafeArea(
                child: LoadingSpinner(
                  inAsyncCall: model.isModalLoading,
                  child: Container(
                    color: kLightPink,
                    child: RefreshIndicator(
                      onRefresh: () => model.getDrafts(),
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 30.0),
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
                ),
              ),
            );
          }),
        ),
      ),
    );
    // );
  }
}
