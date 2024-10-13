import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/success_page.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'kyc_controller.dart';

class KYCDojahScreen extends StatefulWidget {
  const KYCDojahScreen({super.key});

  @override
  State<KYCDojahScreen> createState() => _KYCDojahScreenState();
}

class _KYCDojahScreenState extends State<KYCDojahScreen> {
  // final _controller = Get.isRegistered<KycController>() ? Get.find<KycController>() : Get.put(KycController());
  final _countries = ["Nigeria"];
  final _typeList = ["Bank Verification Number".tr, "National Identification Number".tr];
  final _idList = ["BVN".tr, "NIN".tr];
  final _hintList = ["22398337867".tr, "56743378909".tr];
  RxInt selectedCountry = 0.obs;
  RxInt selectedType = 0.obs;
  final idEditController = TextEditingController();
  Rx<File> selfieImage = File("").obs;

  @override
  void initState() {
    super.initState();
    selectedCountry.value = -1;
    selectedType.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
            child: Column(
              children: [
                appBarBackWithActions(title: "Identity Verification".tr),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(Dimens.paddingMid),
                    children: [
                      textAutoSizeKarla("Country".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                      Obx(() => dropDownListIndex(_countries, selectedCountry.value, "Select Country".tr, (index) => selectedCountry.value = index,
                          hMargin: 0)),
                      Obx(() => selectedCountry.value != -1
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                vSpacer15(),
                                textAutoSizeKarla("Government Data".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                Obx(() => dropDownListIndex(_typeList, selectedType.value, "Select Type".tr, (index) => selectedType.value = index,
                                    hMargin: 0)),
                              ],
                            )
                          : vSpacer0()),
                      Obx(() {
                        return selectedType.value != -1
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  vSpacer15(),
                                  textAutoSizeKarla(_idList[selectedType.value], fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                  vSpacer5(),
                                  textFieldWithSuffixIcon(
                                      hint: _hintList[selectedType.value], controller: idEditController, type: TextInputType.number),
                                  vSpacer15(),
                                  _showUploadImage(selfieImage.value),
                                  textAutoSizePoppins("Face forward and clearly visible".tr, maxLines: 2, textAlign: TextAlign.start),
                                  textAutoSizePoppins("remove your glasses_cap_musk".tr, maxLines: 2, textAlign: TextAlign.start),
                                  vSpacer20(),
                                  buttonRoundedMain(text: "Verify".tr, onPressCallback: () => _handleVerifyAction()),
                                  vSpacer10(),
                                ],
                              )
                            : vSpacer0();
                      })
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  _showUploadImage(File file) {
    return InkWell(
      child: Container(
        height: context.width / 2,
        width: context.width,
        margin: const EdgeInsets.all(Dimens.paddingLarge),
        decoration: boxDecorationRoundBorder(color: context.theme.colorScheme.background),
        child: file.path.isNotEmpty
            ? showImageLocal(file)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buttonOnlyIcon(iconData: Icons.camera_front, size: Dimens.iconSizeLargeExtra, iconColor: context.theme.primaryColor),
                  vSpacer10(),
                  textAutoSizeKarla("Take a Selfie".tr, fontSize: Dimens.regularFontSizeMid),
                ],
              ),
      ),
      onTap: () {
        getImage(false, (chooseFile, isGallery) => selfieImage.value = chooseFile, true, camera: CameraDevice.front);
      },
    );
  }

  void _handleVerifyAction() {
    final id = idEditController.text.trim();
    if (id.isEmpty) {
      showToast("${_typeList[selectedType.value]} ${"is required".tr}");
      return;
    }

    if (selfieImage.value.path.isEmpty) {
      showToast("Selfie image can not be empty".tr);
      return;
    }
    final type = selectedType.value == 1 ? IdVerificationType.nid : IdVerificationType.driving;
    Get.find<KycController>().verifyKycByDojah(type, id, selfieImage.value, () {
      Get.to(() => SuccessPageFullScreen(
          title: "Verification Successful".tr,
          subtitle: "You have completed your Identity verification successfully".tr,
          onDone: () {
            Get.back();
            Get.back();
          }));
    });
  }
}
