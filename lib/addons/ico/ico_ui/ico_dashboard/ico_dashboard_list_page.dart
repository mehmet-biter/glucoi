import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_helper.dart';
import 'package:tradexpro_flutter/addons/ico/ico_ui/ico_chat/ico_chat_screen.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_dashboard.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../ico_create_phase/ico_create_phase_screen.dart';
import '../ico_create_token/ico_create_token_screen.dart';
import '../ico_token_phase_list/ico_token_phase_list_screen.dart';
import 'ico_dashboard_controller.dart';

class IcoDashboardListPage extends StatelessWidget {
  IcoDashboardListPage({super.key});

  final _controller = Get.find<IcoDashboardController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getIcoListData(false));

    return Obx(() {
      return _controller.icoDataList.isEmpty
          ? handleEmptyViewWithLoading(_controller.isLoading.value)
          : Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                itemCount: _controller.icoDataList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_controller.hasMoreData && index == (_controller.icoDataList.length - 1) && !_controller.isLoading.value) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getIcoListData(true));
                  }
                  final item = _controller.icoDataList[index];
                  final selectedType = _controller.selectedType.value;
                  if (selectedType == 0 && item is IcoDynamicForm) {
                    return IcoDynamicFormItemView(dynamicForm: item);
                  } else if (selectedType == 1 && item is IcoToken) {
                    return IcoTokenItemView(token: item);
                  } else if (selectedType == 2 && item is IcoBuyToken) {
                    return IcoBuyTokenItemView(token: item);
                  } else if (selectedType == 3 && item is IcoMyToken) {
                    return IcoMyTokenItemView(token: item);
                  }
                  return Container();
                },
              ),
            );
    });
  }
}

class IcoDynamicFormItemView extends StatelessWidget {
  const IcoDynamicFormItemView({super.key, required this.dynamicForm});

  final IcoDynamicForm dynamicForm;

  @override
  Widget build(BuildContext context) {
    final statusData = getStatusData(dynamicForm.status ?? 0);
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          twoTextSpaceFixed("ID".tr, (dynamicForm.uniqueId ?? 0).toString()),
          twoTextSpaceFixed("Status".tr, statusData.first, subColor: statusData.last),
          twoTextSpaceFixed("Created At".tr, formatDate(dynamicForm.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm)),
          twoTextSpaceFixed("Updated At".tr, formatDate(dynamicForm.updatedAt, format: dateTimeFormatDdMMMMYyyyHhMm)),
          if (dynamicForm.status == 1 && dynamicForm.tokenCreateStatus == 1)
            buttonText("Create Token".tr, onPressCallback: () => Get.to(() => const IcoCreateTokenScreen()))
        ],
      ),
    );
  }
}

class IcoTokenItemView extends StatelessWidget {
  const IcoTokenItemView({super.key, required this.token});

  final IcoToken token;

  @override
  Widget build(BuildContext context) {
    final statusData = getApprovedStatusData(token.status);
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          twoTextSpaceFixed("Base Coin".tr, token.baseCoin ?? ""),
          twoTextSpaceFixed("Token Name".tr, token.tokenName ?? ""),
          twoTextSpaceFixed("Approved Status".tr, statusData.first, subColor: statusData.last, flex: 5),
          twoTextSpaceFixed("Date".tr, formatDate(token.createdAt), flex: 5),
          twoTextSpaceFixed("Wallet Address".tr, token.walletAddress ?? "", flex: 5),
          Row(
            children: [
              textAutoSizeKarla("Actions".tr, fontSize: Dimens.regularFontSizeMid),
              const Spacer(),
              buttonOnlyIcon(
                  iconData: Icons.create_new_folder_rounded,
                  size: Dimens.iconSizeMid,
                  visualDensity: minimumVisualDensity,
                  iconColor: context.theme.primaryColor,
                  onPressCallback: () => Get.to(() => IcoCreatePhaseScreen(token: token))),
              buttonOnlyIcon(
                  iconData: Icons.chat_bubble_rounded,
                  size: Dimens.iconSizeMid,
                  visualDensity: minimumVisualDensity,
                  iconColor: context.theme.primaryColor,
                  onPressCallback: () => Get.to(() => ICOChatScreen(token: token))),
              buttonOnlyIcon(
                  iconData: Icons.drive_file_rename_outline_rounded,
                  size: Dimens.iconSizeMid,
                  visualDensity: minimumVisualDensity,
                  iconColor: context.theme.primaryColor,
                  onPressCallback: () => Get.to(() => IcoCreateTokenScreen(preToken: token))),
              buttonOnlyIcon(
                  iconData: Icons.list_rounded,
                  size: Dimens.iconSizeMid,
                  visualDensity: minimumVisualDensity,
                  iconColor: context.theme.primaryColor,
                  onPressCallback: () => Get.to(() => IcoTokenPhaseListScreen(token: token))),
            ],
          )
        ],
      ),
    );
  }
}

class IcoBuyTokenItemView extends StatelessWidget {
  const IcoBuyTokenItemView({super.key, required this.token});

  final IcoBuyToken token;

  @override
  Widget build(BuildContext context) {
    final statusData = getApprovedStatusData(token.status);
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          twoTextSpaceFixed("Token Name".tr, token.tokenName ?? ""),
          twoTextSpaceFixed("Amount".tr, "${coinFormat(token.amount)} ${token.buyCurrency}"),
          twoTextSpaceFixed("Amount Paid".tr, "${coinFormat(token.payAmount)} ${token.payCurrency}"),
          twoTextSpaceFixed("Approved Status".tr, statusData.first, subColor: statusData.last, flex: 5),
          twoTextSpaceFixed("Date".tr, formatDate(token.createdAt), flex: 5),
          twoTextSpaceFixed("Transaction ID".tr, token.trxId ?? "N/A".tr, flex: 5),
          twoTextSpaceFixed("Payment Method".tr, token.paymentMethod ?? "", flex: 5),
        ],
      ),
    );
  }
}

class IcoMyTokenItemView extends StatelessWidget {
  const IcoMyTokenItemView({super.key, required this.token});

  final IcoMyToken token;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(children: [
            textAutoSizeKarla("Asset".tr, fontSize: Dimens.regularFontSizeMid),
            const Spacer(),
            showImageNetwork(imagePath: token.coinIcon, width: Dimens.iconSizeMin, height: Dimens.iconSizeMin),
            hSpacer2(),
            textAutoSizeKarla(token.name ?? "", fontSize: Dimens.regularFontSizeMid),
          ]),
          twoTextSpaceFixed("Symbol".tr, token.coinType ?? ""),
          twoTextSpaceFixed("Available Balance".tr, coinFormat(token.balance), flex: 5),
          twoTextSpaceFixed("Date".tr, formatDate(token.createdAt, format: dateFormatMMMMDddYyy), flex: 5),
          vSpacer5(),
          Row(
            children: [
              textAutoSizeKarla("Address".tr, fontSize: Dimens.regularFontSizeMid),
              const Spacer(),
              SizedBox(
                  width: Get.width / 2,
                  child: textAutoSizeKarla(token.address ?? "", fontSize: Dimens.regularFontSizeMid, maxLines: 2, textAlign: TextAlign.end)),
              buttonOnlyIcon(
                  iconPath: AssetConstants.icCopy,
                  iconColor: Get.theme.focusColor,
                  visualDensity: minimumVisualDensity,
                  onPressCallback: () => copyToClipboard(token.address ?? ""))
            ],
          ),
        ],
      ),
    );
  }
}
