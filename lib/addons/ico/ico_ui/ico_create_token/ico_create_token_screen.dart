import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_dashboard.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_create_token_controller.dart';

class IcoCreateTokenScreen extends StatefulWidget {
  const IcoCreateTokenScreen({super.key, this.preToken});

  final IcoToken? preToken;

  @override
  State<IcoCreateTokenScreen> createState() => _IcoCreateTokenScreenState();
}

class _IcoCreateTokenScreenState extends State<IcoCreateTokenScreen> {
  final _controller = Get.put(IcoCreateTokenController());
  final _focusLink = FocusNode();
  final _focusContract = FocusNode();
  final linkEditController = TextEditingController();
  final contractEditController = TextEditingController();
  final decimalEditController = TextEditingController();
  final walletEditController = TextEditingController();
  final privateEditController = TextEditingController();
  final gasEditController = TextEditingController();
  final websiteEditController = TextEditingController();
  final rulesEditController = TextEditingController();

  @override
  void initState() {
    _setPreData();
    super.initState();
    _focusLink.addListener(_onFocusChange);
    _focusContract.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
    _focusLink.dispose();
    _focusContract.dispose();
  }

  void _setPreData() {
    if (widget.preToken != null) {
      final index = _controller.networkList.indexWhere((element) => element.id == widget.preToken?.id);
      if (index != -1) _controller.selectedNetwork.value = index;
      linkEditController.text = widget.preToken?.chainLink ?? "";
      contractEditController.text = widget.preToken?.contractAddress ?? "";
      decimalEditController.text = (widget.preToken?.decimal ?? "").toString();
      walletEditController.text = widget.preToken?.walletAddress ?? "";
      privateEditController.text = widget.preToken?.walletPrivateKey ?? "";
      gasEditController.text = (widget.preToken?.gasLimit ?? "").toString();
      websiteEditController.text = widget.preToken?.websiteLink ?? "";
      rulesEditController.text = widget.preToken?.detailsRule ?? "";
    } else {
      _controller.selectedNetwork.value = -1;
    }
  }

