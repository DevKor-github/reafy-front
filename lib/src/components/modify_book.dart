import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reafy_front/src/components/image_data.dart';

class ModifyDialog extends StatefulWidget {
  @override
  _ModifyDialogState createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<ModifyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      //title:
      content: Container(
        width: 248,
        height: 210,
        child: Column(children: [
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Dialog를 닫음
                },
                child: ImageData(IconsPath.x, isSvg: true, width: 10),
              ),
              SizedBox(width: 19.0),
            ],
          ),
          SizedBox(height: 28.0),
          Text(
            "책의 상태를 선택해 주세요!",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BookStatusButtonGroup(),
            ],
          ),
          SizedBox(height: 44),
          ElevatedButton(
            onPressed: () {
              //Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xffffd747),
              minimumSize: Size(212, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 0,
            ),
            child: Text(
              '확인',
              style: const TextStyle(
                color: Color(0xff000000),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ]),
      ),
      actions: <Widget>[],
    );
  }
}

/////

class BookStatusButtonGroup extends StatefulWidget {
  @override
  _BookStatusButtonGroupState createState() => _BookStatusButtonGroupState();
}

class _BookStatusButtonGroupState extends State<BookStatusButtonGroup> {
  int selectedButtonIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 208,
          height: 28,
          decoration: BoxDecoration(
              color: Color(0xfffff7da),
              borderRadius: BorderRadius.circular(100)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BookStatusButton(
              status: '읽은 책',
              isSelected: selectedButtonIndex == 0,
              onPressed: () {
                setState(() {
                  selectedButtonIndex = 0;
                });
              },
            ),
            BookStatusButton(
              status: '읽는 중',
              isSelected: selectedButtonIndex == 1,
              onPressed: () {
                setState(() {
                  selectedButtonIndex = 1;
                });
              },
            ),
            BookStatusButton(
              status: '읽을 책',
              isSelected: selectedButtonIndex == 2,
              onPressed: () {
                setState(() {
                  selectedButtonIndex = 2;
                });
              },
            ),
          ],
        )
      ],
    );
  }
}

class BookStatusButton extends StatelessWidget {
  final String status;
  final bool isSelected;
  final VoidCallback onPressed;

  const BookStatusButton({
    required this.status,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        width: 71,
        height: 28,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: isSelected ? Color(0xffFFECA6) : Color(0xFFFFF7DA),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: BorderSide(
                color: isSelected ? Color(0xFFffd747) : Colors.transparent,
                width: 1.0,
              ),
            ),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      )
    ]);
  }
}