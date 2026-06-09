// lib/main.dart
//
// App entry + adaptive shell. Loads persisted settings (locale, number
// format) before runApp, then watches AppState so a language change in
// Settings takes effect immediately.
//
// Layout:
//   < 720 px  : bottom navigation bar
//   >= 720 px : NavigationRail (extended above 1100 px)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Headless diagnostic self-test. Native (dart:io) impl on desktop/mobile;
// no-op stub on web (no dart:io). Keeps main.dart web-compilable.
import 'diagnostics_runner_stub.dart'
    if (dart.library.io) 'diagnostics_runner_io.dart';
import 'engine/app_state.dart';
import 'engine/calculator_engine.dart';
import 'engine/matrix_diagnostics.dart';
import 'localization/app_localizations.dart';
import 'screens/about_screen.dart';
import 'screens/analysis_hub_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/function_editor_screen.dart';
import 'screens/graphing_screen.dart';
import 'screens/help_screen.dart';
import 'screens/notepad_screen.dart';
import 'services/crash_reporter.dart';
import 'utils/share_link.dart';
import 'widgets/perf_overlay.dart';
import 'services/native_licenses.dart';
import 'widgets/export_data_dialog.dart';
import 'widgets/import_data_dialog.dart';
import 'widgets/onboarding_tour.dart';
import 'widgets/user_functions_dialog.dart';
import 'widgets/function_reference_dialog.dart';
import 'widgets/worked_examples_dialog.dart';
import 'widgets/web_unsupported_banner.dart';
import 'engine/ocr_providers_init_stub.dart'
    if (dart.library.io) 'engine/ocr_providers_init.dart'
    if (dart.library.js_interop) 'engine/ocr_providers_init_web.dart';
import 'widgets/ocr_settings_dialog_stub.dart'
    if (dart.library.io) 'widgets/ocr_settings_dialog.dart';

/// Round 71: a single app-wide [RouteObserver] so screens / dialogs
/// pushed onto the root navigator can subscribe via [RouteAware] and
/// react when the user navigates back. The calculator uses this to
/// reclaim hardware-keyboard focus on every `didPopNext` — without
/// it, dismissing a dialog (Unit Converter, Constants, etc.) or
/// returning from a module screen (Sudoku, Constraints, …) leaves
/// focus stranded on whichever widget the dialog/screen last held,
/// and the user can't type into the calculator until they click a
/// keypad button or hit the "reset focus" recovery action.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opt-in crash reporter: collects errors into a ring buffer.
  // No data leaves the device without explicit user action (email/issue).
  // Also silences the known HardwareKeyboard false-positive assertion.
  CrashReporter.instance.install();

  await AppState().load();
  // Register native (SymEngine / GMP / MPFR / MPC / FLINT) license texts so
  // they appear in `showLicensePage` alongside the pub deps.
  await registerNativeLicenses();

  // Initialize OCR providers (checks for downloaded models + native libs).
  await initOcrProviders();

  // Headless self-test for CI / manual verification. Invoke with the
  // `CRISPCALC_DIAGNOSTIC=matrix|steps` environment variable set (desktop
  // only). Runs the matrix / step battery against the native bridge,
  // prints PASS/FAIL lines, and exits non-zero on any failure. On web this
  // is a no-op (the conditional import resolves to the stub).
  runDiagnosticsIfRequested();

  // The SymEngine bridge loads synchronously on native, but on web the WASM
  // module (web/symengine.js + symengine.wasm) resolves asynchronously after
  // the page boots. Kick off the handshake so CalculatorEngine instances
  // re-acquire the real bridge once it's live — until then they run in the
  // pure-Dart fallback. Fire-and-forget: it flips `nativeBridgeReady` on
  // success and gives up quietly if WASM never loads.
  unawaited(pollForNativeBridge());

  runApp(const CrispCalcApp());
}

class CrispCalcApp extends StatelessWidget {
  const CrispCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'CrispCalc - CAS Calculator',
          debugShowCheckedModeBanner: false,
          locale: appState.locale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('de', ''),
            Locale('fr', ''),
            Locale('es', ''),
          ],
          themeMode: appState.themeMode,
          theme: appState.highContrast
              ? _buildHighContrastLightTheme()
              : _buildLightTheme(),
          darkTheme: appState.highContrast
              ? _buildHighContrastDarkTheme()
              : _buildDarkTheme(),
          builder: (context, child) {
            final scale = appState.textScale;
            if (scale == 1.0) return child!;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            );
          },
          navigatorObservers: [appRouteObserver],
          home: const MainScreen(),
        );
      },
    );
  }
}

