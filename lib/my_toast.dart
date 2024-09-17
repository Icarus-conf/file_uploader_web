import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

myToast({required String text, required ToastStates state}) => showToast(text,
    animation: StyledToastAnimation.slideFromBottomFade,
    reverseAnimation: StyledToastAnimation.slideToBottomFade,
    startOffset: const Offset(0.0, 3.0),
    reverseEndOffset: const Offset(0.0, 3.0),
    position: const StyledToastPosition(align: Alignment.center, offset: 0.0),
    duration: const Duration(seconds: 6),
    //Animation duration   animDuration * 2 <= duration
    animDuration: const Duration(milliseconds: 300),
    curve: Curves.linearToEaseOut,
    reverseCurve: Curves.fastOutSlowIn,
    backgroundColor: toastColor(state));

enum ToastStates { success, error, warning }

Color toastColor(ToastStates state) {
  switch (state) {
    case ToastStates.success:
      return const Color(0xFF153b50);
    case ToastStates.error:
      return const Color(0xFFDB4C40);
    default:
      return const Color(0xFF89bd9e);
  }
}
