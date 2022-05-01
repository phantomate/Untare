import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearchValueChange;

  SearchWidget({required this.onSearchValueChange});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final _textController = TextEditingController();
  bool isForward = false;

  void _setSearchQuery() {
    widget.onSearchValueChange(_textController.text);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this
    );

    final curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutExpo);

    _animation = Tween<double>(begin: 0, end: 130).animate(curvedAnimation)
      ..addListener(() {
        setState(() {

        });
      });

    _textController.addListener(_setSearchQuery);
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.5 + _animation.value,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.black54, width: 1.2)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _animation.value,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(50))
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: TextField(
                controller: _textController,
                cursorColor: Colors.black54,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 14
                ),
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                borderRadius: _animation.value > 1
                    ? BorderRadius.horizontal(right: Radius.circular(50), left: Radius.circular(0))
                    : BorderRadius.circular(50)
            ),
            child: IconButton(
              splashRadius: 20,
              tooltip: 'Search',
              padding: const EdgeInsets.only(bottom: 0, top: 2, left: 2),
              icon: Icon(
                Icons.search,
                color: Colors.black54,
                size: 15,
              ),
              onPressed: () {
                if (!isForward) {
                  _animationController.forward();
                  isForward = true;
                } else {
                  _animationController.reverse();
                  isForward = false;
                  _textController.clear();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}