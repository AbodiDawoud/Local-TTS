//
//  Local_TTSApp.swift
//  Local-TTS
    

import SwiftUI

@main
struct Local_TTSApp: App {
    let player = TTSPlayer()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(player)
        }
    }
}



extension UIApplication {
    var windowScene: UIWindowScene {
        self.connectedScenes.first as! UIWindowScene
    }
}

extension UIWindow {
    static var controller: UIViewController {
        let key = UIApplication.shared.windowScene.keyWindow!
        return key.rootViewController!
    }
}

extension Int {
    var str: String { String(self) }
}
