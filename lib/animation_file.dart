import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final GlobalKey<_OverlayAnimationWidgetState> _animKey =
    GlobalKey<_OverlayAnimationWidgetState>();

GlobalKey<_OverlayAnimationWidgetState> get overlayKey => _animKey;

class OverlayBaseClassWidget extends StatelessWidget {
  final Widget? child;
  final bool stickTopRight, stickTopLeft, stickBottomRight, stickBottomLeft;
  final double itemGap;
  final double? overlayWidth;

  // showItemsNumber cant be more than 8 as if more than 8 it will make as 8
  final int showItemsNumber;

  const OverlayBaseClassWidget({
    super.key,
    required this.child,
    this.stickTopRight = false,
    this.stickTopLeft = false,
    this.stickBottomRight = false,
    this.stickBottomLeft = false,
    this.itemGap = 8,
    int showItemsNumber = 3,
    this.overlayWidth,
  }) : showItemsNumber = showItemsNumber > 8 ? 8 : showItemsNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child!,
          Positioned(
            top: stickBottomRight || stickBottomLeft
                ? null
                : MediaQuery.of(context).viewPadding.top + kToolbarHeight,
            bottom: stickBottomLeft || stickBottomRight ? 0 : null,
            left: stickTopLeft || stickBottomLeft ? 0 : null,
            right: stickTopRight ||
                    stickBottomRight ||
                    (!stickTopRight &&
                        !stickTopLeft &&
                        !stickBottomRight &&
                        !stickBottomLeft)
                ? 0
                : null,
            child: OverlayAnimationWidget(
              key: _animKey,
              overlayWidth: overlayWidth,
              showItemNumber: showItemsNumber,
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayAnimationWidget extends StatefulWidget {
  final double? overlayWidth;
  final int showItemNumber;

  const OverlayAnimationWidget(
      {super.key, this.overlayWidth, this.showItemNumber = 3});

  @override
  State<OverlayAnimationWidget> createState() => _OverlayAnimationWidgetState();
}

class _OverlayAnimationWidgetState extends State<OverlayAnimationWidget>
    with TickerProviderStateMixin {
  final List items = [];
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _sizeAnimations = [];
  final List<Animation<Offset>> _animationOffsets = [];
  final List<bool> removedItem = [];

  bool dataBeingRemoved = false;

  @override
  void initState() {
    super.initState();

    // ignore: unused_local_variable
    for (var element in items) {
      removedItem.add(false);
      _controllers.add(AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ));

      _sizeAnimations.add(
        Tween<double>(begin: 1, end: 0).animate(
          _controllers[_controllers.isNotEmpty ? _controllers.length - 1 : 0],
        ),
      );

      _animationOffsets.add(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          _controllers[_controllers.isNotEmpty ? _controllers.length - 1 : 0],
        ),
      );
    }

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  add(String data) {
    print("add");

    try {
      removedItem.add(false);

      _controllers.add(AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ));

      _sizeAnimations.add(
        Tween<double>(begin: 1, end: 0).animate(
          _controllers[_controllers.isNotEmpty ? _controllers.length - 1 : 0],
        ),
      );

      _animationOffsets.add(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(
          _controllers[_controllers.isNotEmpty ? _controllers.length - 1 : 0],
        ),
      );
      setState(() {
        items.add(data);
      });
      // items.add(data);

      _controllers[_controllers.isNotEmpty ? _controllers.length - 1 : 0]
          .forward();
    } catch (e) {
      if (kDebugMode) {
        print("exception adding");
      }
    }
  }

  remove(int index) async {
    print("remove");

    try {
      if (items[index] != null) {
        removedItem[index] = true;
        _controllers[index].reset();

        setState(() {
          dataBeingRemoved = true;
        });

        if (items.length > widget.showItemNumber) {
          _controllers[widget.showItemNumber-1].reset();
          _controllers[widget.showItemNumber-1].forward();
        }

        await _controllers[index].forward().then(
          (value) {
            _controllers[index].dispose();

            _controllers.removeAt(index);

            _sizeAnimations.removeAt(index);
            _animationOffsets.removeAt(index);
            removedItem.removeAt(index);
            setState(() {
              items.removeAt(index);
            });
            dataBeingRemoved = false;
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("exception removing");
      }
    }
  }

  clear() {
    removedItem.clear();

    for (var e in _controllers) {
      e.dispose();
    }

    _controllers.clear();
    _sizeAnimations.clear();
    _animationOffsets.clear();
    removedItem.clear();
    setState(() {
      items.clear();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: items.length > 8
      height: widget.showItemNumber > 8
          ? MediaQuery.of(context).size.height * 1 -
              (MediaQuery.of(context).viewPadding.top + kToolbarHeight)
          : null,
      width: widget.overlayWidth ?? MediaQuery.of(context).size.width * 1,
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print("ListView $index");
                  return AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      if ((index > (widget.showItemNumber - 1) &&
                              items.length > widget.showItemNumber) ||
                          (index == (widget.showItemNumber - 1) &&
                              items.length > widget.showItemNumber &&
                              !dataBeingRemoved)) {
                        return const SizedBox.shrink();
                      }

                      return mainBWidget(index);
                    },
                  );
                },
              ),
              if (items.length > widget.showItemNumber)
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    mainBWidget(
                      items.length - 1,
                      needClearIcon: true,
                      needAnimation: false,
                    ),
                    Material(
                      child: InkWell(
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          if (kDebugMode) {
                            print(
                                "Clear All tapped ${items.length - widget.showItemNumber}");
                          }
                          clear();
                        },
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: const Text("Clear All"),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemWidget(int index, {bool needClearIcon = true, String? title}) {
    return Container(
      // color: Colors.red[100 * index]
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey,
          )),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          title ??
              (needClearIcon
                  // ? "${items.length - widget.showItemNumber} more"
                  ? "${items.length - (3 - 1)} more"
                  : items[index].toString()),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: !needClearIcon
            ? InkWell(
                onTap: () {
                  remove(index);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget mainBWidget(
    int index, {
    bool needClearIcon = false,
    bool needAnimation = true,
  }) {
    return Stack(
      children: [
        !needAnimation
            ? itemWidget(
                index,
                needClearIcon: needClearIcon,
              )
            : removedItem[index]
                ? SizeTransition(
                    sizeFactor: _sizeAnimations[index],
                    child: itemWidget(
                      index,
                      needClearIcon: needClearIcon,
                    ),
                  )
                : SlideTransition(
                    position: _animationOffsets[index],
                    child: itemWidget(
                      index,
                      needClearIcon: needClearIcon,
                    ),
                  ),
      ],
    );
  }
}
