import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'colors.dart';
import 'decorations.dart';
import 'image_util.dart';

Widget showEmptyView({String? message, double height = 20}) {
  message = message ?? "No data available".tr;
  return SizedBox(width: Get.width, height: height, child: Center(child: textAutoSizePoppins(message)));
}

Widget handleEmptyViewWithLoading(bool isLoading, {double height = 50, String? message}) {
  message = message ?? "No data available".tr;
  return Container(
    margin: const EdgeInsets.all(20),
    height: height,
    child: Center(child: isLoading ? CircularProgressIndicator(color: Get.theme.colorScheme.secondary) : textAutoSizePoppins(message, maxLines: 3)),
  );
}

Widget showLoading({double padding = 20}) {
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.secondary)),
  );
}

Widget showLoadingSmall() {
  return Padding(
    padding: const EdgeInsets.all(5),
    child: Center(
        child: SizedBox(
            width: Dimens.btnHeightMin, height: Dimens.btnHeightMin, child: CircularProgressIndicator(color: Get.theme.colorScheme.secondary))),
  );
}

Widget dropDownListMain(List<String> items, String selectedValue, String hint, Function(String value) onChange,
    {Color? bgColor,
    Color? borderColor,
    double? height,
    double? padding,
    double? hintFontSize,
    double hMargin = 10,
    bool? caretFilled = false,
    bool? borderCurve = true}) {
  bgColor = bgColor ?? Get.theme.colorScheme.background;
  borderColor = borderColor ?? Get.theme.dividerColor;
  padding = padding ?? Dimens.paddingMid;
  height = height ?? Dimens.btnHeightMain;

  return Container(
    margin: EdgeInsets.only(left: hMargin, top: 5, right: hMargin, bottom: 5),
    padding: EdgeInsets.only(left: padding, top: 0, right: padding, bottom: 0),
    height: height,
    width: Get.width,
    decoration: borderCurve == true
        ? boxDecorationRoundBorder(color: bgColor, borderColor: borderColor, radius: Dimens.radiusCornerMid)
        : boxDecorationRoundBorder(color: bgColor, borderColor: borderColor, radius: Dimens.radiusCorner),
    child: DropdownButton<String>(
      isExpanded: true,
      value: selectedValue.isEmpty ? null : selectedValue,
      hint: textAutoSizePoppins(hint, color: Get.theme.primaryColor),
      icon: Align(
          alignment: Alignment.centerRight,
          child: caretFilled == false
              ? const Icon(Icons.keyboard_arrow_down_sharp, color: cSonicSilver, size: 24)
              : const Icon(Icons.arrow_drop_down, color: cSonicSilver, size: 18)),
      elevation: 10,
      dropdownColor: Get.theme.dividerColor,
      underline: Container(height: 0, color: Colors.transparent),
      menuMaxHeight: Get.width,
      onChanged: (value) => onChange(value!),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: textAutoSizePoppins(value, color: Get.theme.primaryColor, fontWeight: FontWeight.bold),
        );
      }).toList(),
    ),
  );
}

Widget dropDownListIndex(List<String> items, int selectedValue, String hint, Function(int index) onChange,
    {Color? bgColor,
    Color? borderColor,
    double? height,
    double? width,
    double? padding,
    double? hintFontSize,
    double? fontSize,
    double hMargin = 10,
    double vMargin = 5,
    bool isBordered = true,
    bool isEditable = true,
    bool isExpanded = true}) {
  bgColor = bgColor ?? Get.theme.colorScheme.background;
  borderColor = borderColor ?? Get.theme.dividerColor;
  padding = padding ?? Dimens.paddingMid;
  height = height ?? Dimens.btnHeightMain;

  return Container(
    margin: EdgeInsets.only(left: hMargin, top: vMargin, right: hMargin, bottom: vMargin),
    padding: EdgeInsets.only(left: padding, top: 0, right: padding, bottom: 0),
    height: height,
    width: width,
    decoration: isBordered ? boxDecorationRoundBorder(color: bgColor, borderColor: borderColor, radius: Dimens.radiusCorner) : null,
    alignment: Alignment.center,
    child: DropdownButton<String>(
      isExpanded: isExpanded,
      value: items.hasIndex(selectedValue) ? items[selectedValue] : null,
      hint: Text(hint, style: Get.textTheme.bodyMedium),
      icon: Icon(Icons.keyboard_arrow_down_outlined, color: isEditable ? Get.theme.primaryColor : Colors.transparent),
      elevation: 10,
      dropdownColor: gIsDarkMode ? Get.theme.colorScheme.background : Get.theme.dividerColor,
      underline: Container(height: 0, color: Colors.transparent),
      menuMaxHeight: Get.width,
      onChanged: isEditable ? (value) => onChange(items.indexOf(value!)) : null,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: textAutoSizePoppins(value,
              color: Get.theme.primaryColor, fontWeight: FontWeight.bold, maxLines: 2, fontSize: fontSize, textAlign: TextAlign.start),
        );
      }).toList(),
    ),
  );
}

