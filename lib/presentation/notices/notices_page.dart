import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/components/loading_spinner.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/notices/notices_model.dart';
import 'package:kakikomi_keijiban/presentation/post_detail/post_detail_page.dart';
import 'package:provider/provider.dart';

/// お知らせ画面
class NoticesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NoticesModel>(
      create: (context) => NoticesModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: const Text('通知'),
        ),
        body: Consumer<NoticesModel>(
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
                              await Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailPage(notices[index]),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                                          '${notices[index].title}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 8),

                                        /// body
                                        Text(
                                          '${notices[index].body}',
                                          style: const TextStyle(
                                            color: kDarkGrey,
                                          ),
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          // softWrap: true,
                                        ),
                                        const SizedBox(height: 4),

                                        /// createdAt
                                        Text(
                                          '${notices[index].createdAt}',
                                          style: const TextStyle(
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
                        : const SizedBox();
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
