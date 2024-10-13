import 'package:tradexpro_flutter/data/models/top_up.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';

import 'gift_card.dart';

class UtilityBillData {
  List<UtilityService>? services;
  List<Coin>? coins;

  UtilityBillData({
    this.services,
    this.coins,
  });

  factory UtilityBillData.fromJson(Map<String, dynamic> json) => UtilityBillData(
        services: json["services"] == null ? null : List<UtilityService>.from(json["services"].map((x) => UtilityService.fromJson(x))),
        coins: json["coins"] == null ? null : List<Coin>.from(json["coins"].map((x) => Coin.fromJson(x))),
      );
}

class UtilityService {
  int? id;
  String? name;
  String? type;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? reLoadLy;

  UtilityService({
    this.id,
    this.name,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.reLoadLy,
  });

  factory UtilityService.fromJson(Map<String, dynamic> json) => UtilityService(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        reLoadLy: json["reloadly"],
      );
}

class UtilityBiller {
  int? id;
  String? name;
  String? countryCode;
  String? countryName;
  String? type;
  String? serviceType;
  bool? localAmountSupported;
  String? localTransactionCurrencyCode;
  double? localTransactionFee;
  String? localTransactionFeeCurrencyCode;
  int? localDiscountPercentage;
  bool? internationalAmountSupported;
  String? internationalTransactionCurrencyCode;
  double? internationalTransactionFee;
  String? internationalTransactionFeeCurrencyCode;
  int? internationalDiscountPercentage;
  String? denominationType;
  Fx? fx;
  List<UtilityFixedAmount>? internationalFixedAmounts;

  String? billerCode;
  String? itemCode;
  double? amount;
  String? labelName;
  String? billerName;

  UtilityBiller({
    this.id,
    this.name,
    this.countryCode,
    this.countryName,
    this.type,
    this.serviceType,
    this.localAmountSupported,
    this.localTransactionCurrencyCode,
    this.localTransactionFee,
    this.localTransactionFeeCurrencyCode,
    this.localDiscountPercentage,
    this.internationalAmountSupported,
    this.internationalTransactionCurrencyCode,
    this.internationalTransactionFee,
    this.internationalTransactionFeeCurrencyCode,
    this.internationalDiscountPercentage,
    this.denominationType,
    this.fx,
    this.internationalFixedAmounts,
    this.itemCode,
    this.billerCode,
    this.amount,
    this.labelName,
    this.billerName,
  });

  factory UtilityBiller.fromJson(Map<String, dynamic> json) => UtilityBiller(
        id: makeInt(json["id"]),
        name: json["name"],
        countryCode: json["countryCode"],
        countryName: json["countryName"],
        type: json["type"],
        serviceType: json["serviceType"],
        localAmountSupported: json["localAmountSupported"],
        localTransactionCurrencyCode: json["localTransactionCurrencyCode"],
        localTransactionFee: makeDouble(json["localTransactionFee"]),
        localTransactionFeeCurrencyCode: json["localTransactionFeeCurrencyCode"],
        localDiscountPercentage: json["localDiscountPercentage"],
        internationalAmountSupported: json["internationalAmountSupported"],
        internationalTransactionCurrencyCode: json["internationalTransactionCurrencyCode"],
        internationalTransactionFee: makeDouble(json["internationalTransactionFee"]),
        internationalTransactionFeeCurrencyCode: json["internationalTransactionFeeCurrencyCode"],
        internationalDiscountPercentage: json["internationalDiscountPercentage"],
        fx: json["denominationType"] == null ? null : Fx.fromJson(json["fx"]),
        denominationType: json["denominationType"],
        internationalFixedAmounts: json["internationalFixedAmounts"] == null
            ? null
            : List<UtilityFixedAmount>.from(json["internationalFixedAmounts"].map((x) => UtilityFixedAmount.fromJson(x))),
        amount: makeDouble(json["amount"]),
        billerCode: json["biller_code"],
        itemCode: json["item_code"],
        labelName: json["label_name"],
        billerName: json["biller_name"],
      );
}

class UtilityFixedAmount {
  int? id;
  double? amount;
  String? description;

  UtilityFixedAmount({
    this.id,
    this.amount,
    this.description,
  });

  factory UtilityFixedAmount.fromJson(Map<String, dynamic> json) => UtilityFixedAmount(
        id: json["id"],
        amount: makeDouble(json["amount"]),
        description: json["description"],
      );
}

class UtilityBillHistory {
  int? id;
  int? transactionId;
  int? userId;
  int? coinId;
  int? walletId;
  int? countryId;
  String? countryCode;
  int? billerId;
  String? billerName;
  String? billerType;
  String? paidAmount;
  String? senderAmount;
  String? senderCurrency;
  String? paidCurrency;
  String? transactionCode;
  String? referenceId;
  String? status;
  DateTime? finalStatusAvailabilityAt;
  DateTime? submittedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  TopUpCountry? country;
  UtilityService? service;

  UtilityBillHistory({
    this.id,
    this.transactionId,
    this.userId,
    this.coinId,
    this.walletId,
    this.countryId,
    this.countryCode,
    this.billerId,
    this.billerName,
    this.billerType,
    this.paidAmount,
    this.senderAmount,
    this.senderCurrency,
    this.paidCurrency,
    this.transactionCode,
    this.referenceId,
    this.status,
    this.finalStatusAvailabilityAt,
    this.submittedAt,
    this.createdAt,
    this.updatedAt,
    this.country,
    this.service,
  });

  factory UtilityBillHistory.fromJson(Map<String, dynamic> json) => UtilityBillHistory(
        id: json["id"],
        transactionId: json["transaction_id"],
        userId: json["user_id"],
        coinId: json["coin_id"],
        walletId: json["wallet_id"],
        countryId: json["country_id"],
        countryCode: json["country_code"],
        billerId: json["biller_id"],
        billerName: json["biller_name"],
        billerType: json["biller_type"],
        paidAmount: json["paid_amount"],
        senderAmount: json["sender_amount"],
        senderCurrency: json["sender_currency"],
        paidCurrency: json["paid_currency"],
        transactionCode: json["transaction_code"],
        referenceId: json["reference_id"],
        status: json["status"],
        finalStatusAvailabilityAt: json["finalStatusAvailabilityAt"] == null ? null : DateTime.parse(json["finalStatusAvailabilityAt"]),
        submittedAt: json["submitted_at"] == null ? null : DateTime.parse(json["submitted_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        country: json["country"] == null ? null : TopUpCountry.fromJson(json["country"]),
        service: json["service"] == null ? null : UtilityService.fromJson(json["service"]),
      );
}

class UtilityBillHistoryFlutter {
  int? id;
  String? name;
  String? service;
  String? user;
  TopUpCountry? country;
  String? currency;
  double? amount;
  double? fees;
  String? ref;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  UtilityBillHistoryFlutter({
    this.id,
    this.name,
    this.service,
    this.user,
    this.country,
    this.currency,
    this.amount,
    this.fees,
    this.ref,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UtilityBillHistoryFlutter.fromJson(Map<String, dynamic> json) => UtilityBillHistoryFlutter(
        id: json["id"],
        name: json["name"],
        service: json["service"],
        user: json["user"],
        country: json["country"] == null ? null : TopUpCountry.fromJson(json["country"]),
        currency: json["currency"],
        amount: makeDouble(json["amount"]),
        fees: makeDouble(json["fees"]),
        ref: json["ref"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );
}
