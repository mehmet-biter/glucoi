import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_constants.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_phase.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_settings.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_phase_details_page.dart';

class IcoPhaseItemView extends StatelessWidget {
  const IcoPhaseItemView({super.key, required this.phase});

  final IcoPhase phase;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => ICOPhaseDetailsPage(phase: phase)),
        child: Container(
            decoration: boxDecorationRoundCorner(),
            padding: const EdgeInsets.all(Dimens.paddingMid),
            child: Column(
              children: [
                Row(children: [
                  showImageNetwork(imagePath: phase.image, width: Dimens.iconSizeLargeExtra, height: Dimens.iconSizeLargeExtra, boxFit: BoxFit.cover),
                  hSpacer10(),
                  Expanded(child: IcoPhaseInfoView(phase: phase, flex: 5))
                ]),
                vSpacer10(),
                twoTextSpaceFixed("${"Sale Price".tr}: ", "1 ${phase.coinType ?? ""} = ${coinFormat(phase.coinPrice)} ${phase.coinCurrency ?? ""}"),
                vSpacer2(),
                twoTextSpaceFixed("${"Start Time".tr}: ", formatDate(phase.startDate, format: dateTimeFormatDdMMMMYyyyHhMm)),
                vSpacer2(),
                twoTextSpaceFixed("${"End Time".tr}: ", formatDate(phase.endDate, format: dateTimeFormatDdMMMMYyyyHhMm)),
              ],
            )),
      ),
    );
  }
}

class IcoPhaseInfoView extends StatelessWidget {
  const IcoPhaseInfoView({super.key, required this.phase, this.flex, this.fromPage});

  final IcoPhase phase;
  final int? flex;
  final String? fromPage;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      twoTextSpaceFixed("${"Tokens Offered".tr}: ", "${coinFormat(phase.totalTokenSupply)} ${phase.coinType ?? ""}", flex: flex),
      vSpacer2(),
      twoTextSpaceFixed("${"Tokens Sold".tr}: ", "${coinFormat(phase.soldPhaseTokens)} ${phase.coinType ?? ""}", flex: flex),
      vSpacer2(),
      twoTextSpaceFixed("${"Tokens Available".tr}: ", "${coinFormat(phase.availableTokenSupply)} ${phase.coinType ?? ""}", flex: flex),
      vSpacer2(),
      twoTextSpaceFixed("${"Participants".tr}: ", (phase.totalParticipated ?? 0).toString(), flex: flex),
      if (fromPage == IcoFromKey.details)
        Column(children: [
          vSpacer2(),
          twoTextSpaceFixed("${"Sale Price".tr}: ", "1 ${phase.coinType ?? ""} = ${coinFormat(phase.coinPrice)} ${phase.coinCurrency ?? ""}"),
          vSpacer2(),
          twoTextSpaceFixed("${"Base Coin".tr}: ", phase.baseCoin ?? ""),
          vSpacer2(),
          twoTextSpaceFixed("${"Token Type".tr}: ", phase.network ?? ""),
        ])
      else if (fromPage == IcoFromKey.buyToken)
        Column(children: [
          vSpacer2(),
          twoTextSpaceFixed("${"Sale Price".tr}: ", "1 ${phase.coinType ?? ""} = ${coinFormat(phase.coinPrice)} ${phase.coinCurrency ?? ""}"),
          vSpacer2(),
          twoTextSpaceFixed("${"Start Time".tr}: ", formatDate(phase.startDate, format: dateTimeFormatDdMMMMYyyyHhMm)),
          vSpacer2(),
          twoTextSpaceFixed("${"End Time".tr}: ", formatDate(phase.endDate, format: dateTimeFormatDdMMMMYyyyHhMm)),
        ])
    ]);
  }
}

class IcoTokenPriceView extends StatelessWidget {
  const IcoTokenPriceView({super.key, required this.token});

  final TokenPriceInfo token;

  @override
  Widget build(BuildContext context) {
    return token.tokenAmount == null
        ? vSpacer0()
        : Container(
            decoration: boxDecorationRoundBorder(),
            padding: const EdgeInsets.all(Dimens.paddingMid),
            margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textAutoSizeKarla("Token Info".tr, fontSize: Dimens.regularFontSizeLarge),
                vSpacer10(),
                twoTextSpaceFixed("${"Price".tr}: ", coinFormat(token.tokenPrice)),
                vSpacer2(),
                twoTextSpaceFixed("${"Amount".tr}: ", coinFormat(token.tokenAmount)),
                vSpacer2(),
                twoTextSpaceFixed("${"Pay Amount".tr}: ", coinFormat(token.payAmount)),
                vSpacer2(),
                twoTextSpaceFixed("${"Total Price".tr}: ", coinFormat(token.tokenTotalPrice)),
                vSpacer2(),
                twoTextSpaceFixed("${"Token Currency".tr}: ", token.tokenCurrency ?? ""),
                vSpacer2(),
                twoTextSpaceFixed("${"Pay Currency".tr}: ", token.payCurrency ?? ""),
              ],
            ),
          );
  }
}

class IcoBankInfoView extends StatelessWidget {
  const IcoBankInfoView({super.key, required this.bank});

  final Bank bank;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundBorder(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textAutoSizeKarla("Bank Info".tr, fontSize: Dimens.regularFontSizeLarge),
          vSpacer10(),
          twoTextSpaceFixed("${"Name".tr}: ", bank.bankName ?? "", subMaxLine: 2),
          vSpacer2(),
          twoTextSpaceFixed("${"Address".tr}: ", bank.bankAddress ?? "", subMaxLine: 2),
          vSpacer2(),
          twoTextSpaceFixed("${"Holder Name".tr}: ", bank.accountHolderName ?? "", subMaxLine: 2),
          vSpacer2(),
          twoTextSpaceFixed("${"Holder Address".tr}: ", bank.accountHolderAddress ?? "", subMaxLine: 2),
          vSpacer2(),
          twoTextSpaceFixed("${"Swift Code".tr}: ", bank.swiftCode ?? "", subMaxLine: 2),
          vSpacer2(),
          twoTextSpaceFixed("${"IBAN".tr}: ", bank.iban ?? "", subMaxLine: 2),
        ],
      ),
    );
  }
}
