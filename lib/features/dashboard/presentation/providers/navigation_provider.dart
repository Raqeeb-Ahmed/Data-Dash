import 'package:flutter_riverpod/flutter_riverpod.dart';

// Represents the active navigation tab index across the dashboard shell
final navigationProvider = StateProvider<int>((ref) => 0);
