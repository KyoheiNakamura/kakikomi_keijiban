import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/on_boarding/on_boarding_model.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ChangeNotifierProvider<OnBoardingModel>(
        create: (context) => OnBoardingModel(),
        child: Scaffold(
          backgroundColor: kLightPink,
          body: Consumer<OnBoardingModel>(
            builder: (context, model, child) {
              const types = OnBoardingPageType.values;
              return SafeArea(
                child: Column(
                  children: [
                    /// 画像と説明のページビュー
                    Expanded(
                      flex: 6,
                      child: PageView.builder(
                        onPageChanged: model.onPageChangedCallBack,
                        itemBuilder: (context, index) {
                          final image = onBoardingPageImage(types[index]);
                          final text = onBoardingPageText(types[index]);
                          return Column(
                            children: [
                              const Spacer(flex: 2),
                              Expanded(
                                flex: 12,
                                child: Image.asset(
                                  image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: types.length,
                      ),
                    ),

                    /// ページインジケーターとはじめるボタン
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            /// ページインジケーター
                            children: List.generate(
                              types.length,
                              (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  width: model.currentPage == index ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: model.currentPage == index
                                        ? Colors.pinkAccent
                                        : kPink,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Spacer(flex: 2),
                          OutlinedButton(
                            onPressed: () async {
                              await model.completeOnBoardingPage(context);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: kDarkPink,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              side: const BorderSide(color: kDarkPink),
                            ),
                            child: const Text(
                              'はじめる',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String onBoardingPageImage(OnBoardingPageType type) {
    switch (type) {
      case OnBoardingPageType.onBoardingPage1:
        return 'lib/assets/images/anpanman_charactors.jpeg';
      case OnBoardingPageType.onBoardingPage2:
        return 'lib/assets/images/anpanman_charactors.jpeg';
      case OnBoardingPageType.onBoardingPage3:
        return 'lib/assets/images/anpanman_charactors.jpeg';
    }
  }

  String onBoardingPageText(OnBoardingPageType type) {
    switch (type) {
      case OnBoardingPageType.onBoardingPage1:
        return '発達障害お悩み掲示板（仮）は発達障害をテーマに扱う掲示板アプリです。';
      case OnBoardingPageType.onBoardingPage2:
        return '当事者の方はもちろん、ご家族、友人の方などもお気軽にご利用ください。';
      case OnBoardingPageType.onBoardingPage3:
        return 'ああああああああああああああああああああああああああああああああ';
    }
  }
}

enum OnBoardingPageType {
  onBoardingPage1,
  onBoardingPage2,
  onBoardingPage3,
}
