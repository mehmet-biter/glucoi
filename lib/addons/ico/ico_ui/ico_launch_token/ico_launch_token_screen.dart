import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_constants.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_dynamic_form.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_launch_token_controller.dart';

class IcoLaunchTokenScreen extends StatefulWidget {
  const IcoLaunchTokenScreen({super.key});

  @override
  State<IcoLaunchTokenScreen> createState() => _IcoLaunchTokenScreenState();
}

class _IcoLaunchTokenScreenState extends State<IcoLaunchTokenScreen> {
  final _controller = Get.put(IcoLaunchTokenController());
  RxInt errorID = 0.obs;

  @override
  void initState() {
    errorID.value = -1;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getIcoDynamicForm());
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
                    appBarBackWithActions(title: "Apply To Launch Token".tr, fontSize: Dimens.regularFontSizeMid),
                    Obx(() {
                      final dyData = _controller.dynamicFormData.value;
                      return _controller.isLoading.value
                          ? showLoading()
                          : Expanded(
                              child: ListView(
                                padding: const EdgeInsets.all(Dimens.paddingMid),
                                children: [
                                  textAutoSizeKarla(dyData.dynamicFormForIcoTitle ?? "",
                                      fontSize: Dimens.regularFontSizeLarge, maxLines: 5, textAlign: TextAlign.start),
                                  vSpacer5(),
                                  textAutoSizePoppins(dyData.dynamicFormForIcoDescription ?? "", maxLines: 20, textAlign: TextAlign.start),
                                  vSpacer10(),
                                  dyData.dynamicForm.isValid
                                      ? Column(
                                          children: List.generate(
                                              dyData.dynamicForm!.length, (index) => DynamicItemView(formIndex: index, errorId: errorID.value)))
                                      : showEmptyView(),
                                  buttonRoundedMain(text: "Apply Now".tr, onPressCallback: () => _checkAndCreateToken(context))
                                ],
                              ),
                            );
                    })
                  ],
                ))),
      ),
    );
  }

  void _checkAndCreateToken(BuildContext context) async {
    final dyList = _controller.dynamicFormData.value.dynamicForm;
    final mapObj = <String, dynamic>{};
    errorID.value = -1;
    if (dyList.isValid) {
      for (int i = 0; i < dyList!.length; i++) {
        final form = dyList[i];
        if (form.required == 1) {
          if ([DynamicFormType.inputText, DynamicFormType.textArea].contains(form.type)) {
            final text = form.value as String? ?? "";
            if (text.isEmpty) errorID.value = form.id ?? -1;
          } else if ([DynamicFormType.radio, DynamicFormType.dropdown, DynamicFormType.file].contains(form.type)) {
            if (form.value == null) errorID.value = form.id ?? -1;
          } else if (form.type == DynamicFormType.checkbox) {
            final list = form.value as List<String>? ?? [];
            if (list.isEmpty) errorID.value = form.id ?? -1;
          }
        }
        if (errorID.value == -1) {
          mapObj["ids[$i]"] = form.id;
          await _addValueInMap(mapObj, i, form);
        } else {
          showToast("Missing a required field".tr);
          return;
        }
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => hideKeyboard(context: context));
    _controller.icoDynamicFormSubmit(mapObj);
  }

  Future<void> _addValueInMap(Map<String, dynamic> mapObj, int i, DynamicForm form) async {
    if (form.type == DynamicFormType.file) {
      mapObj["values[$i]"] = form.value == null ? "" : await APIRepository().makeMultipartFile(form.value!);
    } else if (form.type == DynamicFormType.checkbox) {
      final list = form.value as List<String>? ?? [];
      mapObj["values[$i]"] = list.join(",");
    } else {
      mapObj["values[$i]"] = form.value ?? "";
    }
  }
}

class DynamicItemView extends StatelessWidget {
  DynamicItemView({super.key, required this.formIndex, required this.errorId});

  final int formIndex;
  final int errorId;
  final _controller = Get.find<IcoLaunchTokenController>();

