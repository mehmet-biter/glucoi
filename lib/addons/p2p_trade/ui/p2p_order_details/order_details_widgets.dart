import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_gift_card.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_order.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_ads.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
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

import '../../p2p_constants.dart';
import '../p2p_gift_card/p2p_gift_card_order_details/p2p_gift_order_details_controller.dart';
import 'p2p_order_details_controller.dart';

class OrderInfoView extends StatelessWidget {
  const OrderInfoView({Key? key, this.order, this.gcOrder}) : super(key: key);
  final P2POrder? order;
  final P2PGiftCardOrder? gcOrder;

  @override
  Widget build(BuildContext context) {
    String amount = order != null
        ? "${coinFormat(order?.amount)} ${order?.coinType ?? ""}"
        : "${coinFormat(gcOrder?.amount)} ${gcOrder?.pGiftCard?.giftCard?.coinType ?? ""}";

    String price =
        order != null ? "${coinFormat(order?.price)} ${order?.currency ?? ""}" : "${coinFormat(gcOrder?.price)} ${gcOrder?.currencyType ?? ""}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textAutoSizeKarla("Confirm order info".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
        vSpacer10(),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textAutoSizePoppins("Amount".tr),
                  textAutoSizeKarla(amount, fontSize: Dimens.regularFontSizeMid),
                ],
              ),
            ),
            hSpacer10(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textAutoSizePoppins("Price".tr),
                  textAutoSizeKarla(price, fontSize: Dimens.regularFontSizeMid),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class OrderTimeLimitView extends StatelessWidget {
  const OrderTimeLimitView({Key? key, this.order, this.gcOrder, this.dueMinute, this.onEnd}) : super(key: key);
  final P2POrder? order;
  final P2PGiftCardOrder? gcOrder;
  final int? dueMinute;
  final Function()? onEnd;

  @override
  Widget build(BuildContext context) {
    dynamic currentOrder = gcOrder ?? order;
    if (currentOrder?.status == P2pTradeStatus.escrow && (currentOrder.paymentTime ?? 0) > 0 && (dueMinute ?? 0) > 0) {
      final endTime = DateTime.now().add(Duration(seconds: dueMinute!));
      return Row(
        children: [
          textAutoSizeKarla("${"Time Left".tr} : ", fontSize: Dimens.regularFontSizeMid),
          CountDownView(endTime: endTime, onEnd: onEnd),
        ],
      );
    } else {
      return vSpacer0();
    }
  }
}

class OrderStatusView extends StatelessWidget {
  const OrderStatusView({Key? key, this.order, this.gcOrder}) : super(key: key);
  final P2POrder? order;
  final P2PGiftCardOrder? gcOrder;

  @override
  Widget build(BuildContext context) {
    String title = "";
    Color color = Colors.deepOrange;
    final status = order != null ? order?.status : gcOrder?.status;
    if (status == P2pTradeStatus.timeExpired) {
      title = "Trade time expired".tr;
    } else if (status == P2pTradeStatus.canceled) {
      title = "Trade canceled".tr;
    } else if (status == P2pTradeStatus.paymentDone) {
      title = "Waiting for releasing order".tr;
      color = Colors.amber;
    } else if (status == P2pTradeStatus.escrow) {
      title = "Waiting for payment".tr;
      color = Colors.amber;
    } else if (status == P2pTradeStatus.transferDone) {
      title = "Trade completed".tr;
      color = Colors.green;
    } else if (status == P2pTradeStatus.releasedByAdmin) {
      title = "Order Released By Admin".tr;
      color = Colors.green;
    } else if (status == P2pTradeStatus.refundedByAdmin) {
      title = "Order Refunded By Admin".tr;
    }
    return Column(
      children: [
        vSpacer20(),
        Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLargeExtra),
          decoration: boxDecorationRoundBorder(color: Colors.transparent, borderColor: color),
          child: textAutoSizeTitle(title, fontSize: Dimens.regularFontSizeMid, color: color),
        ),
      ],
    );
  }
}

//ignore: must_be_immutable
class OrderPaymentView extends StatelessWidget {
  OrderPaymentView({Key? key, this.gcOrder, this.order, this.payInfo}) : super(key: key);
  final P2POrder? order;
  final P2PGiftCardOrder? gcOrder;
  final P2pPaymentInfo? payInfo;
  Rx<File> documentImage = File("").obs;

