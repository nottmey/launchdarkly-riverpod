import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launchdarkly_flutter_client_sdk/launchdarkly_flutter_client_sdk.dart';
import 'package:launchdarkly_riverpod/generated/localizations.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Lokalise.init(projectId: 'any, not used', sdkToken: 'any, not used');

  // using empty context, as we don't have user info at app start yet
  final emptyContext = LDContextBuilder().build();
  final ldClient = LDClient(
    LDConfig(
      '<put-your-sdk-key-here>',
      AutoEnvAttributes.enabled,
      logger: LDLogger(level: LDLogLevel.debug),
      dataSourceConfig: DataSourceConfig(evaluationReasons: kDebugMode),
    ),
    emptyContext,
  );
  await ldClient.start().timeout(
    const Duration(seconds: 4),
    onTimeout: () => false,
  );

  runApp(
    ProviderScope(
      overrides: [ldClientProvider.overrideWithValue(ldClient)],
      child: const App(),
    ),
  );
}

final emptyObject = LDValue.buildObject().build(); // for fallback

final ldClientProvider = Provider<LDClient>(
  (ref) => throw UnimplementedError('to be overwritten in ProviderScope'),
);

final jsonFlagChangesProvider = StreamProvider.family<LDValue, String>((
  ref,
  flagKey,
) {
  final ldClient = ref.watch(ldClientProvider);
  return ldClient.flagChanges
      .where((event) => event.keys.contains(flagKey))
      .map((_) => ldClient.jsonVariationDetail(flagKey, emptyObject).value);
});

final jsonFlagProvider = Provider.autoDispose.family<LDValue, String>((
  ref,
  flagKey,
) {
  final ldClient = ref.watch(ldClientProvider);
  final change = ref.watch(jsonFlagChangesProvider(flagKey));
  return change.hasValue
      ? change.requireValue
      : ldClient.jsonVariationDetail(flagKey, emptyObject).value;
});

final supportedLocalesProvider = Provider(
  (ref) => ref
      .watch(jsonFlagProvider('configure-supported-locales'))
      .values
      .map((object) => object.getFor('languageCode').stringValue())
      .where((languageCode) => languageCode.isNotEmpty)
      .map((languageCode) => Locale(languageCode))
      .where((locale) => L10nExtension.supportedLocales.contains(locale))
      .toList(),
);

class PlatformLocalesController extends Notifier<List<Locale>>
    with WidgetsBindingObserver {
  @override
  List<Locale> build() => WidgetsBinding.instance.platformDispatcher.locales;

  @override
  void didChangeLocales(List<Locale>? locales) => state = locales ?? [];
}

final platformLocalesProvider = NotifierProvider(PlatformLocalesController.new);

final selectedLocaleProvider = StateProvider<Locale?>((ref) => null);

final appLocaleProvider = Provider((ref) {
  return basicLocaleListResolution(
    [
      ref.watch(selectedLocaleProvider),
      ...ref.watch(platformLocalesProvider),
    ].nonNulls.toList(),
    ref.watch(supportedLocalesProvider),
  );
});

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final PlatformLocalesController _preferredLocalesController;

  @override
  void initState() {
    super.initState();
    _preferredLocalesController = ref.read(platformLocalesProvider.notifier);
    WidgetsBinding.instance.addObserver(_preferredLocalesController);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_preferredLocalesController);
    super.dispose();
  }

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
                  ref.read(selectedLocaleProvider.notifier).state = value,
            ),
          ],
        ),
      ),
    );
  }
}
