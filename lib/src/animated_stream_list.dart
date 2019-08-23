import 'package:animated_stream_list/src/diff_applier.dart';
import 'package:animated_stream_list/src/list_controller.dart';
import 'package:animated_stream_list/src/myers_diff.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedStreamList<E> extends StatefulWidget {
  final List<E> blocList;
  final List<E> initialList;
  final AnimatedStreamListItemBuilder<E> itemBuilder;
  final AnimatedStreamListItemBuilder<E> itemRemovedBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController scrollController;
  final bool primary;
  final ScrollPhysics scrollPhysics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final Equalizer equals;

  AnimatedStreamList({
    @required this.blocList,
    this.initialList,
    @required this.itemBuilder,
    @required this.itemRemovedBuilder,
    this.scrollDirection: Axis.vertical,
    this.reverse: false,
    this.scrollController,
    this.primary,
    this.scrollPhysics,
    this.shrinkWrap: false,
    this.padding,
    this.equals,
  });

  @override
  State<StatefulWidget> createState() => _AnimatedStreamListState<E>();
}

class _AnimatedStreamListState<E> extends State<AnimatedStreamList<E>>
    with WidgetsBindingObserver {
  final GlobalKey<AnimatedListState> _globalKey = GlobalKey();
  ListController<E> _listController;
  DiffApplier<E> _diffApplier;
  DiffUtil<E> _diffUtil;

  void startListening() async {
    final diffList = await _diffUtil.calculateDiff(
        _listController.items, widget.blocList,
        equalizer: widget.equals);
    _diffApplier.applyDiffs(diffList);
  }

  @override
  void initState() {
    super.initState();
    _listController = ListController(
      key: _globalKey,
      items: widget.initialList ?? <E>[],
      itemRemovedBuilder: widget.itemRemovedBuilder,
    );

    _diffApplier = DiffApplier(_listController);
    _diffUtil = DiffUtil();

    startListening();
  }

  @override
  void didUpdateWidget(AnimatedStreamList oldWidget) {
    if(this.widget.blocList.length != oldWidget.blocList.length){
      startListening();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        startListening();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      initialItemCount: _listController.items.length,
      key: _globalKey,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      controller: widget.scrollController,
      physics: widget.scrollPhysics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) =>
              widget.itemBuilder(
        _listController[index],
        index,
        context,
        animation,
      ),
    );
  }
}
