import SwiftUI
import WebKit

struct HapticsWebView : UIViewControllerRepresentable {
    
    var url: String
    var clearCache: Bool
    
    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController()
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        uiViewController.loadUrl(url: url)
    }
}

//  ----------------------------------------
//  Internal
//

class WebViewController: UIViewController {

    private var webView: WKWebView!

    // haptic feedback generator
    private var selectionFeedbackGenerator: UISelectionFeedbackGenerator!
    private var impactLightFeedbackGenerator: UIImpactFeedbackGenerator!
    private var impactMediumFeedbackGenerator: UIImpactFeedbackGenerator!
    private var impactHeavyFeedbackGenerator: UIImpactFeedbackGenerator!
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator!

    override func loadView() {
        // create js handler
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "runHaptic")

        // create config and attach handler
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController

        // setup haptic feedback generator
        self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.impactLightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        self.impactMediumFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        self.impactHeavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        self.notificationFeedbackGenerator = UINotificationFeedbackGenerator()

        // create WebView
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }

    func loadUrl(url: String, clearCache: Bool = true) {
        if (clearCache) {
            WebViewController.clearCache()
        }
        webView.load(URLRequest(url: URL(string: url)!))
    }

    static func clearCache() {
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {})
    }
}

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let messageName = message.name
        print("JS message received : name = " + messageName)
        
        switch messageName {
            case "runHaptic":
                if (message.body as? String) != nil {
                    let messageBody:String = message.body as! String
                    print("JS message received : body = " + messageBody)
                    switch messageBody {
                        case "selection":
                            self.selectionFeedbackGenerator?.selectionChanged()
                            break
                        case "impact_light":
                            self.impactLightFeedbackGenerator?.impactOccurred()
                            break
                        case "impact_medium":
                            self.impactMediumFeedbackGenerator?.impactOccurred()
                            break
                        case "impact_heavy":
                            self.impactHeavyFeedbackGenerator?.impactOccurred()
                            break
                        case "notification_success":
                            self.notificationFeedbackGenerator?.notificationOccurred(.success)
                            break
                        case "notification_warning":
                            self.notificationFeedbackGenerator?.notificationOccurred(.warning)
                            break
                        case "notification_error":
                            self.notificationFeedbackGenerator?.notificationOccurred(.error)
                            break
                        default:
                            break
                    }
                }
                break
            default:
                return
        }
    }
}

//  ----------------------------------------
//  JS Example
//  if (window.webkit !== undefined) {
//    window.webkit.messageHandlers.runHaptic.postMessage('notification_success')
//  }

