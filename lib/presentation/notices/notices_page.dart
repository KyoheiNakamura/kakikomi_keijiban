import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/common_loading_spinner.dart';
import 'package:kakikomi_keijiban/common/components/common_scroll_bottom_notification_listener.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_model.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_page.dart';
import 'package:provider/provider.dart';

/// お知らせ画面
class NoticesPage extends StatelessWidget {
  const NoticesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NoticesModel>(
      create: (context) => NoticesModel()..init(),
      child: Scaffold(
        // appBar: commonAppBar(title: '通知'),
        body: SafeArea(
          child: Consumer<NoticesModel>(
            builder: (context, model, child) {
              final notices = model.notices;
              return notices.isNotEmpty
                  ? LoadingSpinner(
                      isModalLoading: model.isModalLoading,
                      child: RefreshIndicator(
                        onRefresh: () => model.getMyNotices(),
                        child: CommonScrollBottomNotificationListener(
                          model: model,
                          child: ListView.separated(
                            // physics: const BouncingScrollPhysics(),
                            itemCount: notices.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              return index != notices.length
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () async {
                                        final notice = notices[index];
                                        await Navigator.push<void>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostDetailPage(
                                              posterId: notice.posterId,
                                              postId: notice.postId,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// emotion
                                            kEmotionIcons[notices[index]
                                                            .emotion] !=
                                                        null ||
                                                    kEmotionIcons[notices[index]
                                                            .emotion] !=
                                                        ''
                                                ? Image.asset(
                                                    kEmotionIcons[notices[index]
                                                        .emotion]!,
                                                    width: 50,
                                                    height: 50,
                                                  )
                                                : const FlutterLogo(),
                                            const SizedBox(width: 16),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),

                                                  /// title
                                                  Text(
                                                    notices[index].title,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  const SizedBox(height: 8),

                                                  /// body
                                                  Text(
                                                    notices[index].body,
                                                    style: const TextStyle(
                                                      color: kDarkGrey,
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    // softWrap: true,
                                                  ),
                                                  const SizedBox(height: 4),

                                                  /// createdAt
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: Text(
                                                      notices[index].createdAt,
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                        color: kLightGrey,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              thickness: .5,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('お知らせはありません'),
                    );
            },
          ),
        ),
      ),
    );
  }
}
