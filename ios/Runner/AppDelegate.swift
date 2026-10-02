import Flutter
import UIKit
import AppIntents

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var workflowChannel: FlutterMethodChannel?
  private var pendingWorkflows: [[String: String]] = []
  private var workflowsReady = false
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "crispmath/workflows",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
    workflowChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      if call.method == "takePending" {
        self.workflowsReady = true
        let pending = self.pendingWorkflows
        self.pendingWorkflows.removeAll()
        result(pending)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func receiveWorkflowURL(_ url: URL) {
    var payload: [String: String]
    if url.isFileURL {
      let accessed = url.startAccessingSecurityScopedResource()
      defer { if accessed { url.stopAccessingSecurityScopedResource() } }
      do {
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size <= 8 * 1024 * 1024 else {
          throw NSError(domain: "CrispMath", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Worksheet exceeds the 8 MB limit"])
        }
        let data = try Data(contentsOf: url)
        guard data.count <= 8 * 1024 * 1024 else {
          throw NSError(domain: "CrispMath", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Worksheet exceeds the 8 MB limit"])
        }
        payload = ["file": data.base64EncodedString()]
      } catch {
        payload = ["error": error.localizedDescription]
      }
    } else if url.scheme == "crispmath" {
      payload = ["url": url.absoluteString]
    } else {
      return
    }
    if workflowsReady, let channel = workflowChannel {
      channel.invokeMethod("incoming", arguments: payload)
    } else {
      pendingWorkflows.append(payload)
    }
  }
}

@objc class CrispMathSceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts {
      (UIApplication.shared.delegate as? AppDelegate)?.receiveWorkflowURL(context.url)
    }
  }

  override func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
    for context in contexts {
      (UIApplication.shared.delegate as? AppDelegate)?.receiveWorkflowURL(context.url)
    }
  }
}

@available(iOS 16.0, *)
struct CreateWorksheetIntent: AppIntent {
  static var title: LocalizedStringResource = "Create worksheet"
  static var description = IntentDescription("Open a CrispMath worksheet and calculate its expressions locally.")
  static var openAppWhenRun: Bool = true
  @Parameter(title: "Worksheet name", default: "Shortcut worksheet") var name: String
  @Parameter(title: "Expressions, one per line", default: "") var expressions: String

  func perform() async throws -> some IntentResult & OpensIntent {
    var components = URLComponents()
    components.scheme = "crispmath"
    components.host = "worksheet"
    components.queryItems = [URLQueryItem(name: "name", value: name),
                            URLQueryItem(name: "lines", value: expressions)]
    guard let url = components.url else { throw URLError(.badURL) }
    return .result(opensIntent: OpenURLIntent(url))
  }
}

@available(iOS 16.0, *)
struct OpenCalculationIntent: AppIntent {
  static var title: LocalizedStringResource = "Open calculation"
  static var description = IntentDescription("Open an expression in CrispMath's calculator.")
  static var openAppWhenRun: Bool = true
  @Parameter(title: "Expression", default: "") var expression: String

  func perform() async throws -> some IntentResult & OpensIntent {
    var components = URLComponents()
    components.scheme = "crispmath"
    components.host = "calculate"
    components.queryItems = [URLQueryItem(name: "expression", value: expression)]
    guard let url = components.url else { throw URLError(.badURL) }
    return .result(opensIntent: OpenURLIntent(url))
  }
}

@available(iOS 16.0, *)
struct CrispMathShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(intent: CreateWorksheetIntent(),
      phrases: ["Create a worksheet in \(.applicationName)"],
      shortTitle: "Create worksheet", systemImageName: "doc.badge.plus")
    AppShortcut(intent: OpenCalculationIntent(),
      phrases: ["Open a calculation in \(.applicationName)"],
      shortTitle: "Open calculation", systemImageName: "function")
  }
}
