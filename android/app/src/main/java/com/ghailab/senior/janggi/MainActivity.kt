package com.ghailab.senior.janggi

import android.annotation.SuppressLint
import android.graphics.Color
import android.media.AudioManager
import android.os.Bundle
import android.view.WindowManager
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import android.widget.FrameLayout
import android.speech.tts.TextToSpeech
import java.util.Locale

class MainActivity : ComponentActivity(), TextToSpeech.OnInitListener {

    private lateinit var webView: WebView
    private var backPressedTime: Long = 0
    private var tts: TextToSpeech? = null

    // 자바스크립트와 연동되는 고음질 네이티브 한국어 TTS 브릿지
    inner class AndroidTTSBridge {
        @JavascriptInterface
        fun speak(text: String) {
            tts?.let {
                if (it.isSpeaking) it.stop()
                it.setSpeechRate(0.9f) // 시니어 맞춤 0.9배속의 또렷한 음성
                it.speak(text, TextToSpeech.QUEUE_FLUSH, null, "JANGGI_TTS")
            }
        }

        @JavascriptInterface
        fun stop() {
            tts?.stop()
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale.KOREAN
            tts?.setSpeechRate(0.9f)
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 1. 어르신 장고(長考) 배려 화면 꺼짐 방지
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        // 2. 스마트폰 볼륨 버튼 누를 시 미디어 음량 즉각 제어
        volumeControlStream = AudioManager.STREAM_MUSIC

        // 3. 상태바/내비게이션바 시각 최적화 (어르신 눈이 편안한 원목 베이지 톤 & 다크 아이콘)
        window.statusBarColor = Color.parseColor("#F7EBD3")
        window.navigationBarColor = Color.parseColor("#EBDAB8")
        WindowInsetsControllerCompat(window, window.decorView).apply {
            isAppearanceLightStatusBars = true
            isAppearanceLightNavigationBars = true
        }

        // 4. 네이티브 한국어 TTS 엔진 초기화
        tts = TextToSpeech(this, this)

        // 5. WebView 생성 및 시니어 최적화 세팅
        webView = WebView(this).apply {
            setBackgroundColor(Color.parseColor("#F7EBD3"))

            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                databaseEnabled = true
                useWideViewPort = true
                loadWithOverviewMode = true
                setSupportZoom(false)
                displayZoomControls = false
                mediaPlaybackRequiresUserGesture = false
                cacheMode = WebSettings.LOAD_NO_CACHE
                allowFileAccess = true
                allowContentAccess = true

                // 스마트폰 시스템 글자 크기(150%~200%) 강제 확대를 100% 무시하고 앱 고유의 큰글씨 황금 레이아웃으로 독립 고정
                textZoom = 100
            }

            clearCache(true)

            // 자바스크립트 브릿지 등록
            addJavascriptInterface(AndroidTTSBridge(), "AndroidBridge")

            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
                    return false
                }
            }

            webChromeClient = WebChromeClient()

            loadUrl("file:///android_asset/index.html")
        }

        // 6. 상단 상태바 및 하단 내비게이션 바(소프트키) 겹침 방지 루트 컨테이너
        val rootContainer = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#F7EBD3"))
            addView(
                webView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        }
        setContentView(rootContainer)

        // 시스템 인셋 리스너: 상태바 높이 및 소프트키 높이만큼 컨테이너 패딩 적용 (겹침 원천 차단)
        ViewCompat.setOnApplyWindowInsetsListener(rootContainer) { view, windowInsets ->
            val systemBars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            view.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            windowInsets
        }

        // 6. 어르신 실수 방지: 뒤로가기 버튼 2회 터치 종료
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                if (webView.canGoBack()) {
                    webView.goBack()
                } else {
                    if (System.currentTimeMillis() - backPressedTime < 2000) {
                        finish()
                    } else {
                        backPressedTime = System.currentTimeMillis()
                        Toast.makeText(
                            this@MainActivity,
                            "한 번 더 누르시면 청춘 장기가 종료됩니다.",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            }
        })
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
