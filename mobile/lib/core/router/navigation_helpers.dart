import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pops when possible; otherwise navigates to [fallbackLocation].
void popOrGo(BuildContext context, String fallbackLocation) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackLocation);
  }
}

/// Returns to the course detail screen after quiz completion.
void popToCourseDetail(BuildContext context, int courseId) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go('/courses/$courseId');
}

/// Returns from a course detail/list flow back toward profile/home.
void popCourseFlow(BuildContext context) {
  popOrGo(context, '/home');
}
