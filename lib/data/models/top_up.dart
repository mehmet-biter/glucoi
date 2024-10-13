import 'package:tradexpro_flutter/utils/number_util.dart';

import 'gift_card.dart';

class TopUpData {
  List<TopUpCountry>? country;
  List<Coin>? coins;

  TopUpData({
    this.country,
    this.coins,
  });

  factory TopUpData.fromJson(Map<String, dynamic> json) => TopUpData(
        country: json["country"] == null ? null : List<TopUpCountry>.from(json["country"].map((x) => TopUpCountry.fromJson(x))),
        coins: json["coins"] == null ? null : List<Coin>.from(json["coins"].map((x) => Coin.fromJson(x))),
      );
}

class TopUpCountry {
  int? id;
  String? code;
  String? name;
  String? currencyCode;
  String? currencyName;
  String? image;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? label;

  TopUpCountry({
    this.id,
    this.code,
    this.name,
    this.currencyCode,
    this.currencyName,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.label,
  });

  factory TopUpCountry.fromJson(Map<String, dynamic> json) => TopUpCountry(
        id: json["id"],
        code: json["code"] ?? json["isoName"],
        name: json["name"],
        currencyCode: json["currency_code"],
        currencyName: json["currency_name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        label: json["label"],
      );
}

class TopUpOperator {
  int? id;
  int? operatorId;
  String? name;
  bool? bundle;
  bool? data;
  bool? pin;
  bool? supportsLocalAmounts;
  bool? supportsGeographicalRechargePlans;
  String? denominationType;
  String? senderCurrencyCode;
  String? senderCurrencySymbol;
  String? destinationCurrencyCode;
  String? destinationCurrencySymbol;
  double? commission;
  double? internationalDiscount;
  double? localDiscount;
  double? mostPopularAmount;
  TopUpCountry? country;
  Fx? fx;
  String? status;
  List<String>? logoUrls;
  List<int>? fixedAmounts;

  //  TopUpFees? fees;
  // List<dynamic> fixedAmountsDescriptions;
  // List<int>? localFixedAmounts;
  // List<dynamic> localFixedAmountsDescriptions;
  // List<dynamic> suggestedAmounts;
  // List<dynamic> suggestedAmountsMap;
  // List<dynamic> geographicalRechargePlans;
  // List<dynamic> promotions;
  // dynamic mostPopularLocalAmount;
  // dynamic minAmount;
  // dynamic maxAmount;
  // dynamic localMinAmount;
  // dynamic localMaxAmount;

  TopUpOperator({
    this.id,
    this.operatorId,
    this.name,
    this.bundle,
    this.data,
    this.pin,
    this.supportsLocalAmounts,
    this.supportsGeographicalRechargePlans,
    this.denominationType,
    this.senderCurrencyCode,
    this.senderCurrencySymbol,
    this.destinationCurrencyCode,
    this.destinationCurrencySymbol,
    this.commission,
    this.internationalDiscount,
    this.localDiscount,
    this.mostPopularAmount,
    this.country,
    this.fx,
    this.logoUrls,
    this.fixedAmounts,
    this.status,
    //  this.fees,
    // this.mostPopularLocalAmount,
    // this.minAmount,
    // this.maxAmount,
    // this.localMinAmount,
    // this.localMaxAmount,
    // this.fixedAmountsDescriptions,
    // this.localFixedAmounts,
    // this.localFixedAmountsDescriptions,
    // this.suggestedAmounts,
    // this.suggestedAmountsMap,,
    // this.geographicalRechargePlans,
    // this. promotions,
  });

