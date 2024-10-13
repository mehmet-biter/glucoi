import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../p2p_order_details/chat_card.dart';
import 'p2p_gift_order_details_controller.dart';

//ignore: must_be_immutable
class P2pGiftOrderChatPage extends StatelessWidget {
  P2pGiftOrderChatPage({Key? key}) : super(key: key);
  final _controller = Get.find<P2pGiftOrderDetailsController>();
  final chatEditController = TextEditingController();
  Rx<File> chatFile = File("").obs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _messageList(),
          Obx(() => chatFile.value.path.isEmpty
              ? vSpacer0()
              : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  hSpacer10(),
                  textAutoSizeKarla("${"Attachment".tr} : ", fontSize: Dimens.regularFontSizeMin),
                  Expanded(child: textAutoSizePoppins(chatFile.value.absolute.name)),
                  hSpacer5(),
                  buttonOnlyIcon(
                      iconData: Icons.cancel_outlined,
                      size: Dimens.iconSizeMin,
                      iconColor: Get.theme.primaryColor,
                      visualDensity: minimumVisualDensity,
                      onPressCallback: () => chatFile.value = File("")),
                  hSpacer10()
                ])),
          Row(
            children: [
              hSpacer10(),
              Expanded(
                  child: textFieldWithWidget(
                      controller: chatEditController,
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
        ],
      ),
    );
  }

  _messageList() {
    return Obx(() {
      return Expanded(
          child: _controller.messageList.isEmpty
              ? handleEmptyViewWithLoading(false, message: "Your messages will appear here".tr)
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
          chatFile.value = chooseFile;
        } else {
          saveFileOnTempPath(chooseFile, onNewFile: (newFile) => chatFile.value = newFile);
        }
      } else {
        showToast("Image not found".tr);
      }
    });
  }

  void _sendChatMessage(BuildContext context) {
    var message = chatEditController.text.trim();
    if (message.isEmpty && chatFile.value.path.isEmpty) {
      showToast("Message can not be empty".tr, context: context);
      return;
    }
    _controller.p2pGiftCardSendMessage(message, chatFile.value, () {
      chatEditController.text = "";
      chatFile.value = File("");
    });
  }
}
