import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const App()));
}

final supportedLocalesProvider = Provider(
  // TODO feature flag
  (ref) => [const Locale('en'), const Locale('de')],
);

final manualLocaleProvider = StateProvider((ref) => const Locale('en'));
final appLocaleProvider = Provider((ref) {
  final preferredLocales = [
    ref.watch(manualLocaleProvider),
    // TODO system locales
  ];
  final supportedLocales = ref.watch(supportedLocalesProvider);
  return basicLocaleListResolution(preferredLocales, supportedLocales);
});

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      locale: ref.watch(appLocaleProvider),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // TODO locale based title
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton(
              value: ref.watch(appLocaleProvider),
              items: ref
                  .watch(supportedLocalesProvider)
                  .map(
                    (locale) => DropdownMenuItem(
                      value: locale,
                      child: Text(locale.toLanguageTag()),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  ref.read(manualLocaleProvider.notifier).state = value!,
            ),
          ],
        ),
      ),
    );
  }
}