  factory TopUpOperator.fromJson(Map<String, dynamic> json) => TopUpOperator(
        id: json["id"],
        operatorId: json["operatorId"],
        name: json["name"],
        bundle: json["bundle"],
        data: json["data"],
        pin: json["pin"],
        supportsLocalAmounts: json["supportsLocalAmounts"],
        supportsGeographicalRechargePlans: json["supportsGeographicalRechargePlans"],
        denominationType: json["denominationType"],
        senderCurrencyCode: json["senderCurrencyCode"],
        senderCurrencySymbol: json["senderCurrencySymbol"],
        destinationCurrencyCode: json["destinationCurrencyCode"],
        destinationCurrencySymbol: json["destinationCurrencySymbol"],
        commission: makeDouble(json["commission"]),
        internationalDiscount: makeDouble(json["internationalDiscount"]),
        localDiscount: makeDouble(json["localDiscount"]),
        status: json["status"],
        mostPopularAmount: makeDouble(json["mostPopularAmount"]),
        country: json["country"] == null ? null : TopUpCountry.fromJson(json["country"]),
        fx: json["fx"] == null ? null : Fx.fromJson(json["fx"]),
        logoUrls: json["logoUrls"] == null ? null : List<String>.from(json["logoUrls"].map((x) => x)),
        fixedAmounts: json["fixedAmounts"] == null ? null : List<int>.from(json["fixedAmounts"].map((x) => x)),

        // fees: json["fees"] == null ? null : TopUpFees.fromJson(json["fees"]),
        // mostPopularLocalAmount: json["mostPopularLocalAmount"],
        // minAmount: json["minAmount"],
        // maxAmount: json["maxAmount"],
        // localMinAmount: json["localMinAmount"],
        // localMaxAmount: json["localMaxAmount"],
        // fixedAmountsDescriptions: List<dynamic>.from(json["fixedAmountsDescriptions"].map((x) => x)),
        // localFixedAmounts: List<dynamic>.from(json["localFixedAmounts"].map((x) => x)),
        // localFixedAmountsDescriptions: List<dynamic>.from(json["localFixedAmountsDescriptions"].map((x) => x)),
        // suggestedAmounts: List<dynamic>.from(json["suggestedAmounts"].map((x) => x)),
        // suggestedAmountsMap: List<dynamic>.from(json["suggestedAmountsMap"].map((x) => x)),
        // geographicalRechargePlans: List<dynamic>.from(json["geographicalRechargePlans"].map((x) => x)),
        // promotions: List<dynamic>.from(json["promotions"].map((x) => x)),
      );
}

// class TopUpFees {
//   int? international;
//   int? local;
//   int? localPercentage;
//   int? internationalPercentage;
//
//   TopUpFees({
//     this.international,
//     this.local,
//     this.localPercentage,
//     this.internationalPercentage,
//   });
//
//   factory TopUpFees.fromJson(Map<String, dynamic> json) => TopUpFees(
//         international: json["international"],
//         local: json["local"],
//         localPercentage: json["localPercentage"],
//         internationalPercentage: json["internationalPercentage"],
//       );
// }

class Fx {
  double? rate;
  String? currencyCode;

  Fx({this.rate, this.currencyCode});

  factory Fx.fromJson(Map<String, dynamic> json) => Fx(rate: json["rate"].toDouble(), currencyCode: json["currencyCode"]);
}

class TopUpHistory {
  int? id;
  int? userId;
  String? userEmail;
  int? transactionId;
  int? operatorId;
  String? operatorName;
  String? amount;
  String? paidAmount;
  String? recipientAmount;
  String? recipientPhone;
  String? recipientCurrency;
  String? senderCurrency;
  String? paidCurrency;
  String? countryCode;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  TopUpCountry? country;

  TopUpHistory({
    this.id,
    this.userId,
    this.userEmail,
    this.transactionId,
    this.operatorId,
    this.operatorName,
    this.amount,
    this.paidAmount,
    this.recipientAmount,
    this.recipientPhone,
    this.recipientCurrency,
    this.senderCurrency,
    this.paidCurrency,
    this.countryCode,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.country,
  });

