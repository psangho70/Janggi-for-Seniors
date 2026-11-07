//
//  NativeBridgeHandler.swift
//  청춘 장기 (Janggi for Seniors) - 시니어 맞춤형 효도 장기
//
//  자바스크립트(웹)와 iOS 네이티브 간 고음질 한국어 TTS 및 Taptic Engine 햅틱 브릿지
//

import Foundation
import WebKit
import AVFoundation
import UIKit

class NativeBridgeHandler: NSObject, WKScriptMessageHandler {
    private let speechSynthesizer = AVSpeechSynthesizer()

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "iosBridge",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            return
        }

        switch action {
        case "speak":
            if let text = body["text"] as? String {
                speakKorean(text: text)
            }
        case "haptic":
            let style = body["style"] as? String ?? "medium"
            triggerHaptic(style: style)
        case "stopTTS":
            stopSpeaking()
        default:
            break
        }
    }

    // MARK: - 시니어 맞춤 고음질 한국어 TTS
    private func speakKorean(text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 기존 발화가 진행 중이면 즉각 정지 후 새 안내 발화
            if self.speechSynthesizer.isSpeaking {
                self.speechSynthesizer.stopSpeaking(at: .immediate)
            }

            let utterance = AVSpeechUtterance(string: text)
            // 한국어 음성 설정
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
            // 어르신 귀에 또렷하게 꽂히는 0.45배속 (표준보다 약간 차분하고 또렷함)
            utterance.rate = 0.45
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0

            self.speechSynthesizer.speak(utterance)
        }
    }

    private func stopSpeaking() {
        DispatchQueue.main.async { [weak self] in
            self?.speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - 묵직한 Taptic Engine 원목 착수 손맛
    private func triggerHaptic(style: String) {
        DispatchQueue.main.async {
            switch style {
            case "light":
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            case "heavy":
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()
            case "rigid":
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.prepare()
                generator.impactOccurred()
            case "warning":
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.warning)
            default: // "medium"
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }
}

