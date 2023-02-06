import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_responsive_tools/screen_type_layout.dart';
import 'package:notary_admin/main.dart';
import 'package:notary_admin/src/init.dart';
import 'package:notary_admin/src/widgets/mixins/lang.dart';
import 'package:rapidoc_utils/widgets/image_utils.dart';
import 'package:rxdart/rxdart.dart';

Map<String, String> _flagMap = {
  'en': 'gb.png',
  'ar': 'dz.png',
  'fr': 'fr.png',
};

class ResponsiveLangSwitch extends StatelessWidget {
  final List<Locale> list;
  final Locale current;

  const ResponsiveLangSwitch(
      {Key? key, required this.list, required this.current})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return ScreenTypeLayout(
      mobileBuilder: (context) => LangSwitch(
        showFlag: false,
        showFullName: false,
        initialValue: current,
        onChange: (l) => myAppKey.currentState?.setLang(l),
        flagUrl: (l) =>
            "${getUrlBase()}/resources/assets/flags/${_flagMap[l.languageCode]}",
        locales: list,
        langName: (l) => lang.getLangName(l.languageCode),
      ),
      tabletBuilder: (context) => LangSwitch(
        showFlag: false,
        showFullName: true,
        onChange: (l) => myAppKey.currentState?.setLang(l),
        flagUrl: (l) =>
            "${getUrlBase()}/resources/assets/flags/${_flagMap[l.languageCode]}",
        locales: list,
        initialValue: current,
        langName: (l) => lang.getLangName(l.languageCode),
      ),
      desktopBuilder: (context) => LangSwitch(
        showFlag: true,
        showFullName: true,
        initialValue: current,
        onChange: (l) => myAppKey.currentState?.setLang(l),
        flagUrl: (l) =>
            "${getUrlBase()}/resources/assets/flags/${_flagMap[l.languageCode]}",
        locales: list,
        langName: (l) => lang.getLangName(l.languageCode),
      ),
    );
  }
}

class LangSwitch extends StatefulWidget {
  final Function(Locale) onChange;
  final String Function(Locale)? flagUrl;
  final String Function(Locale)? langName;
  final bool showFullName;
  final bool showFlag;
  final List<Locale> locales;
  final Locale initialValue;
  final bool hideSelected;

  const LangSwitch({
    Key? key,
    required this.onChange,
    required this.locales,
    required this.initialValue,
    this.flagUrl,
    this.langName,
    this.showFlag = true,
    this.showFullName = true,
    this.hideSelected = true,
  })  : assert(locales.length != 0, "Locales must not be empty"),
        super(key: key);

  @override
  LangSwitchState createState() => LangSwitchState();
}

class LangSwitchState extends State<LangSwitch> {
  final _subject = BehaviorSubject<Locale>();
  late StreamSubscription _sub;
  final localeKey = "lang_switch_locale";

  @override
  void initState() {
    _sub = _subject.listen((val) {
      widget.onChange(val);
    });
    _subject.add(widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Locale>(
        stream: _subject,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          Locale selected = snapshot.data!;

          return PopupMenuButton(
            onSelected: _subject.add,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      if (widget.showFlag) ...[
                        _getFlag(selected),
                        const SizedBox(width: 10)
                      ],
                      Text(
                        widget.showFullName
                            ? _getLangName(selected)
                            : selected.languageCode.toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            itemBuilder: (context) {
              return widget.locales
                  .where(
                    (element) => widget.hideSelected && element != selected,
                  )
                  .map(
                    (e) => PopupMenuItem(
                      child: Row(
                        children: [
                          _getFlag(e),
                          const SizedBox(width: 10),
                          Text(_getLangName(e)),
                        ],
                      ),
                      value: e,
                    ),
                  )
                  .toList();
            },
          );
        });
  }

  Widget _getFlag(Locale l) {
    if (widget.flagUrl != null) {
      return ImageUtils.fromNetwork(widget.flagUrl!(l), width: 24, height: 24);
    }
    return const SizedBox.shrink();
  }

  String _getLangName(Locale l) {
    if (widget.langName != null) {
      return widget.langName!(l);
    }
    return l.languageCode;
  }
}
