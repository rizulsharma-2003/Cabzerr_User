
import 'package:flutter/material.dart';

import '../../../main.dart';

void navigatorPush({required BuildContext context, required newScreen}) async {
  // Ensure that the navigation operation is awaited
  await Navigator.push(context??MyApp.navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return newScreen;
        },
        // fullscreenDialog: fullscreenDialog,
      )
  );
}




 navigatorPushReplace(BuildContext context, Widget widgetScreen) async {
  return await Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => widgetScreen),
        (Route<dynamic> route) => false,
  );
}

goBack({param,context}) {
  if(Navigator.canPop(context??MyApp.navigatorKey.currentContext!)) {
    Navigator.pop(context??MyApp.navigatorKey.currentContext!,param);
  }
}

navigatorPop({int popCount = 0,context}) {
  Navigator.of(context??MyApp.navigatorKey.currentContext!).popUntil((_) => popCount-- <= 0);
}