ThemeData _buildDarkTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF222222),
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.blueAccent,
      secondary: Colors.cyanAccent,
    ),
  );
}

ThemeData _buildLightTheme() {
  return ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE8EAED),
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blue,
      secondary: Colors.cyan,
    ),
  );
}

ThemeData _buildHighContrastDarkTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.highContrastDark(),
    dividerColor: Colors.white54,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

ThemeData _buildHighContrastLightTheme() {
  return ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.highContrastLight(),
    dividerColor: Colors.black54,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black87, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

const double _railBreakpoint = 720;
const double _extendedRailBreakpoint = 1100;

// Index constants for the tab order in [_screens] / [_destinations].
// Only a subset is referenced by name today (the cross-tab nav callbacks);
// the rest are kept as documentation so the next person inserting a tab
// can renumber without spelunking through the IndexedStack indices.
const int _kCalculator = 0;
// ignore: unused_element
const int _kNotepad = 1;
const int _kGraphing = 2;
// ignore: unused_element
const int _kFunctionEditor = 3;
const int _kAnalysis = 4;
// ignore: unused_element
const int _kSettings = 5;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = _kCalculator;
  bool _showPerfOverlay = false;

  final GlobalKey<CalculatorScreenState> _calculatorKey = GlobalKey();
  final GlobalKey<GraphingScreenState> _graphingKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CalculatorScreen(
        key: _calculatorKey,
        onGoToGraphing: () => _select(_kGraphing),
        onGoToAnalysis: () => _select(_kAnalysis),
      ),
      const NotepadScreen(),
      GraphingScreen(key: _graphingKey),
      FunctionEditorScreen(
        onSwitchToGraphing: (_) => _select(_kGraphing),
      ),
      const AnalysisHubScreen(),
      const SettingsScreen(),
    ];
    // First-launch onboarding tour. Skipped if the user has already
    // dismissed it (persisted) or — pragmatically — when running
    // headless / under widget tests where no MaterialApp ancestor is
    // mounted in the right way to host a Dialog. The setOnboarding flag
    // toggle in OnboardingTour.show prevents re-showing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!AppState().onboardingDismissed) {
        OnboardingTour.show(context);
      }
      // Calculator's own initState postFrame already requests focus,
      // but it can lose the focus race when the IndexedStack mounts
      // sibling screens (Notepad, Graphing, etc.) and their
      // TextEditingControllers/FocusNodes get instantiated. Belt-and-
      // suspender re-request here ensures the calculator captures
      // hardware-keyboard focus on cold launch without the user
      // having to tap the "reset focus" recovery action.
      if (_selectedIndex == _kCalculator) {
        _calculatorKey.currentState?.requestFocus();
      }
      // Shared link: auto-populate calculator from URL params on web.
      final share = ShareParams.fromCurrentUrl();
      if (share != null) {
        if (share.tab != null && share.tab! >= 0 && share.tab! < 6) {
          _select(share.tab!);
        }
        if (share.expression != null) {
          _calculatorKey.currentState?.insertExpression(share.expression!);
        }
      }
    });
    // Worked-examples V2: when a dialog signals "insert this into the
    // calculator", switch to the Calculator tab. The CalculatorScreen
    // itself consumes the pending expression and inserts it.
    AppState().addListener(_maybeRouteToCalculator);
  }

  @override
  void dispose() {
    AppState().removeListener(_maybeRouteToCalculator);
    super.dispose();
  }

  void _maybeRouteToCalculator() {
    if (!mounted) return;
    if (AppState().pendingInsertExpression != null &&
        _selectedIndex != _kCalculator) {
      _select(_kCalculator);
    }
  }

  void _select(int i) {
    if (i == _selectedIndex) return;
    setState(() => _selectedIndex = i);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (i == _kCalculator) {
        _calculatorKey.currentState?.requestFocus();
      } else if (i == _kGraphing) {
        _graphingKey.currentState?.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Ctrl/Cmd + 1-6 switch between tabs (accessibility / power-user).
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
            _select(0),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
            _select(1),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () =>
            _select(2),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () =>
            _select(3),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true): () =>
            _select(4),
        const SingleActivator(LogicalKeyboardKey.digit6, control: true): () =>
            _select(5),
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
            _select(0),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
            _select(1),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true): () =>
            _select(2),
        const SingleActivator(LogicalKeyboardKey.digit4, meta: true): () =>
            _select(3),
        const SingleActivator(LogicalKeyboardKey.digit5, meta: true): () =>
            _select(4),
        const SingleActivator(LogicalKeyboardKey.digit6, meta: true): () =>
            _select(5),
        const SingleActivator(LogicalKeyboardKey.keyP,
                control: true, shift: true):
            () => setState(() => _showPerfOverlay = !_showPerfOverlay),
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true, shift: true):
            () => setState(() => _showPerfOverlay = !_showPerfOverlay),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (width >= _railBreakpoint) {
              return _buildRailLayout(t,
                  extended: width >= _extendedRailBreakpoint);
            }
            return _buildBottomNavLayout(t);
          },
        ),
      ),
    );
  }

  List<({IconData icon, String label})> _destinations(AppLocalizations t) {
    return [
      (icon: Icons.calculate, label: t.navCalculator),
      (icon: Icons.notes, label: t.navNotepad),
      (icon: Icons.show_chart, label: t.navGraphing),
      (icon: Icons.functions, label: t.navFunctions),
      (icon: Icons.donut_large, label: t.navAnalysis),
      (icon: Icons.settings, label: t.navSettings),
    ];
  }

  /// Wraps a shell body with the web-only "CAS unavailable" banner above
  /// it. Off-web the banner renders nothing, so this is a transparent
  /// pass-through on native.
  Widget _withWebBanner(Widget body) => Column(
        children: [
          if (_showPerfOverlay) const PerfOverlay(),
          const WebUnsupportedBanner(),
          Expanded(child: body),
        ],
      );

  Widget _buildBottomNavLayout(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _withWebBanner(
          IndexedStack(index: _selectedIndex, children: _screens)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withValues(alpha: 0.6),
        currentIndex: _selectedIndex,
        onTap: _select,
        items: _destinations(t)
            .map((d) => BottomNavigationBarItem(
                  icon: Icon(d.icon, semanticLabel: d.label),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRailLayout(AppLocalizations t, {required bool extended}) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _withWebBanner(Row(
        children: [
          NavigationRail(
            backgroundColor: cs.surface,
            extended: extended,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _select,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: _destinations(t)
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon, semanticLabel: d.label),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
        ],
      )),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.settingsLanguage,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      RadioGroup<String>(
                        groupValue: appState.locale.languageCode,
                        onChanged: (v) {
                          if (v != null) appState.setLocale(Locale(v));
                        },
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(t.settingsLanguageEnglish),
                              value: 'en',
                            ),
                            RadioListTile<String>(
                              title: Text(t.settingsLanguageGerman),
                              value: 'de',
                            ),
                            RadioListTile<String>(
                              title: Text(t.settingsLanguageFrench),
                              value: 'fr',
                            ),
                            RadioListTile<String>(
                              title: Text(t.settingsLanguageSpanish),
                              value: 'es',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.settingsNumberFormat,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.settingsNumberFormatAuto),
                        value: appState.decimalPlaces < 0,
                        onChanged: (auto) {
                          appState.setDecimalPlaces(auto ? -1 : 2);
                        },
                      ),
                      if (appState.decimalPlaces >= 0) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.settingsNumberFormatDecimalPlaces(
                                    appState.decimalPlaces),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: appState.decimalPlaces.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          label: appState.decimalPlaces.toString(),
                          onChanged: (v) =>
                              appState.setDecimalPlaces(v.round()),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.settingsTheme,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      RadioGroup<ThemeMode>(
                        groupValue: appState.themeMode,
                        onChanged: (v) {
                          if (v != null) appState.setThemeMode(v);
                        },
                        child: Column(
                          children: [
                            RadioListTile<ThemeMode>(
                              title: Text(t.settingsThemeSystem),
                              value: ThemeMode.system,
                            ),
                            RadioListTile<ThemeMode>(
                              title: Text(t.settingsThemeLight),
                              value: ThemeMode.light,
                            ),
                            RadioListTile<ThemeMode>(
                              title: Text(t.settingsThemeDark),
                              value: ThemeMode.dark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.contrast,
                      semanticLabel: 'High contrast'),
                  title: Text(t.settingsHighContrast),
                  subtitle: Text(t.settingsHighContrastSubtitle),
                  value: appState.highContrast,
                  onChanged: appState.setHighContrast,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.text_fields,
                      semanticLabel: 'Text scale'),
                  title: Text(t.settingsTextScale),
                  subtitle: Slider(
                    value: appState.textScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(appState.textScale * 100).round()}%',
                    onChanged: appState.setTextScale,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.pin_outlined,
                      semanticLabel: 'Exact integers'),
                  title: Text(t.settingsExactIntegerMode),
                  subtitle: Text(t.settingsExactIntegerModeSubtitle),
                  value: appState.exactIntegerMode,
                  onChanged: appState.setExactIntegerMode,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  secondary:
                      const Icon(Icons.link, semanticLabel: 'Auto bind solve'),
                  title: Text(t.settingsAutoBindSolve),
                  subtitle: Text(t.settingsAutoBindSolveSubtitle),
                  value: appState.autoBindSolve,
                  onChanged: appState.setAutoBindSolve,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.flag_outlined, semanticLabel: 'Tour'),
                  title: Text(t.settingsReplayTour),
                  subtitle: Text(t.settingsReplayTourSubtitle),
                  trailing:
                      const Icon(Icons.play_arrow, semanticLabel: 'Start tour'),
                  onTap: () => OnboardingTour.show(context),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.settingsLayoutTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(t.settingsLayoutBody),
                    ],
                  ),
                ),
              ),
              // Round 71: Unit Converter + Constants live in the
              // Analysis hub only — duplicated entry-points here
              // made Settings noisy and confused new users about
              // which surface owned what.
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.functions,
                      semanticLabel: 'User functions'),
                  title: Text(t.settingsUserFunctions),
                  subtitle: Text(t.settingsUserFunctionsSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const UserFunctionsDialog(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined,
                      semanticLabel: 'Worked examples'),
                  title: Text(t.settingsWorkedExamples),
                  subtitle: Text(t.settingsWorkedExamplesSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const WorkedExamplesDialog(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Round 96 (P6): Function Reference dialog. Lives in
              // Settings for V1; Round 101's help-mode toggle will
              // surface it inline from Calculator / Notepad.
              Card(
                child: ListTile(
                  leading: const Icon(Icons.functions,
                      semanticLabel: 'Function reference'),
                  title: Text(t.settingsFunctionRef),
                  subtitle: Text(t.settingsFunctionRefSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const FunctionReferenceDialog(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.help_outline, semanticLabel: 'Help'),
                  title: Text(t.settingsHelp),
                  subtitle: Text(t.settingsHelpSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const HelpScreen(),
                    ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.ios_share, semanticLabel: 'Export'),
                  title: Text(t.settingsExportData),
                  subtitle: Text(t.settingsExportDataSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const ExportDataDialog(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.file_upload, semanticLabel: 'Import'),
                  title: Text(t.settingsImportData),
                  subtitle: Text(t.settingsImportDataSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const ImportDataDialog(),
                  ),
                ),
              ),
              // OCR model management
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.camera_alt_outlined,
                      semanticLabel: 'OCR Models'),
                  title: const Text('Math OCR Models'),
                  subtitle:
                      const Text('Download models for equation recognition'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => const OcrSettingsDialog(),
                  ),
                ),
              ),
              // Round 91 follow-up: matrix self-test is a developer
              // diagnostic — it runs the SymbolicMathBridge calls and
              // prints a pass/fail report. End users will never need
              // it, and a release-build user who taps it sees raw
              // bridge output. Gate behind kDebugMode so it ships only
              // to dev builds. CI / scripted runs still reach it via
              // the CRISPCALC_DIAGNOSTIC=matrix env-var at startup
              // (see main.dart:73-79).
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.fact_check_outlined,
                        semanticLabel: 'Diagnostics'),
                    title: Text(t.matrixDiagnosticsTitle),
                    subtitle: Text(t.matrixDiagnosticsSubtitle),
                    trailing: const Icon(Icons.play_arrow,
                        semanticLabel: 'Run diagnostics'),
                    onTap: () => _showMatrixDiagnostics(context, t),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _CrispAssistSettingsCard(appState: appState),
              const SizedBox(height: 16),
              if (CrashReporter.instance.hasReports)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.bug_report,
                        semanticLabel: 'Crash reports',
                        color: Theme.of(context).colorScheme.error),
                    title:
                        Text('Crash Reports (${CrashReporter.instance.count})'),
                    subtitle: const Text(
                        'Review and send — no data leaves without your action'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, semanticLabel: 'Open'),
                    onTap: () => _showCrashReportDialog(context),
                  ),
                ),
              if (CrashReporter.instance.hasReports) const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.info_outline, semanticLabel: 'About'),
                  title: Text(t.settingsAbout),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, semanticLabel: 'Open'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AboutScreen(),
                    ));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCrashReportDialog(BuildContext context) {
    final reporter = CrashReporter.instance;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crash Reports'),
        content: SizedBox(
          width: 420,
          height: 300,
          child: ListView(
            children: [
              for (final r in reporter.reports)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      r.toReportString(),
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              reporter.clear();
              Navigator.of(ctx).pop();
              // Trigger ListenableBuilder rebuild to hide the card.
              AppState().refresh();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              reporter.launchGitHubIssue();
            },
            child: const Text('Report on GitHub'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              reporter.launchEmailReport();
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMatrixDiagnostics(
      BuildContext context, AppLocalizations t) async {
    final engine = CalculatorEngine();
    final results = MatrixDiagnostics.run(engine);
    final passed = results.where((r) => r.passed).length;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.matrixDiagnosticsTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.matrixDiagnosticsSummary(passed, results.length),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                for (final r in results) ...[
                  Row(
                    children: [
                      Icon(
                        r.passed ? Icons.check_circle : Icons.cancel,
                        semanticLabel: r.passed ? 'Passed' : 'Failed',
                        color: r.passed
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('expr: ${r.expression}',
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12)),
                        Text('expected: ${r.expected}',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.grey[400])),
                        Text('actual:   ${r.actual}',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: r.passed
                                    ? Colors.grey[400]
                                    : Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.cancel),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CrispAssist settings card
// ---------------------------------------------------------------------------

class _CrispAssistSettingsCard extends StatefulWidget {
  final AppState appState;
  const _CrispAssistSettingsCard({required this.appState});

  @override
  State<_CrispAssistSettingsCard> createState() =>
      _CrispAssistSettingsCardState();
}

class _CrispAssistSettingsCardState extends State<_CrispAssistSettingsCard> {
  late final TextEditingController _urlCtl;
  late final TextEditingController _keyCtl;
  late final TextEditingController _modelCtl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _urlCtl = TextEditingController(text: widget.appState.crispAssistApiUrl);
    _keyCtl = TextEditingController(text: widget.appState.crispAssistApiKey);
    _modelCtl = TextEditingController(text: widget.appState.crispAssistModel);
  }

  @override
  void dispose() {
    _urlCtl.dispose();
    _keyCtl.dispose();
    _modelCtl.dispose();
    super.dispose();
  }

  Widget _providerChip(String label, String url, String model) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      onPressed: () => setState(() {
        _urlCtl.text = url;
        _modelCtl.text = model;
      }),
    );
  }

  void _save() {
    widget.appState.setCrispAssistApiUrl(_urlCtl.text.trim());
    widget.appState.setCrispAssistApiKey(_keyCtl.text.trim());
    final model = _modelCtl.text.trim();
    widget.appState.setCrispAssistModel(
        model.isEmpty ? 'claude-sonnet-4-20250514' : model);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CrispAssist settings saved')),
    );
  }

  void _clear() {
    _urlCtl.text = '';
    _keyCtl.text = '';
    _modelCtl.text = 'claude-sonnet-4-20250514';
    widget.appState.setCrispAssistApiUrl('');
    widget.appState.setCrispAssistApiKey('');
    widget.appState.setCrispAssistModel('claude-sonnet-4-20250514');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = widget.appState.crispAssistEnabled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      semanticLabel: 'CrispAssist',
                      color: enabled ? cs.primary : cs.onSurface),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CrispAssist',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          enabled
                              ? 'Connected (${widget.appState.crispAssistModel})'
                              : 'Not configured',
                          style: TextStyle(
                            fontSize: 12,
                            color: enabled
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      semanticLabel: _expanded ? 'Collapse' : 'Expand'),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 16),
              Text(
                'CrispAssist explains results and translates natural language '
                'to engine syntax. It never computes answers — all math goes '
                'through SymEngine. You supply your own API key.',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              // Quick-fill presets for common providers
              Wrap(
                spacing: 6,
                children: [
                  _providerChip(
                      'Anthropic',
                      'https://api.anthropic.com/v1/messages',
                      'claude-sonnet-4-20250514'),
                  _providerChip(
                      'Mistral',
                      'https://api.mistral.ai/v1/chat/completions',
                      'mistral-small-latest'),
                  _providerChip(
                      'Scaleway',
                      'https://api.scaleway.ai/v1/chat/completions',
                      'llama-3.1-8b-instruct'),
                  _providerChip(
                      'OpenAI',
                      'https://api.openai.com/v1/chat/completions',
                      'gpt-4o-mini'),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlCtl,
                decoration: const InputDecoration(
                  labelText: 'API URL',
                  hintText: 'https://api.anthropic.com/v1/messages',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keyCtl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'sk-ant-...',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _modelCtl,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'claude-sonnet-4-20250514',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _clear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
