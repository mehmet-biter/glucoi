import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../../models/p2p_ads.dart';
import '../../p2p_common_widgets.dart';
import 'p2p_create_ads_controller.dart';

class CreateAdsPageThree extends StatefulWidget {
  const CreateAdsPageThree({Key? key}) : super(key: key);

  @override
  State<CreateAdsPageThree> createState() => _CreateAdsPageThreeState();
}

class _CreateAdsPageThreeState extends State<CreateAdsPageThree> {
  final _controller = Get.find<P2pCreateAdsController>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimens.paddingMid),
      children: [
        _titleView("Terms [Optional]".tr),
        textFieldWithSuffixIcon(
            controller: _controller.termsEditController, hint: "Terms will be displayed on the counterparty".tr, maxLines: 3, height: 100),
        vSpacer10(),
        _titleView("Auto-reply [Optional]".tr),
        textFieldWithSuffixIcon(
            controller: _controller.replyEditController, hint: "Auto-reply will be displayed on the counterparty".tr, maxLines: 3, height: 100),
        vSpacer10(),
        _titleView("Counterparty Conditions".tr),
        Align(
            alignment: Alignment.centerLeft,
            child: textAutoSizePoppins("Adding counterparty requirements message".tr, maxLines: 2, textAlign: TextAlign.start)),
        vSpacer5(),
        Row(
          children: [
            textAutoSizeKarla("Register".tr, fontSize: Dimens.regularFontSizeMid),
            hSpacer5(),
            textFieldWithSuffixIcon(
                controller: _controller.regiEditController, width: 100, height: 40, type: TextInputType.number, isEnable: !_controller.isEdit),
            hSpacer5(),
            textAutoSizeKarla("days ago".tr, fontSize: Dimens.regularFontSizeMid),
          ],
        ),
        vSpacer5(),
        Row(
          children: [
            textAutoSizeKarla("Holding more than".tr, fontSize: Dimens.regularFontSizeMid),
            hSpacer5(),
            textFieldWithSuffixIcon(
                controller: _controller.holdingEditController, type: TextInputType.number, width: 100, height: 40, isEnable: !_controller.isEdit),
            hSpacer5(),
            textAutoSizeKarla(_controller.currentAds?.coinType ?? "", fontSize: Dimens.regularFontSizeMid),
          ],
        ),
        vSpacer20(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textAutoSizeKarla("Available Region[s]".tr, fontSize: Dimens.regularFontSizeMid),
            Row(
              children: [
                Obx(() => textAutoSizeKarla(_controller.selectedCountryList.length.toString(),
                    fontSize: Dimens.regularFontSizeMid, color: Get.theme.colorScheme.secondary)),
                buttonOnlyIcon(
                    iconData: Icons.cancel_outlined,
                    visualDensity: minimumVisualDensity,
                    iconColor: Get.theme.primaryColor,
                    onPressCallback: () => _controller.countryTagController.clearTags())
              ],
            )
          ],
        ),
        TagSelectionViewString(
            tagList: _controller.getCountryNameList(),
            controller: _controller.countryTagController,
            initialSelection: _controller.selectedCountryList,
            onTagSelected: (list) => _controller.selectedCountryList.value = list),
        vSpacer20(),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          buttonText("Previous".tr, bgColor: Colors.grey, onPressCallback: () {
            _controller.pageController
                .animateToPage(_controller.currentPageCreate - 1, duration: const Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
          }),
          hSpacer10(),
          buttonText(_controller.isEdit ? "Update".tr : "Create".tr, onPressCallback: () => _goForCreate()),
          hSpacer10()
        ]),
        vSpacer20(),
      ],
    );
  }

  _titleView(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Align(alignment: Alignment.centerLeft, child: textAutoSizeKarla(text, fontSize: Dimens.regularFontSizeMid)),
      );

  void _goForCreate() {
    final terms = _controller.termsEditController.text.trim();
    if (terms.isValid) _controller.currentAds?.terms = terms;

    final reply = _controller.replyEditController.text.trim();
    if (reply.isValid) _controller.currentAds?.autoReply = reply;

    _controller.currentAds?.registerDays = makeInt(_controller.regiEditController.text.trim());
    _controller.currentAds?.coinHolding = makeDouble(_controller.holdingEditController.text.trim());

    List<P2pPaymentInfo> payList = [];
    for (final payment in _controller.selectedPayMethods) {
      final object = _controller.adsSettings!.paymentMethods?.firstWhere((element) => element.adminPaymentMethod?.name == payment);
      if (object != null) payList.add(object);
    }
    _controller.currentAds?.paymentMethodList = payList;

    List<String> cList = [];
    if (_controller.selectedCountryList.isValid) {
      for (final country in _controller.selectedCountryList) {
        final key = _controller.adsSettings!.country?.firstWhere((element) => element.value == country).key;
        if (key.isValid) cList.add(key!);
      }
    } else {
      cList = _controller.adsSettings?.country?.map((e) => e.key ?? "").toList() ?? [];
    }
    _controller.currentAds?.country = cList.toSet().join(",");

    hideKeyboard();
    _controller.saveOrEditAds(context);
  }
}
