//
//  Speecher.swift
//  BoardRidingAnalyzer
//
//  Created by koyanagi on 2023/10/17.
//

import Foundation
import AVFoundation

class Speecher {
    static func speeche(text: String) {
        // AVSpeechSynthesizerのインスタンス作成
        let speechSynthesizer = AVSpeechSynthesizer()
        // 読み上げる、文字、言語などの設定
        let utterance = AVSpeechUtterance(string: text) // 読み上げる文字
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP") // 言語
        utterance.rate = 1 // 読み上げ速度
        utterance.pitchMultiplier = 1.0 // 読み上げる声のピッチ
        utterance.preUtteranceDelay = 0.0 // 読み上げるまでのため
        utterance.postUtteranceDelay = 0.0
        
        speechSynthesizer.speak(utterance)
    }
}
