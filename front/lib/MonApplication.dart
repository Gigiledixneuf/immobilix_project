import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './routers.dart';

class MonApplication extends ConsumerStatefulWidget {
  const MonApplication({super.key});
  
  @override
  ConsumerState<MonApplication> createState() => _MonApplicationState();
}

class _MonApplicationState extends ConsumerState<MonApplication> {
  @override
  Widget build(BuildContext context) {
    final routerConfig = ref.watch(routerConfigProvider);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFF9900)),
        useMaterial3: true,
      ),
      routerConfig: routerConfig,
    );
  }
}