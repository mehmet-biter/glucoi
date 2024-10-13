import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'banks/bank_screen.dart';
import 'kyc_verification/kyc_controller.dart';
import 'kyc_verification/kyc_screen.dart';
import 'my_profile_controller.dart';
import 'my_profile_edit_screen.dart';
import 'profile_details_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, this.viewType}) : super(key: key);
  final int? viewType;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = Get.put(MyProfileController());

  @override
  void initState() {
    Get.put(KycController());
    if (widget.viewType != null) _controller.selectedType.value = widget.viewType!;
    super.initState();
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
                appBarBackWithActions(title: "Profile".tr),
                Obx(() => Expanded(
                      child: Column(
                        children: [
                          dropDownListIndex(_controller.getProfileMenus(), _controller.selectedType.value, "All type".tr,
                              (value) => _controller.selectedType.value = value),
                          _buildBody()
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildBody() {
    if (_controller.selectedType.value == 0) {
      return const ProfileDetailsView();
    } else if (_controller.selectedType.value == 1) {
      return const ProfileEditScreen();
    } else if (_controller.selectedType.value == 2) {
      return const KYCScreen();
    } else if (_controller.selectedType.value == 3) {
      return const BankScreen();
    }  else {
      return Container();
    }
  }

// Widget _buildBody() {
//   if (_controller.selectedType.value == 0) {
//     return _profileView(gUserRx.value);
//   } else if (_controller.selectedType.value == 1) {
//     return const ProfileEditScreen();
//   } else if (_controller.selectedType.value == 2) {
//     return const SendSMSScreen();
//   } else if (_controller.selectedType.value == 3) {
//     return const SecurityScreen();
//   } else if (_controller.selectedType.value == 4) {
//     return const KYCScreen();
//   } else if (_controller.selectedType.value == 5) {
//     return const BankScreen();
//   } else {
//     return Container();
//   }
// }
}
