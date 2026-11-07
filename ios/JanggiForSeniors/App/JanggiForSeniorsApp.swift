//
//  JanggiForSeniorsApp.swift
//  청춘 장기 (Janggi for Seniors) - 시니어 맞춤형 효도 장기
//
//  앱 라이프사이클 및 네이티브 시니어 시스템 환경설정
//

import SwiftUI
import AVFoundation

@main
struct JanggiForSeniorsApp: App {
    init() {
        // 1. 어르신 장고(長考) 배려 화면 꺼짐 방지
        UIApplication.shared.isIdleTimerDisabled = true

        // 2. 무음 모드(Silent Switch) 상태에서도 장기 착수음과 TTS 음성이 나오도록 오디오 세션 설정
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ [JanggiForSeniorsApp] AVAudioSession 설정 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 눈이 침침하신 어르신들을 위한 명확하고 따뜻한 원목 라이트 테마 고정
                .preferredColorScheme(.light)
        }
    }
}