  @override
  Widget build(BuildContext context) {
    final type = payInfo?.adminPaymentMethod?.paymentType ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dividerHorizontal(),
        textWithBackground("Transfer the fund to the seller account provided below".tr, bgColor: Get.theme.colorScheme.secondary.withOpacity(0.5)),
        vSpacer10(),
        _textWithCopyView(payInfo?.adminPaymentMethod?.name ?? "", preText: "Method Name".tr, hideCopy: true),
        vSpacer5(),
        _textWithCopyView(payInfo?.username ?? "", preText: "Account Name".tr),
        if (type == P2pPaymentType.mobile)
          _textWithCopyView(payInfo?.mobileAccountNumber ?? "", preText: "Mobile Number".tr)
        else if (type == P2pPaymentType.card)
          Column(children: [
            _textWithCopyView(payInfo?.cardNumber ?? "", preText: "Card Number".tr),
            vSpacer5(),
            _textWithCopyView(payInfo?.cardType == CardPaymentType.debit ? "Debit".tr : "Credit".tr, preText: "Card Type".tr, hideCopy: true)
          ])
        else if (type == P2pPaymentType.bank)
          Column(children: [
            _textWithCopyView(payInfo?.bankName ?? "", preText: "Bank Name".tr),
            _textWithCopyView(payInfo?.bankAccountNumber ?? "", preText: "Bank Account Number".tr),
            _textWithCopyView(payInfo?.accountOpeningBranch ?? "", preText: "Account Opening Branch".tr),
            _textWithCopyView(payInfo?.transactionReference ?? "", preText: "Transaction Reference".tr),
          ]),
        vSpacer20(),
        textAutoSizePoppins("Select document".tr, color: Get.theme.primaryColor),
        vSpacer5(),
        _showUploadImage(context),
        vSpacer20(),
        buttonRoundedMain(
            text: "Pay and notify seller".tr,
            onPressCallback: () {
              if (documentImage.value.path.isEmpty) {
                showToast("select image of your payment", context: context);
                return;
              }
              if (order != null) {
                Get.find<P2pOrderDetailsController>().p2pPaymentOrder(documentImage.value);
              } else if (gcOrder != null) {
                Get.find<P2pGiftOrderDetailsController>().p2pGiftCardOrderPayNow(documentImage.value);
              }
            }),
        vSpacer10(),
        dividerHorizontal(height: 0),
      ],
    );
  }

  _textWithCopyView(String text, {String? preText, bool hideCopy = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        textAutoSizePoppins("$preText : "),
        textAutoSizeKarla(text, fontSize: Dimens.regularFontSizeMid, maxLines: 2),
        if (!hideCopy)
          buttonOnlyIcon(
              iconPath: AssetConstants.icCopy,
              visualDensity: minimumVisualDensity,
              iconColor: Get.theme.colorScheme.secondary,
              onPressCallback: () => copyToClipboard(text))
      ],
    );
  }

  _showUploadImage(BuildContext context) {
    return Obx(() => InkWell(
          child: Container(
            height: context.width / 3,
            width: context.width,
            decoration: boxDecorationRoundBorder(color: context.theme.scaffoldBackgroundColor),
            child: (documentImage.value.path.isNotEmpty)
                ? showImageLocal(documentImage.value)
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
              isGallery ? documentImage.value = chooseFile : saveFileOnTempPath(chooseFile, onNewFile: (newFile) => documentImage.value = newFile);
            });
          },
        ));
  }
}

class OrderReviewView extends StatelessWidget {
  OrderReviewView({Key? key, this.order, required this.isBuy}) : super(key: key);
  final P2POrder? order;
  final bool isBuy;
  final reviewEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final typeText = isBuy ? "Seller".tr.toLowerCase() : "Buyer".tr.toLowerCase();
    final feedback = isBuy ? order?.buyerFeedback : order?.sellerFeedback;
    final feedbackOpposite = isBuy ? order?.sellerFeedback : order?.buyerFeedback;
    RxInt feedbackType = 1.obs;

