import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/gift_card.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/gift_cards/gift_cards_self/gift_cards_self_screen.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';

class GiftCardBuyController extends GetxController {
  GiftCardBuyData? giftCardBuyData;
  bool isLoading = true;
  RxInt selectedBannerIndex = 0.obs;
  GiftCardBanner selectedBanner = GiftCardBanner();

  // Rx<Country> selectedCountry = Country.parse("us").obs;
  RxBool isPreOrder = false.obs;
  RxInt selectedCoin = 0.obs;
  RxInt quantity = 0.obs;
  RxDouble amount = 0.0.obs;
  RxDouble totalCurrencyAmount = 0.0.obs;

  List<String> getCoinNameList() {
    if (giftCardBuyData?.coins.isValid ?? false) {
      return giftCardBuyData!.coins!.map((e) => e.coinType ?? "").toList();
    }
    return [];
  }

  String getCoinType() {
    if (selectedCoin.value != -1 && (giftCardBuyData?.coins.isValid ?? false)) {
      return giftCardBuyData!.coins![selectedCoin.value].coinType ?? "";
    }
    return "";
  }

  void getGiftCardBuyData(String uid, Function() onSuccess) {
    APIRepository().getGiftCardBuyData(uid).then((resp) {
      isLoading = false;
      if (resp.success && resp.data != null) {
        giftCardBuyData = GiftCardBuyData.fromJson(resp.data);
        onSuccess();
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoading = false;
      showToast(err.toString());
    });
  }

  void getGiftCardCoinConvert() {
    if (selectedCoin.value == -1) return;
    if (amount.value <= 0 || quantity.value <= 0) {
      totalCurrencyAmount.value = 0;
      return;
    }
    final unitPrice = (selectedBanner.minSenderAmount ?? 0) / (selectedBanner.minRecipientAmount ?? 0);
    final feeAmount = (selectedBanner.fees ?? 0) * quantity.value;
    final totalPrice = ((unitPrice * amount.value) * quantity.value) + feeAmount;
    APIRepository().getGiftCardCoinConvert(getCoinType(), selectedBanner.senderCurrency ?? "", totalPrice.toDouble()).then((resp) {
      if (resp.data != null) {
        totalCurrencyAmount.value = makeDouble(resp.data[APIKeyConstants.amount]);
      }
      if (!resp.success) showToast(resp.message);
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void giftCardBuyCard() async {
    showLoadingDialog();
    final bannerId = selectedBanner.uid ?? "";
    final preOrder = isPreOrder.value ? 1 : 0;
    final unitPrice = (selectedBanner.minSenderAmount ?? 0) / (selectedBanner.minRecipientAmount ?? 0) * amount.value;
    // String? phoneNum = phone.replaceFirst(selectedCountry.value.phoneCode, "");
    // phoneNum = phoneNum.isValid ? phone : null;
    // final cCode = phoneNum.isValid ? selectedCountry.value.countryCode : null;

    APIRepository().giftCardBuyCard(bannerId, getCoinType(), quantity.value, preOrder, amount.value, totalCurrencyAmount.value, unitPrice).then(
        (resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success, isLong: !resp.success);
      if (resp.success) Get.off(() => const GiftCardSelfScreen());
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

// void checkAndBuyGiftCard(BuildContext context) async {
//   final bannerId = giftCardBuyData?.selectedBanner?.uid ?? "";
//   if (bannerId.isEmpty) {
//     showToast("Gift Card ID not found".tr, context: context);
//     return;
//   }
//   final coinType = getCoinType();
//   if (coinType.isEmpty) {
//     showToast("Select your coin".tr, context: context);
//     return;
//   }
//   if (amount.value <= 0) {
//     showToast("amount_must_greater_than_0".tr, context: context);
//     return;
//   }
//   // final balance = selectedWallet.value == WalletType.p2p ? walletData.value.p2PWalletBalance : walletData.value.exchangeWalletBalance;
//   // if (amount.value > (balance ?? 0)) {
//   //   showToast("Amount_greater_then".trParams({"amount": "$balance"}), context: context);
//   //   return;
//   // }
//   //
//   // if (selectedWallet.value == 0) {
//   //   showToast("select your wallet".tr, context: context);
//   //   return;
//   // }
//   // if (selectedTab.value == 1 && quantity.value <= 0) {
//   //   showToast("Quantity is required".tr, context: context);
//   //   return;
//   // }
//   // final lock = isLock.value ? 1 : 0;
//   // final note = noteEditController.text.trim();
// }

// void checkAndBuyGiftCard(BuildContext context) async {
//   final bannerId = giftCardBuyData?.selectedBanner?.uid ?? "";
//   if (bannerId.isEmpty) {
//     showToast("Gift Card ID not found".tr, context: context);
//     return;
//   }
//   final coinType = getCoinType();
//   if (coinType.isEmpty) {
//     showToast("Select your coin".tr, context: context);
//     return;
//   }
//   if (amount.value <= 0) {
//     showToast("amount_must_greater_than_0".tr, context: context);
//     return;
//   }
//   final balance = selectedWallet.value == WalletType.p2p ? walletData.value.p2PWalletBalance : walletData.value.exchangeWalletBalance;
//   if (amount.value > (balance ?? 0)) {
//     showToast("Amount_greater_then".trParams({"amount": "$balance"}), context: context);
//     return;
//   }
//
//   if (selectedWallet.value == 0) {
//     showToast("select your wallet".tr, context: context);
//     return;
//   }
//   if (selectedTab.value == 1 && quantity.value <= 0) {
//     showToast("Quantity is required".tr, context: context);
//     return;
//   }
//   final lock = isLock.value ? 1 : 0;
//   final note = noteEditController.text.trim();
//
//   hideKeyboard(context: context);
//   showLoadingDialog();
//   APIRepository().giftCardBuy(bannerId, coinType, selectedWallet.value, amount.value, quantity.value, lock, selectedTab.value, note).then((resp) {
//     hideLoadingDialog();
//     showToast(resp.message, isError: !resp.success, context: context);
//     if (resp.success) {
//       Get.off(() => const GiftCardSelfScreen());
//     }
//   }, onError: (err) {
//     hideLoadingDialog();
//     showToast(err.toString());
//   });
// }
}
