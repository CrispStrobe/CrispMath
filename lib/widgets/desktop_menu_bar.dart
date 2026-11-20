// lib/widgets/desktop_menu_bar.dart
//
// Native macOS menu bar. Replaces Flutter's template xib menu, whose
// "Preferences…" item was not connected to anything and which offered no
// app actions. Other platforms (and the iPad build running on a Mac, whose
// menu UIKit owns) get the child unchanged.
//
// Shortcuts deliberately avoid editing keys (⌘Z, ⌘C, ⌘V, ⌘A, ⌘F): a native
// key equivalent would take those away from the focused text field.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';

/// Every action the menu can trigger, supplied by the app shell.
class DesktopMenuActions {
  const DesktopMenuActions({
    required this.selectTab,
    required this.openCommandPalette,
    required this.newWorksheet,
    required this.openWorksheet,
    required this.saveWorksheet,
    required this.importData,
    required this.exportData,
    required this.workspaceBackups,
    required this.sync,
    required this.unitConverter,
    required this.functionReference,
    required this.userFunctions,
    required this.workedExamples,
    required this.openModule,
    required this.help,
    required this.replayTour,
    required this.about,
  });

  final void Function(int tab) selectTab;
  final VoidCallback openCommandPalette;
  final VoidCallback newWorksheet;
  final VoidCallback openWorksheet;
  final VoidCallback saveWorksheet;
  final VoidCallback importData;
  final VoidCallback exportData;
  final VoidCallback workspaceBackups;
  final VoidCallback sync;
  final VoidCallback unitConverter;
  final VoidCallback functionReference;
  final VoidCallback userFunctions;
  final VoidCallback workedExamples;

  /// Opens a module screen by sentinel (`open:statistics`, …).
  final void Function(String sentinel) openModule;
  final VoidCallback help;
  final VoidCallback replayTour;
  final VoidCallback about;
}

/// Index of the Settings tab in the app shell.
const int kDesktopMenuSettingsTab = 5;

bool get desktopMenuSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

class DesktopMenuBar extends StatelessWidget {
  const DesktopMenuBar({super.key, required this.actions, required this.child});

  final DesktopMenuActions actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!desktopMenuSupported) return child;
    final t = AppLocalizations.of(context);
    final a = actions;

    PlatformMenuItem item(String label, VoidCallback onSelected,
            [MenuSerializableShortcut? shortcut]) =>
        PlatformMenuItem(
            label: label, onSelected: onSelected, shortcut: shortcut);
    SingleActivator cmd(LogicalKeyboardKey key, {bool shift = false}) =>
        SingleActivator(key, meta: true, shift: shift);

    final tabs = [
      t.navCalculator,
      t.navNotepad,
      t.navGraphing,
      t.navFunctions,
      t.navAnalysis,
      t.navSettings,
    ];
    const digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
    ];

    return PlatformMenuBar(
      menus: [
        PlatformMenu(label: 'CrispMath', menus: [
          PlatformMenuItemGroup(members: [
            item(t.menuAboutApp, a.about),
          ]),
          PlatformMenuItemGroup(members: [
            item(t.menuSettingsEllipsis,
                () => a.selectTab(kDesktopMenuSettingsTab),
                cmd(LogicalKeyboardKey.comma)),
          ]),
          if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.servicesSubmenu))
            const PlatformMenuItemGroup(members: [
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.servicesSubmenu),
            ]),
          const PlatformMenuItemGroup(members: [
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
            PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hideOtherApplications),
            PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.showAllApplications),
          ]),
          const PlatformMenuItemGroup(members: [
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
          ]),
        ]),
        PlatformMenu(label: t.menuFile, menus: [
          PlatformMenuItemGroup(members: [
            item(t.notepadNewDocument, a.newWorksheet,
                cmd(LogicalKeyboardKey.keyN)),
            item(t.notepadOpenFile, a.openWorksheet,
                cmd(LogicalKeyboardKey.keyO)),
            item(t.notepadSaveFile, a.saveWorksheet,
                cmd(LogicalKeyboardKey.keyS)),
          ]),
          PlatformMenuItemGroup(members: [
            item(t.settingsImportData, a.importData),
            item(t.settingsExportData, a.exportData),
          ]),
          PlatformMenuItemGroup(members: [
            item(t.menuWorkspaceBackups, a.workspaceBackups),
            item(t.menuSync, a.sync),
          ]),
        ]),
        PlatformMenu(label: t.menuView, menus: [
          PlatformMenuItemGroup(members: [
            for (var i = 0; i < tabs.length; i++)
              item(tabs[i], () => a.selectTab(i), cmd(digits[i])),
          ]),
          PlatformMenuItemGroup(members: [
            item(t.menuCommandPalette, a.openCommandPalette,
                cmd(LogicalKeyboardKey.keyK)),
          ]),
          if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.toggleFullScreen))
            const PlatformMenuItemGroup(members: [
              PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.toggleFullScreen),
            ]),
        ]),
        PlatformMenu(label: t.menuTools, menus: [
          PlatformMenuItemGroup(members: [
            item(t.unitConverterTitle, a.unitConverter),
            item(t.settingsUserFunctions, a.userFunctions),
          ]),
          PlatformMenuItemGroup(members: [
            item(t.moduleStatistics, () => a.openModule('open:statistics')),
            item(t.moduleConstraintsTitle,
                () => a.openModule('open:constraints')),
            item(t.moduleSudokuTitle, () => a.openModule('open:sudoku')),
          ]),
        ]),
        const PlatformMenu(label: 'Window', menus: [
          PlatformMenuItemGroup(members: [
            PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.minimizeWindow),
            PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.zoomWindow),
          ]),
          PlatformMenuItemGroup(members: [
            PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.arrangeWindowsInFront),
          ]),
        ]),
        PlatformMenu(label: t.menuHelp, menus: [
          PlatformMenuItemGroup(members: [
            item(t.settingsHelp, a.help, cmd(LogicalKeyboardKey.slash,
                shift: true)),
            item(t.settingsFunctionRef, a.functionReference),
            item(t.settingsWorkedExamples, a.workedExamples),
          ]),
          PlatformMenuItemGroup(members: [
            item(t.settingsReplayTour, a.replayTour),
          ]),
        ]),
      ],
      child: child,
    );
  }
}