class DropdownWithSearch extends StatelessWidget {
  const DropdownWithSearch(
      {super.key, required this.items, this.selectedItem, required this.onSelect, this.showSearchBox, this.hint, this.isEditable = true});

  final List<String> items;
  final String? selectedItem;
  final Function(String) onSelect;
  final bool? showSearchBox;
  final String? hint;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
        items: items,
        dropdownBuilder: (context, selectedItem) {
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: selectedItem.isValid
                ? textAutoSizePoppins(selectedItem!,
                    color: context.theme.primaryColor, fontWeight: FontWeight.bold, maxLines: 2, textAlign: TextAlign.start)
                : Text(hint ?? "Select".tr, style: context.textTheme.bodyMedium),
          );
        },
        selectedItem: selectedItem,
        onChanged: (value) => value == null ? {} : onSelect(value),
        popupProps: PopupProps.menu(
          showSelectedItems: true,
          searchDelay: const Duration(milliseconds: 100),
          searchFieldProps: TextFieldProps(
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.all(Dimens.paddingMid),
                hintText: "Search".tr,
                enabledBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
                disabledBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
                focusedBorder: textFieldBorder(borderRadius: Dimens.radiusCorner, isFocus: true),
              )),
          itemBuilder: (context, item, selected) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingMin),
              child: textAutoSizeKarla(item, maxLines: 2, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
            );
          },
          showSearchBox: showSearchBox ?? true,
        ),
        compareFn: (item, sItem) => item == sItem,
        filterFn: (item, filter) {
          filter = filter.trim().toLowerCase();
          if (filter.isEmpty) return true;
          if (item.toLowerCase().contains(filter)) {
            return true;
          } else {
            return false;
          }
        },
        dropdownButtonProps:
            DropdownButtonProps(icon: Icon(Icons.keyboard_arrow_down_outlined, color: isEditable ? Get.theme.primaryColor : Colors.transparent)),
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: context.textTheme.bodyMedium,
          dropdownSearchDecoration: InputDecoration(
            filled: true,
            fillColor: Get.theme.colorScheme.background,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            enabledBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
            disabledBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
            focusedBorder: textFieldBorder(borderRadius: Dimens.radiusCorner),
          ),
        ));
  }
}

Widget qrView(String data, {Color backgroundColor = Colors.transparent}) {
  return QrImageView(
    data: data,
    version: QrVersions.auto,
    backgroundColor: Colors.white,
    size: 150,
  );
}

Widget countryPickerView(BuildContext context, Country selectedCountry, Function(Country) onSelect, {bool? showPhoneCode, bool isEnable = true}) {
  return InkWell(
    onTap: isEnable
        ? () {
            hideKeyboard(context: context);
            showCountryPicker(
                context: context,
                showPhoneCode: showPhoneCode ?? false,
                onSelect: onSelect,
                countryListTheme: CountryListThemeData(
                    backgroundColor: context.theme.colorScheme.background,
                    // textStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.black),
                    searchTextStyle: context.textTheme.bodyMedium,
                    inputDecoration: InputDecoration(
                        filled: false,
                        isDense: true,
                        hintText: "Search".tr,

                        enabledBorder: textFieldBorder(borderRadius: 7),
                        disabledBorder: textFieldBorder(borderRadius: 7),
                        focusedBorder: textFieldBorder(isFocus: true, borderRadius: 7))));
          }
        : null,
    child: Padding(
      padding: const EdgeInsets.only(left: Dimens.paddingMid),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedCountry.flagEmoji, style: const TextStyle(fontSize: Dimens.iconSizeMid)),
          //if (showPhoneCode ?? false) hSpacer5(),
          //if (showPhoneCode ?? false) Text(selectedCountry.phoneCode, style: Get.theme.textTheme.bodyMedium),
          Icon(Icons.arrow_drop_down, size: Dimens.iconSizeMid, color: context.theme.primaryColor),
          hSpacer5()
        ],
      ),
    ),
  );
}

