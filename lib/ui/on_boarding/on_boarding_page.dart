import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kakikomi_keijiban/config/constants.dart';
import 'package:kakikomi_keijiban/ui/on_boarding/on_boarding_model.dart';
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
            body: Consumer<OnBoardingModel>(builder: (context, model, child) {
              return Container(
                color: kLightPink,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0),
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
                          Spacer(),
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
                          Spacer(flex: 4),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await model.beDoneOnBoardingPage(context);
                                },
                                child: Text(
                                  'はじめる',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: kDarkPink,
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  side: BorderSide(color: kDarkPink),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  DotIndicator({required this.index, required this.model});

  final int index;
  final OnBoardingModel model;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5.0),
      width: model.currentPage == index ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: model.currentPage == index ? Colors.pinkAccent : kPink,
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

class OnBoardingContent extends StatelessWidget {
  OnBoardingContent({required this.image, required this.text});

  final String image;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Expanded(
          flex: 6,
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        Spacer(),
        Expanded(
          flex: 1,
          child: Container(
            width: 320.0,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  // fontSize: 17.0,
                  // fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