  @override
  Widget build(BuildContext context) {
    final form = _controller.dynamicFormData.value.dynamicForm![formIndex];
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textAutoSizeKarla(form.title ?? "", fontSize: Dimens.regularFontSizeMid, maxLines: 5, textAlign: TextAlign.start),
          if (form.type == DynamicFormType.inputText)
            Column(
              children: [
                vSpacer5(),
                textFieldWithSuffixIcon(
                    controller: TextEditingController(text: form.value ?? ""),
                    onTextChange: (text) {
                      _controller.dynamicFormData.value.dynamicForm![formIndex].value = text;
                    }),
              ],
            )
          else if (form.type == DynamicFormType.dropdown)
            dropDownListIndex(form.optionList ?? [], form.value ?? -1, "Select".tr, hMargin: 0, (index) {
              _controller.dynamicFormData.value.dynamicForm![formIndex].value = index;
              _controller.dynamicFormData.refresh();
            })
          else if (form.type == DynamicFormType.radio)
            Wrap(
                spacing: Dimens.paddingMid,
                runSpacing: Dimens.paddingMid,
                children: List.generate(form.optionList?.length ?? 0, (index) => _radioItemView(form.optionList![index], form.value)))
          else if (form.type == DynamicFormType.checkbox)
            Wrap(
                spacing: Dimens.paddingMid,
                runSpacing: Dimens.paddingMid,
                children: List.generate(form.optionList?.length ?? 0, (index) => _checkItemView(form.optionList![index], form.value ?? [])))
          else if (form.type == DynamicFormType.textArea)
            Column(
              children: [
                vSpacer5(),
                textFieldWithSuffixIcon(
                    maxLines: 5,
                    height: 120,
                    controller: TextEditingController(text: form.value ?? ""),
                    onTextChange: (text) {
                      _controller.dynamicFormData.value.dynamicForm![formIndex].value = text;
                    }),
              ],
            )
          else if (form.type == DynamicFormType.file)
            _documentView(context, form.value, form.fileType),
          if (errorId == form.id) vSpacer2(),
          if (errorId == form.id) textAutoSizePoppins("This field is required".tr, color: context.theme.focusColor)
        ],
      ),
    );
  }

  _radioItemView(String item, String? value) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          Radio(
              value: item,
              groupValue: value,
              visualDensity: minimumVisualDensity,
              onChanged: (v) {
                _controller.dynamicFormData.value.dynamicForm![formIndex].value = v;
                _controller.dynamicFormData.refresh();
              }),
          textAutoSizeKarla(item, fontSize: Dimens.regularFontSizeMid),
          hSpacer10()
        ],
      ),
    );
  }

  _checkItemView(String item, List<String> values) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          Checkbox(
              value: values.contains(item),
              visualDensity: minimumVisualDensity,
              onChanged: (v) {
                v == true ? values.add(item) : values.remove(item);
                _controller.dynamicFormData.value.dynamicForm![formIndex].value = values;
                _controller.dynamicFormData.refresh();
              }),
          textAutoSizeKarla(item, fontSize: Dimens.regularFontSizeMid),
          hSpacer10()
        ],
      ),
    );
  }

  _documentView(BuildContext context, File? file, String? fileType) {
    final text = (file != null && file.path.isEmpty) ? "No image selected".tr : file.name;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(width: 150, child: buttonText("Select image".tr, onPressCallback: () => pickFile(fileType))),
      Expanded(child: textAutoSizePoppins(text, maxLines: 2))
    ]);
  }

  void pickFile(String? fileType) async {
    final ext = fileType == "pdf_word" ? ['pdf', 'doc'] : ['jpg', 'png'];
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ext);
    if (result != null) {
      File file = File(result.files.single.path ?? "");
      _controller.dynamicFormData.value.dynamicForm![formIndex].value = file;
      _controller.dynamicFormData.refresh();
    } else {
      showToast("File not found".tr, isError: true);
    }
  }
}
