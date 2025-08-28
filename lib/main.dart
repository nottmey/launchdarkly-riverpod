import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchdarkly_riverpod/generated/localizations.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Lokalise.init(projectId: 'any, not used', sdkToken: 'any, not used');

  runApp(ProviderScope(child: const App()));
}

final supportedLocalesProvider = Provider(
  // TODO feature flag
  (ref) => L10nExtension.supportedLocales,
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
      localizationsDelegates: L10nExtension.localizationsDelegates,
      supportedLocales: ref.watch(supportedLocalesProvider),
      locale: ref.watch(appLocaleProvider),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(L10nExtension.of(context).title)),
      body: Center(
        child: Column(
          children: [
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
