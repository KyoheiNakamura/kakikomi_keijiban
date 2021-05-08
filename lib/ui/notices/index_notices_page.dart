import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/ui/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/ui/notices/index_notices_model.dart';
import 'package:kakikomi_keijiban/ui/post/view_post_page.dart';
import 'package:provider/provider.dart';

/// お知らせ画面
class IndexNoticesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<IndexNoticesModel>(
      create: (context) => IndexNoticesModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Text('通知'),
        ),
        body: Consumer<IndexNoticesModel>(
          builder: (context, model, child) {
            final notices = model.notices;
            return LoadingSpinner(
              inAsyncCall: model.isModalLoading,
              child: RefreshIndicator(
                onRefresh: () => model.getMyNotices(),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: notices.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    return index != notices.length
                        ? GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailPage(notices[index]),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                top: 8,
                                right: 16,
                                bottom: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// emotion
                                  kEmotionIcons[notices[index].emotion] !=
                                              null ||
                                          kEmotionIcons[
                                                  notices[index].emotion] !=
                                              ''
                                      ? Image.asset(
                                          kEmotionIcons[
                                              notices[index].emotion]!,
                                          width: 50,
                                          height: 50,
                                        )
                                      : FlutterLogo(),
                                  SizedBox(width: 16),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),

                                        /// title
                                        Text(
                                          '${notices[index].title}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                        ),
                                        SizedBox(height: 8),

                                        /// body
                                        Text(
                                          '${notices[index].body}',
                                          style: TextStyle(color: kDarkGrey),
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          // softWrap: true,
                                        ),
                                        SizedBox(height: 4),

                                        /// createdAt
                                        Text(
                                          '${notices[index].createdAt}',
                                          style: TextStyle(
                                            color: kLightGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox();
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
