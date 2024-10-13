import 'package:tradexpro_flutter/data/models/history.dart';

class FlutterWaveData {
  FiatHistory? depositDetails;
  WalletCurrencyHistory? walletDepositDetails;
  FlutterWaveBankDetails? flutterWaveBankDetails;

  FlutterWaveData({this.depositDetails, this.flutterWaveBankDetails, this.walletDepositDetails});

  factory FlutterWaveData.fromJson(Map<String, dynamic> json) => FlutterWaveData(
        depositDetails: json["deposit_details"] == null ? null : FiatHistory.fromJson(json["deposit_details"]),
        walletDepositDetails: json["wallet_deposit_details"] == null ? null : WalletCurrencyHistory.fromJson(json["wallet_deposit_details"]),
        flutterWaveBankDetails: json["flutterwave_bank_details"] == null ? null : FlutterWaveBankDetails.fromJson(json["flutterwave_bank_details"]),
      );
}

class FlutterWaveBankDetails {
  String? status;
  String? message;
  Meta? meta;

  FlutterWaveBankDetails({
    this.status,
    this.message,
    this.meta,
  });

  factory FlutterWaveBankDetails.fromJson(Map<String, dynamic> json) => FlutterWaveBankDetails(
        status: json["status"],
        message: json["message"],
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
      );
}

class Meta {
  Authorization? authorization;

  Meta({this.authorization});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        authorization: json["authorization"] == null ? null : Authorization.fromJson(json["authorization"]),
      );
}

class Authorization {
  String? transferReference;
  String? transferAccount;
  String? transferBank;
  String? accountExpiration;
  String? transferNote;
  String? transferAmount;
  String? mode;

  Authorization({
    this.transferReference,
    this.transferAccount,
    this.transferBank,
    this.accountExpiration,
    this.transferNote,
    this.transferAmount,
    this.mode,
  });

  factory Authorization.fromJson(Map<String, dynamic> json) => Authorization(
        transferReference: json["transfer_reference"],
        transferAccount: json["transfer_account"],
        transferBank: json["transfer_bank"],
        accountExpiration: json["account_expiration"] is String? ? json["account_expiration"] : null,
        transferNote: json["transfer_note"],
        transferAmount: json["transfer_amount"],
        mode: json["mode"],
      );
}

class FlutterWaveAddBankData {
  List<FlutterWaveBank>? bankList;
  Map<String, String>? countryList;

  FlutterWaveAddBankData({this.bankList, this.countryList});

  factory FlutterWaveAddBankData.fromJson(Map<String, dynamic> json) => FlutterWaveAddBankData(
        bankList: json["bank_list"] == null ? null : List<FlutterWaveBank>.from(json["bank_list"].map((x) => FlutterWaveBank.fromJson(x))),
        countryList: json["country_list"] == null ? null : Map.from(json["country_list"]).map((k, v) => MapEntry<String, String>(k, v)),
      );
}

class FlutterWaveBank {
  int? id;
  String? code;
  String? name;

  FlutterWaveBank({this.id, this.code, this.name});

  factory FlutterWaveBank.fromJson(Map<String, dynamic> json) => FlutterWaveBank(
        id: json["id"],
        code: json["code"],
        name: json["name"],
      );
}
