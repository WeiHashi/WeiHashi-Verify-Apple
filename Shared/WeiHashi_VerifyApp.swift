//
//  WeiHashi_VerifyApp.swift
//  Shared
//
//  Created by kangguanghui on 2022/2/15.
//

import SwiftUI

#if os(macOS)
class AppDelegate:NSObject,NSApplicationDelegate{
    
}
#endif

@main
struct WeiHashi_VerifyApp: App {
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 300, height: 200)
                .navigationTitle("微哈师授权工具")
                .onDisappear(perform: {
                    exit(0)
                })
        }
    }
}