    if (order?.status == P2pTradeStatus.transferDone) {
      return Container(
        decoration: boxDecorationRoundCorner(),
        padding: const EdgeInsets.all(Dimens.paddingMid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedbackOpposite != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textAutoSizeKarla("${typeText.toCapitalizeFirst()} ${"Feedback".tr}: ", fontSize: Dimens.regularFontSizeMid),
                  hSpacer5(),
                  Expanded(child: textAutoSizePoppins(feedbackOpposite, maxLines: 20, textAlign: TextAlign.start, color: Get.theme.primaryColor)),
                ],
              ),
            if (feedbackOpposite != null && feedback == null) vSpacer10(),
            if (feedback == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textAutoSizeKarla("${"Submit review about the".tr} $typeText", fontSize: Dimens.regularFontSizeMid),
                  vSpacer5(),
                  textFieldWithSuffixIcon(controller: reviewEditController, hint: "Write your review".tr, maxLines: 2, height: 80),
                  vSpacer10(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textAutoSizeKarla("Review Type".tr, fontSize: Dimens.regularFontSizeMid),
                      vSpacer5(),
                      Obx(() =>
                          SegmentedControlView(["Positive".tr, "Negative".tr], feedbackType.value, onChange: (index) => feedbackType.value = index)),
                    ],
                  ),
                  vSpacer20(),
                  buttonRoundedMain(
                      text: "Submit Review".tr,
                      onPressCallback: () {
                        final reviewText = reviewEditController.text.trim();
                        if (reviewText.isEmpty) {
                          showToast("Write your review".tr);
                          return;
                        }
                        hideKeyboard(context: context);
                        Get.find<P2pOrderDetailsController>().p2pFeedbackOrder(reviewText, feedbackType.value);
                      }),
                  vSpacer10(),
                ],
              ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class OrderDisputeView extends StatelessWidget {
  OrderDisputeView(this.order, {Key? key}) : super(key: key);
  final P2POrder? order;
  final subEditController = TextEditingController();
  final descEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Rx<File> documentImage = File("").obs;
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          textAutoSizeKarla("Dispute Subject".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer5(),
          textFieldWithSuffixIcon(controller: subEditController, hint: "Write Subject".tr),
          vSpacer15(),
          textAutoSizeKarla("Dispute Description".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer5(),
          textFieldWithSuffixIcon(controller: descEditController, hint: "Write the Reason to dispute the order".tr, maxLines: 3, height: 90),
          vSpacer15(),
          textAutoSizeKarla("Select document".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer5(),
          Obx(() => DocumentUploadView(documentImage: documentImage.value, selectedImage: (selected) => documentImage.value = selected)),
          vSpacer20(),
          buttonRoundedMain(
              text: "Confirm".tr,
              onPressCallback: () {
                final title = subEditController.text.trim();
                if (title.isEmpty) {
                  showToast("Write the dispute subject".tr, context: context);
                  return;
                }
                final description = descEditController.text.trim();
                if (description.isEmpty) {
                  showToast("Write the dispute description".tr, context: context);
                  return;
                }
                // if (documentImage.value.path.isEmpty) {
                //   showToast("Select a image for dispute".tr, context: context);
                //   return;
                // }
                hideKeyboard(context: context);
                Get.find<P2pOrderDetailsController>().p2pOrderDispute(title, description, documentImage.value);
              })
        ],
      ),
    );
  }
}

class DisputedView extends StatelessWidget {
  const DisputedView({Key? key, this.p2pGiftCardOrderDetails, this.p2pOrderDetails}) : super(key: key);
  final P2PGiftCardOrderDetails? p2pGiftCardOrderDetails;
  final P2POrderDetails? p2pOrderDetails;

  @override
  Widget build(BuildContext context) {
    dynamic order = p2pOrderDetails != null ? p2pOrderDetails?.order : p2pGiftCardOrderDetails?.order;
    dynamic dispute = p2pOrderDetails != null ? p2pOrderDetails?.dispute : p2pGiftCardOrderDetails?.dispute;
    String title = "";

    if (dispute?.status == 1) {
      if (order?.status == P2pTradeStatus.releasedByAdmin) {
        title = "Order Released By Admin".tr;
      } else if (order?.status == P2pTradeStatus.refundedByAdmin) {
        title = "Order Refunded By Admin".tr;
      } else {
        title = "Disputed".tr;
      }
    } else {
      final disputer = (p2pOrderDetails != null ? p2pOrderDetails?.whoDispute : p2pGiftCardOrderDetails?.whoDispute) ?? "";
      title = disputer == "seller" ? "Seller created dispute against order".tr : "Buyer created dispute against order".tr;
    }
    return dispute == null
        ? vSpacer0()
        : Column(
            children: [
              vSpacer20(),
              Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLargeExtra),
                decoration: boxDecorationRoundBorder(color: Colors.transparent, borderColor: Colors.deepOrangeAccent),
                child: textAutoSizeTitle(title, fontSize: Dimens.regularFontSizeMid, color: Colors.deepOrangeAccent),
              ),
            ],
          );
  }
}

// class DisputedView extends StatelessWidget {
//   DisputedView({Key? key}) : super(key: key);
//   final _controller = Get.find<P2pOrderDetailsController>();
//
//   @override
//   Widget build(BuildContext context) {
//     final order = _controller.orderDetails.value.order;
//     final dispute = _controller.orderDetails.value.dispute;
//     String title = "";
//
//     if (dispute?.status == 1) {
//       if (order?.status == P2pTradeStatus.releasedByAdmin) {
//         title = "Order Released By Admin".tr;
//       } else if (order?.status == P2pTradeStatus.refundedByAdmin) {
//         title = "Order Refunded By Admin".tr;
//       } else {
//         title = "Disputed".tr;
//       }
//     } else {
//       final disputer = _controller.orderDetails.value.whoDispute ?? "";
//       title = disputer == "seller" ? "Seller created dispute against order".tr : "Buyer created dispute against order".tr;
//     }
//
//     return dispute == null
//         ? vSpacer0()
//         : Column(
//             children: [
//               vSpacer20(),
//               Container(
//                 width: Get.width,
//                 padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLargeExtra),
//                 decoration: boxDecorationRoundBorder(color: Colors.transparent, borderColor: Colors.deepOrangeAccent),
//                 child: textAutoSizeTitle(title, fontSize: Dimens.regularFontSizeMid, color: Colors.deepOrangeAccent),
//               ),
//             ],
//           );
//   }
// }
