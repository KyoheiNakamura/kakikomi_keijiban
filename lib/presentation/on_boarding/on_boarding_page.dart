import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/common/constants.dart';
import 'package:kakikomi_keijiban/presentation/on_boarding/on_boarding_model.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: ChangeNotifierProvider<OnBoardingModel>(
        create: (context) => OnBoardingModel(),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: kLightPink,
            body: Consumer<OnBoardingModel>(
              builder: (context, model, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PageView.builder(
                          onPageChanged: model.onPageChangedCallBack,
                          itemBuilder: (context, index) => OnBoardingContent(
                            image: kOnBoardingData[index]['image']!,
                            text: kOnBoardingData[index]['text']!,
                          ),
                          itemCount: kOnBoardingData.length,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                kOnBoardingData.length,
                                (index) => DotIndicator(
                                  index: index,
                                  model: model,
                                ),
                              ),
                            ),
                            const Spacer(flex: 4),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await model.beDoneOnBoardingPage(context);
                                  },
                                  child: const Text(
                                    'はじめる',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: kDarkPink,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: const BorderSide(color: kDarkPink),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
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
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    required this.index,
    required this.model,
  });

  final int index;
  final OnBoardingModel model;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      width: model.currentPage == index ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: model.currentPage == index ? Colors.pinkAccent : kPink,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnBoardingContent extends StatelessWidget {
  const OnBoardingContent({
    required this.image,
    required this.text,
  });

  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Expanded(
          flex: 6,
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 320,
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
