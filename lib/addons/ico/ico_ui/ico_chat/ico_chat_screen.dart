import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_dashboard.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_chat_card.dart';
import 'ico_chat_controller.dart';

class ICOChatScreen extends StatefulWidget {
  const ICOChatScreen({super.key, this.token});

  final IcoToken? token;

  @override
  State<ICOChatScreen> createState() => _ICOChatScreenState();
}

class _ICOChatScreenState extends State<ICOChatScreen> {
  final _controller = Get.put(IcoChatController());

  @override
  void initState() {
    _controller.selectedAdmin.value = -1;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getIcoChatDetails(widget.token));
  }
  @override
  void dispose() {
    _controller.manageChatChannel(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: "Chat".tr),
                    Obx(() {
                      final list = _controller.adminList.map((data) => data.name ?? "").toList();
                      return dropDownListIndex(list, _controller.selectedAdmin.value, "Select Admin".tr, (index) {
                        _controller.selectedAdmin.value = index;
                        _controller.getIcoChatList(widget.token);
                      });
                    }),
                    _messageList(),
                    _sendView()
                  ],
                ))),
      ),
    );
  }

  _sendView() {
    return Column(children: [
      Obx(() => _controller.chatFile.value.path.isEmpty
          ? vSpacer0()
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              hSpacer10(),
              textAutoSizeKarla("${"Attachment".tr} : ", fontSize: Dimens.regularFontSizeMin),
              Expanded(child: textAutoSizePoppins(_controller.chatFile.value.absolute.name)),
              hSpacer5(),
              buttonOnlyIcon(
                  iconData: Icons.cancel_outlined,
                  size: Dimens.iconSizeMin,
                  iconColor: Get.theme.primaryColor,
                  visualDensity: minimumVisualDensity,
                  onPressCallback: () => _controller.chatFile.value = File("")),
              hSpacer10()
            ])),
      Row(
        children: [
          hSpacer10(),
          Expanded(
              child: textFieldWithWidget(
                  controller: _controller.chatEditController,
                  hint: "Write Message".tr,
                  suffixWidget: buttonOnlyIcon(
                      iconData: Icons.image_outlined, iconColor: Get.theme.primaryColor, onPressCallback: () => _selectImage(context)))),
          hSpacer10(),
          SizedBox(
              height: Dimens.btnHeightMain,
              child: buttonText("Send".tr, textColor: Get.theme.scaffoldBackgroundColor, onPressCallback: () => _sendChatMessage(context))),
          hSpacer10()
        ],
      ),
      vSpacer10()
    ]);
  }

  _messageList() {
    return Obx(() {
      return Expanded(
          child: _controller.messageList.isEmpty
              ? handleEmptyViewWithLoading(_controller.isDataLoading.value, message: "Your messages will appear here".tr)
              : ListView.builder(
                  padding: const EdgeInsets.all(Dimens.paddingMid),
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  itemCount: _controller.messageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ChatCard(message: _controller.messageList[index], selfUserId: gUserRx.value.id);
                  },
                ));
    });
  }

  void _selectImage(BuildContext context) {
    showImageChooser(context, (chooseFile, isGallery) async {
      if (chooseFile.path.isNotEmpty) {
        if (isGallery) {
          _controller.chatFile.value = chooseFile;
        } else {
          saveFileOnTempPath(chooseFile, onNewFile: (newFile) => _controller.chatFile.value = newFile);
        }
      } else {
        showToast("Image not found".tr);
      }
    });
  }

  void _sendChatMessage(BuildContext context) {
    var message = _controller.chatEditController.text.trim();
    if (message.isEmpty && _controller.chatFile.value.path.isEmpty) {
      showToast("Message can not be empty".tr, context: context);
      return;
    }
    _controller.sendChatMessage(widget.token, message, _controller.chatFile.value, () {
      _controller.chatEditController.text = "";
      _controller.chatFile.value = File("");
    });
  }
}
