import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:get/get.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/user.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../models/p2p_profile_details.dart';
import 'p2p_profile/p2p_profile_screen.dart';

class P2pUserView extends StatelessWidget {
  const P2pUserView({Key? key, this.user, this.isActiveOnTap = true, this.name, this.image, this.withName = false}) : super(key: key);
  final User? user;
  final bool isActiveOnTap;
  final bool withName;
  final String? name;
  final String? image;

  @override
  Widget build(BuildContext context) {
    var nameL = name;
    if (user != null) nameL = user?.nickName ?? user?.firstName;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (isActiveOnTap && user != null) ? () => Get.to(() => P2pProfileScreen(userId: user?.id ?? 0)) : null,
        child: Row(
          children: [
            ClipOval(
                child: Container(
                    color: Colors.grey,
                    height: Dimens.iconSizeMid,
                    width: Dimens.iconSizeMid,
                    padding: const EdgeInsets.all(2),
                    child: showCircleAvatar(user?.photo ?? image))),
            hSpacer5(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textAutoSizeTitle(nameL ?? "", fontSize: Dimens.regularFontSizeMid),
                if (withName && user != null) textAutoSizePoppins(getName(user?.firstName, user?.lastName), textAlign: TextAlign.start),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

titleAndDescView(String title, String description) {
  return Container(
    width: Get.width,
    decoration: boxDecorationRoundCorner(),
    padding: const EdgeInsets.all(Dimens.paddingMid),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textAutoSizeTitle(title, fontSize: Dimens.regularFontSizeMid),
        vSpacer10(),
        textAutoSizeKarla(description,
            fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start, maxLines: 50, color: Get.theme.primaryColor.withOpacity(0.75)),
        vSpacer10(),
      ],
    ),
  );
}

class FeedBackItemView extends StatelessWidget {
  const FeedBackItemView({Key? key, required this.feedback}) : super(key: key);
  final P2pFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final btnTitle = feedback.feedbackType == 1 ? "Positive".tr : "Negative".tr;
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: textAutoSizeKarla(feedback.feedback ?? "", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: Dimens.paddingMin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              P2pUserView(isActiveOnTap: false, name: feedback.userName, image: feedback.userImg),
              buttonText(btnTitle, bgColor: feedback.feedbackType == 1 ? Colors.green : Colors.redAccent)
            ],
          ),
        ),
      ),
    );
  }
}

class SegmentedControlView extends StatelessWidget {
  const SegmentedControlView(this.list, this.selected, {Key? key, this.onChange}) : super(key: key);
  final int selected;
  final Function(int)? onChange;
  final List<String> list;

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).textScaleFactor > 1 ? Dimens.regularFontSizeSmall : Dimens.regularFontSizeMid;
    final Map<int, Widget> segmentValues = <int, Widget>{
      1: Text(list.first,
          style: Get.theme.textTheme.titleSmall!
              .copyWith(fontSize: fontSize, color: selected == 1 ? Colors.white : Get.theme.primaryColor),
          textAlign: TextAlign.center),
      2: Text(list.last,
          style: Get.theme.textTheme.titleSmall!
              .copyWith(fontSize: fontSize, color: selected == 2 ? Colors.white : Get.theme.primaryColor),
          textAlign: TextAlign.center)
    };

    return CupertinoSlidingSegmentedControl(
        groupValue: selected,
        children: segmentValues,
        thumbColor: Get.theme.colorScheme.secondary,
        backgroundColor: Colors.grey.withOpacity(0.25),
        padding: const EdgeInsets.all(Dimens.paddingMin),
        onValueChanged: (i) {
          if (onChange != null) onChange!(i as int);
        });
  }
}

class NumberIncrementView extends StatelessWidget {
  const NumberIncrementView({Key? key, required this.controller, this.onTextChange}) : super(key: key);
  final TextEditingController controller;
  final Function(String)? onTextChange;

  @override
  Widget build(BuildContext context) {
    return textFieldWithWidget(prefixWidget: _buttonView(false), controller: controller, suffixWidget: _buttonView(true), type: TextInputType.number);
  }

  _buttonView(bool isIncrement) {
    final icon = isIncrement ? Icons.add : Icons.remove;
    return InkWell(onTap: () => _buttonAction(isIncrement), child: Icon(icon, size: Dimens.iconSizeMin, color: Get.theme.primaryColor));
  }

  _buttonAction(bool isIncrement) {
    var amount = makeDouble(controller.text.trim());
    if (isIncrement) {
      amount = amount + 1;
    } else {
      amount = amount - 1;
      if (amount < 0) return;
    }
    controller.text = amount.toString();
  }
}

