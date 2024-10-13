import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import 'p2p_orders_controller.dart';
import 'p2p_orders_widgets.dart';

class P2POrdersScreen extends StatefulWidget {
  const P2POrdersScreen({Key? key}) : super(key: key);

  @override
  State<P2POrdersScreen> createState() => _P2POrdersScreenState();
}

class _P2POrdersScreenState extends State<P2POrdersScreen> {
  final _controller = Get.put(P2POrdersController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getOrderSettings(() => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          vSpacer10(),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tabBarText(["All Orders".tr, "Disputed Orders".tr], _controller.selectedTab.value, (index) {
                      _controller.selectedTab.value = index;
                      _controller.getOrdersData(false);
                    }, selectedColor: Get.theme.colorScheme.secondary),
                    _controller.selectedTab.value == 0
                        ? buttonOnlyIcon(
                            iconData: Icons.filter_alt_outlined,
                            size: Dimens.iconSizeMin,
                            iconColor: Get.theme.primaryColor,
                            visualDensity: minimumVisualDensity,
                            onPressCallback: () => showBottomSheetFullScreen(context, const P2pOrdersFilterView(),
                                title: "Filter Orders".tr, onClose: () => _controller.checkFilterChange(), isScrollControlled: false)
                          )
                        : vSpacer10()
                  ],
                ),
              )),
          vSpacer10(),
          _ordersListView()
        ],
      ),
    );
  }

  _ordersListView() {
    return Obx(() => _controller.ordersList.isEmpty
        ? handleEmptyViewWithLoading(_controller.isLoading.value)
        : Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _controller.ordersList.length,
              itemBuilder: (BuildContext context, int index) {
                if (_controller.hasMoreData && index == (_controller.ordersList.length - 1)) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getOrdersData(true));
                }
                return P2pOrderItemView(_controller.ordersList[index], isDisputeList: _controller.selectedTab.value == 1);
              },
            ),
          ));
  }
}