Widget pinCodeView({TextEditingController? controller}) {
  final size = (Get.width - 100) / 6;
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  return Container(
    margin: const EdgeInsets.all(Dimens.paddingMid),
    child: PinCodeTextField(
      length: DefaultValue.codeLength,
      obscureText: false,
      animationType: AnimationType.slide,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(4),
        borderWidth: 0.5,
        fieldHeight: size,
        fieldWidth: size,
        activeColor: Get.theme.focusColor,
        activeFillColor: Colors.transparent,
        inactiveColor: Get.theme.primaryColorLight,
        inactiveFillColor: Colors.transparent,
        selectedColor: Get.theme.focusColor,
        selectedFillColor: Colors.transparent,
        errorBorderColor: Get.theme.colorScheme.error,
      ),
      cursorColor: Get.theme.focusColor,
      animationDuration: const Duration(milliseconds: 100),
      backgroundColor: Colors.transparent,
      enableActiveFill: true,
      hintCharacter: "#",
      textStyle: Get.textTheme.bodyLarge,
      errorAnimationController: errorController,
      controller: controller,
      onCompleted: (value) {},
      onChanged: (value) {},
      beforeTextPaste: (text) => false,
      appContext: Get.context!,
    ),
  );
}

Widget toggleSwitch(
    {bool? selectedValue,
    Function(bool)? onChange,
    double height = 30,
    String activeText = "",
    String inactiveText = "",
    String text = "",
    TextStyle? textStyle,
    MainAxisAlignment? mainAxisAlignment}) {
  return Row(
    mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
    children: [
      if (text.isNotEmpty) Text(text, style: textStyle ?? Get.textTheme.labelSmall),
      const SizedBox(width: 5),
      FlutterSwitch(
        width: activeText.isValid ? 80 : height * 2,
        height: height,
        valueFontSize: height / 2,
        toggleSize: height - 10,
        value: selectedValue ?? false,
        toggleColor: Get.theme.primaryColor,
        activeToggleColor: Get.theme.colorScheme.secondary,
        activeColor: Get.theme.primaryColorLight.withOpacity(0.25),
        inactiveColor: Get.theme.primaryColorLight.withOpacity(0.25),
        borderRadius: height / 2,
        activeTextColor: Get.theme.primaryColorDark,
        inactiveTextColor: Get.theme.primaryColor,
        switchBorder: Border.all(width: 2, color: Get.theme.primaryColor),
        padding: 3,
        showOnOff: true,
        activeText: activeText,
        inactiveText: inactiveText,
        onToggle: (val) {
          if (onChange != null) onChange(val);
        },
      ),
    ],
  );
}

Widget popupMenu(List<String> list, {Widget? child, Function(String)? onSelected}) {
  return PopupMenuButton<String>(
    onSelected: onSelected,
    itemBuilder: (BuildContext context) => List.generate(
      list.length,
      (index) => PopupMenuItem<String>(
          value: list[index],
          height: 35,
          child: Text(list[index], style: Get.theme.textTheme.titleSmall!.copyWith(fontSize: Dimens.regularFontSizeMid))),
    ),
    child: child,
  );
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size, this.radius});

  final double? size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final sizeL = size ?? context.width / 4;
    // final logo = gIsDarkMode ? AssetConstants.icLogo : AssetConstants.icLogoBlack;
    return Center(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? Dimens.radiusCorner),
          child: showImageAsset(imagePath: AssetConstants.icLogo, height: sizeL, width: sizeL)),
    );
  }
}

PopupMenuItem<int> makePopupMenu(String title, int value) =>
    PopupMenuItem(height: 40, value: value, child: Text(title, style: Get.theme.textTheme.titleSmall!.copyWith(fontSize: Dimens.regularFontSizeMid)));