  void _onFocusChange() {
    if (!_focusLink.hasFocus && !_focusContract.hasFocus) {
      final link = linkEditController.text.trim();
      final address = contractEditController.text.trim();
      if (link.isNotEmpty && address.isNotEmpty) {
        _controller.icoGetContractAddressDetails(link, address);
      } else {
        _controller.contractError.value = "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.preToken == null ? "Add New ICO Token".tr : "Edit ICO Token".tr;
    final btnTitle = widget.preToken == null ? "Create Token".tr : "Edit Token".tr;

    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: title, fontSize: Dimens.regularFontSizeMid),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(Dimens.paddingMid),
                        children: [
                          vSpacer5(),
                          textAutoSizeKarla("Token Type".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                          Obx(() {
                            final list = _controller.networkList.map((e) => e.networkName ?? "").toList();
                            return dropDownListIndex(
                                list, _controller.selectedNetwork.value, "Select".tr, (index) => _controller.selectedNetwork.value = index,
                                hMargin: 0);
                          }),
                          vSpacer5(),
                          Obx(() {
                            final subText = _controller.selectedNetwork.value == -1
                                ? "N/A".tr
                                : _controller.networkList[_controller.selectedNetwork.value].networkType;
                            return twoTextSpaceFixed("Base Coin".tr, subText ?? "");
                          }),
                          dividerHorizontal(),
                          vSpacer10(),
                          textFieldWithSuffixIcon(
                              controller: linkEditController, hint: "Enter RPC Url".tr, labelText: "Network Link".tr, focusNode: _focusLink),
                          vSpacer10(),
                          textFieldWithSuffixIcon(
                              controller: contractEditController,
                              hint: "Enter contract address".tr,
                              labelText: "Contract Address".tr,
                              focusNode: _focusContract),
                          Obx(() {
                            final contract = _controller.contract.value;
                            if (contract.chainId.isValid) {
                              return Column(
                                children: [
                                  vSpacer10(),
                                  twoTextSpaceFixed("Token Symbol".tr, contract.symbol ?? ""),
                                  twoTextSpaceFixed("Token Name".tr, contract.name ?? ""),
                                  twoTextSpaceFixed("Chain Id".tr, contract.chainId ?? ""),
                                ],
                              );
                            } else {
                              return _controller.contractError.value.isValid
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        vSpacer2(),
                                        textAutoSizePoppins(_controller.contractError.value,
                                            maxLines: 3, color: Colors.amber, textAlign: TextAlign.start),
                                        vSpacer5()
                                      ],
                                    )
                                  : vSpacer0();
                            }
                          }),
                          vSpacer10(),
                          textFieldWithSuffixIcon(
                              controller: decimalEditController, hint: "Enter decimal".tr, type: TextInputType.number, labelText: "Decimal".tr),
                          vSpacer10(),
                          textFieldWithSuffixIcon(controller: walletEditController, hint: "Enter wallet address".tr, labelText: "Wallet Address".tr),
                          vSpacer10(),
                          textFieldWithSuffixIcon(
                              controller: privateEditController, hint: "Enter private key".tr, labelText: "Wallet Private Key".tr, isObscure: true),
                          vSpacer10(),
                          textFieldWithSuffixIcon(
                              controller: gasEditController,
                              hint: "Enter gas limit".tr,
                              labelText: "Gas Limit".tr,
                              type: const TextInputType.numberWithOptions(decimal: true)),
                          vSpacer10(),
                          textFieldWithSuffixIcon(controller: websiteEditController, hint: "Enter website Link".tr, labelText: "Website Link".tr),
                          vSpacer10(),
                          textFieldWithSuffixIcon(
                              controller: rulesEditController,
                              hint: "Enter your rules".tr,
                              labelText: "Details Rules".tr,
                              maxLines: 3,
                              height: MediaQuery.of(context).textScaleFactor > 1 ? 100 : 80),
                          vSpacer10(),
                          if (widget.preToken?.imagePath.isValid ?? false)
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              textAutoSizeKarla("Selected Image".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                              showImageNetwork(imagePath: widget.preToken?.imagePath, height: Dimens.iconSizeLogo, width: Dimens.iconSizeLogo)
                            ]),
                          _documentView(),
                          vSpacer10(),
                          buttonRoundedMain(text: btnTitle, onPressCallback: () => _checkAndCreateToken()),
                          vSpacer10(),
                        ],
                      ),
                    )
                  ],
                ))),
      ),
    );
  }

  _documentView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: 150,
            child: buttonText("Select image".tr, onPressCallback: () {
              showImageChooser(context, (chooseFile, isGallery) => _controller.selectedFile.value = chooseFile, isCrop: false);
            })),
        Obx(() {
          final text = _controller.selectedFile.value.path.isEmpty ? "No image selected".tr : _controller.selectedFile.value.name;
          return Expanded(child: textAutoSizePoppins(text, maxLines: 2));
        })
      ],
    );
  }

  void _checkAndCreateToken() {
    final token = widget.preToken ?? IcoToken();
    if (_controller.selectedNetwork.value == -1) {
      showToast("Select_token_type");
      return;
    }
    final net = _controller.networkList[_controller.selectedNetwork.value];
    token.network = net.id.toString();
    token.baseCoin = net.networkType;

    token.chainLink = linkEditController.text.trim();
    if (!token.chainLink.isValid) {
      showToast("Enter_rpc_link");
      return;
    }
    token.contractAddress = contractEditController.text.trim();
    if (!token.contractAddress.isValid) {
      showToast("Enter_contract_Address");
      return;
    }
    token.walletAddress = walletEditController.text.trim();
    if (!token.walletAddress.isValid) {
      showToast("Enter_wallet_Address");
      return;
    }
    token.walletPrivateKey = privateEditController.text.trim();
    if (!token.walletPrivateKey.isValid) {
      showToast("Enter_wallet_private_key");
      return;
    }
    token.gasLimit = makeDouble(gasEditController.text.trim());
    if (token.gasLimit! <= 0) {
      showToast("gas_limit_must_greater_than_0".tr);
      return;
    }
    final contract = _controller.contract.value;
    if (contract.chainId.isValid) {
      token.chainId = contract.chainId;
      token.tokenName = contract.name;
      token.imageName = contract.symbol;
    }
    token.decimal = makeInt(decimalEditController.text.trim());
    token.formId = gUserRx.value.id;
    token.websiteLink = websiteEditController.text.trim();
    token.detailsRule = rulesEditController.text.trim();
    hideKeyboard(context: context);
    _controller.icoCreateUpdateToken(token, _controller.selectedFile.value);
  }
}
