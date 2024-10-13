import 'dart:convert';
import 'package:tradexpro_flutter/data/models/faq.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';

GiftCardsData giftCardsDataFromJson(String str) => GiftCardsData.fromJson(json.decode(str));

class GiftCardsData {
  String? header;
  String? description;
  String? banner;
  String? secondHeader;
  String? secondDescription;
  String? secondBanner;
  String? gifCardRedeemDescription;
  String? gifCardAddCardDescription;
  String? gifCardCheckCardDescription;
  List<GiftCardBanner>? banners;
  List<GiftCard>? myCards;
  List<FAQ>? faq;

  GiftCardsData({
    this.header,
    this.description,
    this.banner,
    this.secondHeader,
    this.secondDescription,
    this.secondBanner,
    this.gifCardRedeemDescription,
    this.gifCardAddCardDescription,
    this.gifCardCheckCardDescription,
    this.banners,
    this.myCards,
    this.faq,
  });

  factory GiftCardsData.fromJson(Map<String, dynamic> json) => GiftCardsData(
        header: json["header"],
        description: json["description"],
        banner: json["banner"],
        secondHeader: json["second_header"],
        secondDescription: json["second_description"],
        secondBanner: json["second_banner"],
        gifCardRedeemDescription: json["gif_card_redeem_description"],
        gifCardAddCardDescription: json["gif_card_add_card_description"],
        gifCardCheckCardDescription: json["gif_card_check_card_description"],
        banners: json["banners"] == null ? null : List<GiftCardBanner>.from(json["banners"].map((x) => GiftCardBanner.fromJson(x))),
        myCards: json["my_cards"] == null ? null : List<GiftCard>.from(json["my_cards"].map((x) => GiftCard.fromJson(x))),
        faq: json["faq"] == null ? null : List<FAQ>.from(json["faq"].map((x) => FAQ.fromJson(x))),
      );
}

class GiftCard {
  double? recipientAmount;
  double? payAmount;
  double? unitPrice;
  double? fees;
  double? totalUnitPrice;
  int? quantity;
  GiftCardBanner? banner;
  GiftCardCountry? country;
  String? status;

  int? userId;
  dynamic walletType;
  String? redeemCode;
  String? note;
  int? ownerId;
  int? isAdsCreated;
  DateTime? updatedAt;
  String? uid;
  String? giftCardBannerId;
  String? transactionId;
  String? coinType;
  double? amount;
  DateTime? createdAt;
  String? lockText;
  String? statusText;
  int? lockStatus;
  int? lock;

  GiftCard({
    this.recipientAmount,
    this.payAmount,
    this.unitPrice,
    this.banner,
    this.fees,
    this.quantity,
    this.totalUnitPrice,
    this.country,
    this.status,
    this.userId,
    this.walletType,
    this.redeemCode,
    this.note,
    this.ownerId,
    this.isAdsCreated,
    this.updatedAt,
    this.uid,
    this.giftCardBannerId,
    this.transactionId,
    this.coinType,
    this.amount,
    this.createdAt,
    this.lockText,
    this.statusText,
    this.lockStatus,
    this.lock,
  });