class DocumentUploadView extends StatelessWidget {
  const DocumentUploadView({Key? key, this.documentImage, required this.selectedImage}) : super(key: key);
  final File? documentImage;
  final Function(File) selectedImage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: context.width / 3,
        width: context.width,
        decoration: boxDecorationRoundBorder(color: context.theme.scaffoldBackgroundColor),
        child: (documentImage?.path.isValid ?? false)
            ? showImageLocal(documentImage!)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buttonOnlyIcon(iconPath: AssetConstants.icUpload, size: Dimens.iconSizeMid),
                  vSpacer10(),
                  textAutoSizePoppins("Tap to upload photo".tr),
                ],
              ),
      ),
      onTap: () {
        showImageChooser(context, (chooseFile, isGallery) {
          if (isGallery) {
            selectedImage(chooseFile);
          } else {
            saveFileOnTempPath(chooseFile, onNewFile: (newFile) {
              selectedImage(newFile);
            });
          }
        });
      },
    );
  }
}

class TagSelectionViewString extends StatelessWidget {
  const TagSelectionViewString(
      {Key? key, required this.tagList, required this.controller, required this.initialSelection, required this.onTagSelected})
      : super(key: key);
  final List<String> tagList;
  final Function(List<String>) onTagSelected;
  final TextfieldTagsController controller;
  final List<String> initialSelection;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            elevation: 4.0,
            color: Get.theme.colorScheme.background,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final dynamic option = options.elementAt(index);
                return TextButton(
                  onPressed: () => onSelected(option),
                  child: Align(alignment: Alignment.centerLeft, child: Text('$option', textAlign: TextAlign.left, style: Get.textTheme.bodyMedium)),
                );
              },
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return tagList;
        }
        return tagList.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selectedTag) => controller.addTag = selectedTag,
      fieldViewBuilder: (context, tTec, tTn, onFieldSubmitted) {
        return TextFieldTags(
          textEditingController: tTec,
          focusNode: tTn,
          textfieldTagsController: controller,
          initialTags: initialSelection,
          textSeparators: const [' ', ','],
          letterCase: LetterCase.normal,
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) => onTagSelected(tags));
              return TextField(
                controller: tec,
                focusNode: fn,
                style: Get.theme.textTheme.bodyMedium,
                cursorColor: Get.theme.primaryColor,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1, color: Get.theme.dividerColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(width: 1, color: Get.theme.focusColor)),
                  hintText: controller.hasTags ? '' : "Select".tr,
                  prefixIconConstraints: BoxConstraints(maxWidth: Get.width - 100),
                  prefixIcon: tags.isNotEmpty
                      ? SingleChildScrollView(
                          controller: sc,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(tags.length, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                    color: Get.theme.colorScheme.secondary.withOpacity(0.25)),
                                margin: EdgeInsets.only(left: index == 0 ? 10 : 0, right: 10.0),
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tags[index], style: Get.textTheme.bodyMedium!.copyWith(color: Get.theme.primaryColor)),
                                    const SizedBox(width: 5.0),
                                    InkWell(
                                      child: Icon(Icons.cancel, size: Dimens.iconSizeMin, color: Get.theme.primaryColor),
                                      onTap: () => onTagDelete(tags[index]),
                                    )
                                  ],
                                ),
                              );
                            }),
                          ),
                        )
                      : null,
                ),
              );
            });
          },
        );
      },
    );
  }
}

class CountDownView extends StatelessWidget {
  const CountDownView({super.key, required this.endTime, this.onEnd});

  final DateTime endTime;
  final Function()? onEnd;

  @override
  Widget build(BuildContext context) {
    int endTimeMilli = endTime.millisecondsSinceEpoch;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: CountdownTimer(
        endTime: endTimeMilli,
        widgetBuilder: (_, CurrentRemainingTime? time) {
          var text = "${twoDigitInt(time?.days)} : ${twoDigitInt(time?.hours)} : ${twoDigitInt(time?.min)} : ${twoDigitInt(time?.sec)}";
          return Text(text, style: Get.textTheme.bodyLarge!.copyWith(color: Get.theme.focusColor));
        },
        onEnd: onEnd,
      ),
    );
  }
}

class CancelView extends StatelessWidget {
  CancelView({super.key, this.onCancel});

  final Function(String)? onCancel;
  final reasonEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        vSpacer10(),
        textAutoSizeKarla("Cancel Order".tr, fontSize: Dimens.regularFontSizeMid),
        vSpacer20(),
        Align(alignment: Alignment.centerLeft, child: textAutoSizePoppins("Reason to cancel the order".tr)),
        vSpacer5(),
        textFieldWithSuffixIcon(controller: reasonEditController, hint: "Write Your Reason".tr, maxLines: 3, height: 100),
        vSpacer15(),
        buttonRoundedMain(
            text: "Confirm".tr,
            onPressCallback: () {
              final reason = reasonEditController.text.trim();
              if (reason.isEmpty) {
                showToast("reason for the cancellation".tr, context: context);
                return;
              }
              hideKeyboard(context: context);
              if (onCancel != null) onCancel!(reason);
            }),
        vSpacer10(),
      ],
    );
  }
}
