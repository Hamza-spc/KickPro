import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openPlayerProfile(BuildContext context, int profileId) {
  context.push('/players/$profileId');
}
