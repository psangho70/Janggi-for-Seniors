//
//  ContentView.swift
//  청춘 장기 (Janggi for Seniors) - 시니어 맞춤형 효도 장기
//
//  아이폰 & 아이패드 유니버설 Safe Area 최적화 루트 뷰
//

import SwiftUI

struct ContentView: View {
    // 시니어 친화 원목 베이지 컬러 (#F7EBD3)
    private let woodBeige = Color(red: 247/255, green: 235/255, blue: 211/255)

    var body: some View {
        ZStack {
            // 배경색을 Safe Area 전체(상단 상태바, 하단 홈바)로 확장하여 일체감 형성
            woodBeige
                .ignoresSafeArea()

            // 메인 장기판 웹뷰
            JanggiWebView()
                .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    ContentView()
}

