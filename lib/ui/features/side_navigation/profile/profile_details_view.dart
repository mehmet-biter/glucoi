import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/data/models/user.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'my_profile_controller.dart';

class ProfileDetailsView extends StatefulWidget {
  const ProfileDetailsView({Key? key}) : super(key: key);

  @override
  ProfileDetailsViewState createState() => ProfileDetailsViewState();
}

class ProfileDetailsViewState extends State<ProfileDetailsView> {
  final _controller = Get.find<MyProfileController>();
  List<UserActivity> userActivities = <UserActivity>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = gUserRx.value;
      final dateString = user.birthDate == null ? "No Date of Birth".tr : formatDate(user.birthDate, format: dateFormatMMMMDddYyy);
      return Expanded(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimens.paddingMid),
          children: [
            textAutoSizePoppins("Profile Information".tr, fontSize: Dimens.regularFontSizeExtraMid, textAlign: TextAlign.start),
            vSpacer20(),
            Row(
              children: [
                hSpacer10(),
                showCircleAvatar(user.photo, size: context.width / 4),
                hSpacer10(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textAutoSizeTitle(getName(user.firstName, user.lastName), fontSize: Dimens.regularFontSizeLarge),
                      UserCodeView(code: user.userUniqueId, mainAxisAlignment: MainAxisAlignment.start),
                      textAutoSizePoppins(user.email ?? "", color: context.theme.primaryColor),
                    ],
                  ),
                ),
                hSpacer10(),
              ],
            ),
            const TierItemViewProfile(),
            vSpacer20(),
            textFieldWithSuffixIcon(
                controller: TextEditingController(),
                text: user.nickName.isValid ? user.nickName : "No Nick Name".tr,
                hint: "Nick Name".tr,
                isEnable: false),
            vSpacer10(),
            textFieldWithSuffixIcon(
                controller: TextEditingController(),
                text: user.countryName.isValid ? user.countryName : "No Country".tr,
                hint: "Country".tr,
                isEnable: false),
            vSpacer10(),
            textFieldWithSuffixIcon(
                controller: TextEditingController(), text: getActiveStatusData(user.status).first, hint: "Status".tr, isEnable: false),
            vSpacer10(),
            textFieldWithSuffixIcon(controller: TextEditingController(), text: user.phone ?? "No Phone".tr, hint: "Phone".tr, isEnable: false),
            if (user.phone.isValid && user.phoneVerified != 1)
              textAutoSizePoppins("Your phone number is not verity yet, please verify from the Security Page".tr,
                  color: context.theme.focusColor, maxLines: 2, textAlign: TextAlign.start),
            vSpacer10(),
            textFieldWithSuffixIcon(controller: TextEditingController(), text: dateString, hint: "Date of Birth".tr, isEnable: false),
            vSpacer30(),
            _userActivityListView()
          ],
        ),
      );
    });
  }

  _userActivityListView() {
    if (userActivities.isEmpty) _controller.getUserActivities((list) => userActivities = list);
    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: textAutoSizePoppins("Profile Activity".tr, fontSize: Dimens.regularFontSizeExtraMid),
      ),
      vSpacer20(),
      _activitySectionView(),
      userActivities.isEmpty
          ? vSpacer0()
          : Column(children: List.generate(userActivities.length, (index) => _userActivityItem(userActivities[index]))),
      vSpacer20(),
    ]);
  }

  _activitySectionView() {
    return Container(
      decoration: boxDecorationTopRound(color: context.theme.colorScheme.background),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
      height: Dimens.btnHeightMain,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(flex: 1, child: textAutoSizePoppins("Action".tr, textAlign: TextAlign.start)),
          Expanded(flex: 1, child: textAutoSizePoppins("IP Address".tr)),
          Expanded(flex: 1, child: textAutoSizePoppins("Time".tr, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  _userActivityItem(UserActivity activity) {
    String actionString = "${getActivityActionText(activity.action)}\n${activity.source ?? ""}";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
      child: Row(
        children: [
          Expanded(flex: 1, child: textAutoSizePoppins(actionString, maxLines: 2, textAlign: TextAlign.start)),
          Expanded(flex: 1, child: textAutoSizePoppins(activity.ipAddress ?? "", maxLines: 2)),
          Expanded(
              flex: 1,
              child: textAutoSizePoppins(formatDate(activity.updatedAt, format: dateTimeFormatYyyyMMDdHhMm), maxLines: 2, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class TierItemViewProfile extends StatelessWidget {
  const TierItemViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final sts = getSettingsLocal();
    final amount = gIsKYCVerified ? (sts?.dailyMaxWithdrawDepositAmount ?? 0) : 0;
    return sts?.dailyMaxWithdrawDepositStatus == 1
        ? Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingLarge),
            child: Card(
              elevation: gIsDarkMode ? 10 : 0,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: context.theme.focusColor), borderRadius: const BorderRadius.all(Radius.circular(Dimens.radiusCorner))),
              child: Padding(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textAutoSizePoppins("24h Withdrawal Limit".tr),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        textAutoSizeKarla("NGN $amount"),
                        gIsKYCVerified
                            ? hSpacer10()
                            : buttonText("Increase".tr.toUpperCase(), onPressCallback: () => Get.find<MyProfileController>().selectedType.value = 2)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : vSpacer0();
  }
}