  factory TopUpHistory.fromJson(Map<String, dynamic> json) => TopUpHistory(
        id: json["id"],
        userId: json["user_id"],
        userEmail: json["user_email"],
        transactionId: json["transactionId"],
        operatorId: json["operator_id"],
        operatorName: json["operator_name"],
        amount: json["amount"],
        paidAmount: json["paid_amount"],
        recipientAmount: json["recipient_amount"],
        recipientPhone: json["recipient_phone"],
        recipientCurrency: json["recipient_currency"],
        senderCurrency: json["sender_currency"],
        paidCurrency: json["paid_currency"],
        countryCode: json["country_code"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        country: json["country"] == null ? null : TopUpCountry.fromJson(json["country"]),
      );
}

// class TopUpCoin {
//   int? id;
//   String? name;
//   String? coinType;
//   int? currencyType;
//   int? currencyId;
//   int? status;
//   int? adminApproval;
//   int? network;
//   int? isWithdrawal;
//   int? isDeposit;
//   int? isDemoTrade;
//   int? isBuy;
//   int? isSell;
//   dynamic coinIcon;
//   int? isBase;
//   int? isCurrency;
//   dynamic isPrimary;
//   int? isWallet;
//   int? isTransferable;
//   int? isVirtualAmount;
//   int? tradeStatus;
//   dynamic sign;
//   String? minimumBuyAmount;
//   String? maximumBuyAmount;
//   String? minimumSellAmount;
//   String? maximumSellAmount;
//   String? minimumWithdrawal;
//   String? maximumWithdrawal;
//   String? maxSendLimit;
//   String? withdrawalFees;
//   int? withdrawalFeesType;
//   String? coinPrice;
//   int? icoId;
//   int? isListed;
//   int? lastBlockNumber;
//   int? lastTimestamp;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? decimal;
//   int? syncRateStatus;
//   int? convertStatus;
//   String? minConvertAmount;
//   String? maxConvertAmount;
//   int? convertFeeType;
//   String? convertFee;
//   String? marketCap;
//   String? label;
//   String? value;
//
//   TopUpCoin({
//     this.id,
//     this.name,
//     this.coinType,
//     this.currencyType,
//     this.currencyId,
//     this.status,
//     this.adminApproval,
//     this.network,
//     this.isWithdrawal,
//     this.isDeposit,
//     this.isDemoTrade,
//     this.isBuy,
//     this.isSell,
//     this.coinIcon,
//     this.isBase,
//     this.isCurrency,
//     this.isPrimary,
//     this.isWallet,
//     this.isTransferable,
//     this.isVirtualAmount,
//     this.tradeStatus,
//     this.sign,
//     this.minimumBuyAmount,
//     this.maximumBuyAmount,
//     this.minimumSellAmount,
//     this.maximumSellAmount,
//     this.minimumWithdrawal,
//     this.maximumWithdrawal,
//     this.maxSendLimit,
//     this.withdrawalFees,
//     this.withdrawalFeesType,
//     this.coinPrice,
//     this.icoId,
//     this.isListed,
//     this.lastBlockNumber,
//     this.lastTimestamp,
//     this.createdAt,
//     this.updatedAt,
//     this.decimal,
//     this.syncRateStatus,
//     this.convertStatus,
//     this.minConvertAmount,
//     this.maxConvertAmount,
//     this.convertFeeType,
//     this.convertFee,
//     this.marketCap,
//     this.label,
//     this.value,
//   });
//
//   factory TopUpCoin.fromJson(Map<String, dynamic> json) => TopUpCoin(
//         id: json["id"],
//         name: json["name"],
//         coinType: json["coin_type"],
//         currencyType: json["currency_type"],
//         currencyId: json["currency_id"],
//         status: json["status"],
//         adminApproval: json["admin_approval"],
//         network: json["network"],
//         isWithdrawal: json["is_withdrawal"],
//         isDeposit: json["is_deposit"],
//         isDemoTrade: json["is_demo_trade"],
//         isBuy: json["is_buy"],
//         isSell: json["is_sell"],
//         coinIcon: json["coin_icon"],
//         isBase: json["is_base"],
//         isCurrency: json["is_currency"],
//         isPrimary: json["is_primary"],
//         isWallet: json["is_wallet"],
//         isTransferable: json["is_transferable"],
//         isVirtualAmount: json["is_virtual_amount"],
//         tradeStatus: json["trade_status"],
//         sign: json["sign"],
//         minimumBuyAmount: json["minimum_buy_amount"],
//         maximumBuyAmount: json["maximum_buy_amount"],
//         minimumSellAmount: json["minimum_sell_amount"],
//         maximumSellAmount: json["maximum_sell_amount"],
//         minimumWithdrawal: json["minimum_withdrawal"],
//         maximumWithdrawal: json["maximum_withdrawal"],
//         maxSendLimit: json["max_send_limit"],
//         withdrawalFees: json["withdrawal_fees"],
//         withdrawalFeesType: json["withdrawal_fees_type"],
//         coinPrice: json["coin_price"],
//         icoId: json["ico_id"],
//         isListed: json["is_listed"],
//         lastBlockNumber: json["last_block_number"],
//         lastTimestamp: json["last_timestamp"],
//         createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//         updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//         decimal: json["decimal"],
//         syncRateStatus: json["sync_rate_status"],
//         convertStatus: json["convert_status"],
//         minConvertAmount: json["min_convert_amount"],
//         maxConvertAmount: json["max_convert_amount"],
//         convertFeeType: json["convert_fee_type"],
//         convertFee: json["convert_fee"],
//         marketCap: json["market_cap"],
//         label: json["label"],
//         value: json["value"],
//       );
// }
