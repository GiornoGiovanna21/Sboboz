// app/lib/main.dart
// Purpose: App entry point with Riverpod ProviderScope

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SbobozApp(),
    ),
  );
}
