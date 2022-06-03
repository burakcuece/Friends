//
//  Find_my_FriendsApp.swift
//  Find my Friends
//
//  Created by Burak Cüce on 19.05.22.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct Find_my_FriendsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup() {
            
            TabView {
                
                MapView()
                    .tabItem {
                        Label("Karte", systemImage: "map.fill")
                    }
                
                FindFriendView()
                    .tabItem {
                        Label("Freunde Finden", systemImage: "person.2.fill")
                    }
                ChatView()
                    .tabItem {
                        Label("Nachrichten", systemImage: "message.fill")
                    }
                
            }
        }
    }
    
}

class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}
