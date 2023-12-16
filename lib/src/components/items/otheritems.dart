import 'package:flutter/material.dart';
import 'package:reafy_front/src/components/image_data.dart';
import 'package:provider/provider.dart';
import 'package:reafy_front/src/components/purchase_dialog.dart';
import 'package:reafy_front/src/provider/item_provider.dart';
import 'package:reafy_front/src/provider/item_placement_provider.dart';

class ItemData {
  final int itemId;
  final String imagePath;
  final String text;

  ItemData({required this.itemId, required this.imagePath, required this.text});
}

List<ItemData> itemDataList = [
  //others 40~59
  ItemData(itemId: 40, imagePath: 'assets/images/nothing.png', text: '선택 안함'),
  ItemData(
      itemId: 41,
      imagePath: 'assets/images/items/item_flower.png',
      text: '꽃 의자'),
  ItemData(
      itemId: 42,
      imagePath: 'assets/images/items/item_mushroom.png',
      text: '버섯 테이블'),
  ItemData(
      itemId: 43, imagePath: 'assets/images/items/item_bear.png', text: '곰 인형'),
  ItemData(
      itemId: 44, imagePath: 'assets/images/items/item_tree.png', text: '트리'),
  ItemData(
      itemId: 45,
      imagePath: 'assets/images/items/item_light.png',
      text: '달빛 전구'),
  ItemData(
      itemId: 46,
      imagePath: 'assets/images/items/item_bamboo.png',
      text: '선인장 화분'),
];

class ItemOthers extends StatefulWidget {
  @override
  _ItemOthersState createState() => _ItemOthersState();
}

class _ItemOthersState extends State<ItemOthers> {
  int selectedGridIndex = 0;
  String selectedImagePath = '';

  @override
  void initState() {
    super.initState();

    // 이전에 선택한 값으로 초기화
    selectedGridIndex =
        Provider.of<ItemPlacementProvider>(context, listen: false)
            .getSelectedOthersIndex();
  }

  @override
  Widget build(BuildContext context) {
    final itemPlacementProvider =
        Provider.of<ItemPlacementProvider>(context, listen: false);

    return Container(
      child: SingleChildScrollView(
        //physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 400,
          padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, //그리드 열 수
              crossAxisSpacing: 14.0, //가로 간격
              mainAxisSpacing: 16.0, // 세로 간격
              childAspectRatio: 0.8,
            ),
            itemCount: itemDataList.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedGridIndex == index;
              ItemData itemIndex = itemDataList[index];
              bool isButtonEnabled = Provider.of<ItemProvider>(context)
                      .ownedItemIds
                      .contains(itemIndex.itemId) ||
                  index == 0;

              return InkWell(
                onTap: () {
                  setState(() {
                    selectedGridIndex = index;
                    selectedImagePath = itemIndex.imagePath;
                    if (isButtonEnabled) {
                      itemPlacementProvider.updateSelectedOthersIndex(index);
                      itemPlacementProvider
                          .updateOthersImagePath(itemIndex.imagePath);
                    }
                  });
                  if (!isButtonEnabled) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PurchaseDialog(
                          itemId: itemIndex.itemId,
                          itemName: itemIndex.text,
                          itemImagePath: itemIndex.imagePath,
                        );
                      },
                    );
                  }
                },
                child: GridItem(
                  index,
                  itemIndex,
                  isSelected,
                  selectedImagePath,
                  isButtonEnabled: isButtonEnabled,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget GridItem(
  int index,
  ItemData itemIndex,
  bool isSelected,
  String selectedImagePath, {
  required bool isButtonEnabled,
}) {
  return Flexible(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 79,
              height: 79,
              decoration: BoxDecoration(
                  color: isSelected && isButtonEnabled
                      ? Color(0xfffffd747).withOpacity(0.1)
                      : Color(0xffffffff),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 1),
                    ),
                  ],
                  border: isSelected && isButtonEnabled
                      ? Border.all(color: Color(0xffffd747), width: 2)
                      : Border.all(color: Color(0xffffffff), width: 2)),
              child: itemIndex.imagePath.isNotEmpty
                  ? Center(
                      child: Container(
                      width: 60,
                      height: 60,
                      child: ImageData(itemIndex.imagePath),
                    ))
                  : null,
            ),
            if (!isButtonEnabled)
              Container(
                width: 79,
                height: 79,
                decoration: BoxDecoration(
                  color: Color(0xff000000).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ImageData(IconsPath.lock),
              ),
            if (index == 0)
              Container(
                width: 79,
                height: 79,
                child: ImageData(IconsPath.select_nothing),
              ),
          ],
        ),
        SizedBox(height: 6.0),
        Text(
          itemIndex.text,
          style: const TextStyle(
              color: Color(0xff333333),
              fontSize: 12,
              fontWeight: FontWeight.w400),
        ),
      ],
    ),
  );
}