  factory GiftCard.fromJson(Map<String, dynamic> json) => GiftCard(
        recipientAmount: makeDouble(json['recipient_amount']),
        payAmount: makeDouble(json["pay_amount"]),
        unitPrice: makeDouble(json["unit_price"]),
        totalUnitPrice: makeDouble(json["total_unit_price"]),
        fees: makeDouble(json["fee"]),
        quantity: json["quantity"],
        banner: json["banner"] == null ? null : GiftCardBanner.fromJson(json["banner"]),
        country: json["country"] == null ? null : GiftCardCountry.fromJson(json["country"]),
        status: json["status"],

        userId: json["user_id"],
        walletType: json["wallet_type"],
        redeemCode: json["redeem_code"],
        note: json["note"],
        ownerId: json["owner_id"],
        isAdsCreated: json["is_ads_created"],
        lockText: json["lock"].toString(),
        statusText: json["status"].toString(),
        lockStatus: json["lock_status"],
        lock: json["_lock"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        uid: json["uid"],
        giftCardBannerId: json["gift_card_banner_id"],
        transactionId: json["transaction_id"],
        coinType: json["coin_type"],
        amount: makeDouble(json["amount"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );
}

// class GiftCardBanner {
//   String? uid;
//   String? title;
//   String? subTitle;
//   String? banner;
//   String? image;
//
//   GiftCardBanner({
//     this.uid,
//     this.title,
//     this.subTitle,
//     this.banner,
//     this.image,
//   });
//
//   factory GiftCardBanner.fromJson(Map<String, dynamic> json) => GiftCardBanner(
//         uid: json["uid"],
//         title: json["title"],
//         subTitle: json["sub_title"],
//         banner: json["banner"],
//         image: json["image"],
//       );
// }

class GiftCardThemeData {
  String? header;
  String? description;
  String? banner;
  List<GiftCardCountry>? countries;

  GiftCardThemeData({
    this.header,
    this.description,
    this.banner,
    this.countries,
  });

  factory GiftCardThemeData.fromJson(Map<String, dynamic> json) => GiftCardThemeData(
        header: json["header"],
        description: json["description"],
        banner: json["banner"],
        countries: json["countrys"] == null ? null : List<GiftCardCountry>.from(json["countrys"].map((x) => GiftCardCountry.fromJson(x))),
      );
}

class GiftCardSelfData {
  String? header;
  String? description;
  String? banner;

  GiftCardSelfData({this.header, this.description, this.banner});

  factory GiftCardSelfData.fromJson(Map<String, dynamic> json) =>
      GiftCardSelfData(header: json["header"], description: json["description"], banner: json["banner"]);
}

class GiftCardCountry {
  String? code;
  String? name;
  String? value;
  String? label;

  GiftCardCountry({this.code, this.name, this.value, this.label});

  factory GiftCardCountry.fromJson(Map<String, dynamic> json) =>
      GiftCardCountry(code: json["code"], name: json["name"], value: json["value"], label: json["label"]);
}

// class GiftCardCategory {
//   String? uid;
//   String? name;
//   String? label;
//   String? value;
//
//   GiftCardCategory({this.uid, this.name, this.label, this.value});
//
//   factory GiftCardCategory.fromJson(Map<String, dynamic> json) =>
//       GiftCardCategory(uid: json["uid"], name: json["name"], label: json["label"], value: json["value"]);
// }

class GiftCardBuyData {
  String? header;
  String? description;
  String? banner;
  String? featureOne;
  String? featureOneIcon;
  String? featureTwo;
  String? featureTwoIcon;
  String? featureThree;
  String? featureThreeIcon;
  GiftCardBanner? selectedBanner;
  List<Coin>? coins;
  List<GiftCardBanner>? banners;

  GiftCardBuyData({
    this.header,
    this.description,
    this.banner,
    this.featureOne,
    this.featureOneIcon,
    this.featureTwo,
    this.featureTwoIcon,
    this.featureThree,
    this.featureThreeIcon,
    this.selectedBanner,
    this.coins,
    this.banners,
  });

  factory GiftCardBuyData.fromJson(Map<String, dynamic> json) => GiftCardBuyData(
        header: json["header"],
        description: json["description"],
        banner: json["banner"],
        featureOne: json["feature_one"],
        featureOneIcon: json["feature_one_icon"],
        featureTwo: json["feature_two"],
        featureTwoIcon: json["feature_two_icon"],
        featureThree: json["feature_three"],
        featureThreeIcon: json["feature_three_icon"],
        selectedBanner: json["selected_banner"] == null ? null : GiftCardBanner.fromJson(json["selected_banner"]),
        coins: json["coins"] == null ? null : List<Coin>.from(json["coins"].map((x) => Coin.fromJson(x))),
        banners: json["banners"] == null ? null : List<GiftCardBanner>.from(json["banners"].map((x) => GiftCardBanner.fromJson(x))),
      );
}

class Coin {
  String? name;
  String? coinType;
  String? label;
  String? value;

  Coin({this.name, this.coinType, this.label, this.value});

  factory Coin.fromJson(Map<String, dynamic> json) =>
      Coin(name: json["name"], coinType: json["coin_type"], label: json["label"], value: json["value"]);
}

// class GiftCardWalletData {
//   double? exchangeWalletBalance;
//   double? p2PWalletBalance;
//
//   GiftCardWalletData({this.exchangeWalletBalance, this.p2PWalletBalance});
//
//   factory GiftCardWalletData.fromJson(Map<String, dynamic> json) => GiftCardWalletData(
//       exchangeWalletBalance: makeDouble(json["exchange_wallet_balance"]), p2PWalletBalance: makeDouble(json["p2p_wallet_balance"]));
// }

class GiftCardBanner {
  int? id;
  String? uid;
  String? title;
  String? banner;
  String? countryCode;
  String? brandName;
  String? denominationType;
  String? recipientCurrency;
  double? minRecipientAmount;
  double? maxRecipientAmount;
  String? senderCurrency;
  double? minSenderAmount;
  double? maxSenderAmount;
  double? fees;
  double? adminFees;
  double? discount;
  int? updatedBy;
  int? countryStatus;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  GiftCardCountry? country;

  GiftCardBanner({
    this.id,
    this.uid,
    this.title,
    this.banner,
    this.countryCode,
    this.brandName,
    this.denominationType,
    this.recipientCurrency,
    this.minRecipientAmount,
    this.maxRecipientAmount,
    this.senderCurrency,
    this.minSenderAmount,
    this.maxSenderAmount,
    this.fees,
    this.adminFees,
    this.discount,
    this.updatedBy,
    this.countryStatus,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.country,
  });

  factory GiftCardBanner.fromJson(Map<String, dynamic> json) => GiftCardBanner(
        id: json["id"],
        uid: json["uid"],
        title: json["title"],
        banner: json["banner"],
        countryCode: json["country_code"],
        brandName: json["brand_name"],
        denominationType: json["denomination_type"],
        recipientCurrency: json["recipient_currency"],
        minRecipientAmount: makeDouble(json["min_recipient_amount"]),
        maxRecipientAmount: makeDouble(json["max_recipient_amount"]),
        senderCurrency: json["sender_currency"],
        minSenderAmount: makeDouble(json["min_sender_amount"]),
        maxSenderAmount: makeDouble(json["max_sender_amount"]),
        fees: makeDouble(json["fees"]),
        adminFees: makeDouble(json["admin_fees"]),
        discount: makeDouble(json["discount"]),
        updatedBy: json["updated_by"],
        countryStatus: json["country_status"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        country: json["country"] == null ? null : GiftCardCountry.fromJson(json["country"]),
      );
}

// {
// "id": 1,
// "banner_id": 90,
// "user_id": 2,
// "coin_id": 3,
// "wallet_id": 7,
// "banner_uid": "21",
// "user_email": "user@email.com",
// "transaction_id": "20446",
// "denomination_type": "RANGE",
// "coin_type": "NGN",
// "product_name": "App Store & iTunes US",
// "brand_id": "3",
// "brand_name": "App Store & iTunes",
// "country_code": "US",
// "identifier": "Mr_User_1698441790",
// "quantity": 1,
// "pay_amount": "13660.00",
// "unit_price": "2440.00",
// "recipient_amount": "2.00",
// "total_unit_price": "2.00",
// "discount": "107.36",
// "fee": "1220.00",
// "sms_fee": "0.00",
// "recipient_email": "kudoslucia@gmail.com",
// "recipient_phone": null,
// "status": "SUCCESSFUL",
// "created_at": "2023-10-27T17:23:10.000000Z",
// "updated_at": "2023-10-27T21:23:10.000000Z",
// "country": {
// "code": "US",
// "name": "United States"
// },
// "banner": {
// "id": 90,
// "uid": "21",
// "title": "App Store & iTunes US",
// "banner": "https:\/\/cdn.reloadly.com\/giftcards\/08ed62a9-52d3-47d2-9ad8-ae27d0a3f3a2.png",
// "country_code": "US",
// "brand_name": "App Store & iTunes",
// "denomination_type": "RANGE",
// "recipient_currency": "USD",
// "min_recipient_amount": "2.00",
// "max_recipient_amount": "100.00",
// "sender_currency": "NGN",
// "min_sender_amount": "2440.00",
// "max_sender_amount": "122000.00",
// "fees": "1220.00",
// "admin_fees": "0.00",
// "discount": "4.40",
// "updated_by": 1,
// "country_status": 1,
// "status": 1,
// "created_at": "2023-10-27T12:25:05.000000Z",
// "updated_at": "2023-10-27T21:39:04.000000Z"
// },
// "user": {
// "id": 2,
// "email": "user@email.com"
// }
// }
