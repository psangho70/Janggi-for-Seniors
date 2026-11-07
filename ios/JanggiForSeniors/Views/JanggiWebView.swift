//
//  JanggiWebView.swift
//  청춘 장기 (Janggi for Seniors) - 시니어 맞춤형 효도 장기
//
//  시니어 최적화 WKWebView 컨테이너 (오프라인 로컬 번들 서빙, 뷰포트 고정, 바운스 방지)
//

import SwiftUI
import WebKit

struct JanggiWebView: UIViewRepresentable {
    private let bridgeHandler = NativeBridgeHandler()

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false

        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true

        let userContentController = WKUserContentController()
        // 자바스크립트 iosBridge 핸들러 등록
        userContentController.add(bridgeHandler, name: "iosBridge")

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.defaultWebpagePreferences = webpagePreferences
        configuration.userContentController = userContentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        // 어르신 눈이 편안한 원목 베이지 (#F7EBD3)
        let woodBeige = UIColor(red: 247/255, green: 235/255, blue: 211/255, alpha: 1.0)
        webView.backgroundColor = woodBeige
        webView.isOpaque = true

        // 스크롤 및 불필요한 제스처 통제 (실수로 인한 페이지 밀림 방지)
        webView.scrollView.backgroundColor = woodBeige
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = false

        // 로컬 번들(www/index.html) 오프라인 로드
        if let bundleURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "www") {
            webView.loadFileURL(bundleURL, allowingReadAccessTo: bundleURL.deletingLastPathComponent())
        } else if let directURL = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(directURL, allowingReadAccessTo: directURL.deletingLastPathComponent())
        } else {
            print("⚠️ [JanggiWebView] index.html 로컬 리소스를 찾을 수 없습니다.")
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 뷰 업데이트가 필요할 경우 여기에 작성
    }
}

