//
//  ContentView.swift
//  Shared
//
//  Created by kangguanghui on 2022/2/15.
//

import SwiftUI
import Foundation
import SystemConfiguration.CaptiveNetwork
import AdSupport
import AppTrackingTransparency

struct ContentView: View {
    @State private var txt="请确保设备已正常联网\n正在获取设备信息……"
    
    var body: some View {
        Text(txt)
            .padding()
#if os(iOS)
            .frame(width: 300, height: nil, alignment: Alignment.center)
#endif
            .minimumScaleFactor(0.3)
            .onAppear(perform: {
#if os(iOS)
                if #available(iOS 14,*) {
                    self.requestIDFAPermission()
                }else{
                    self.requestApi()
                }
#else
                self.requestApi()
#endif
            })
    }
    
    private func requestApi(){
        txt.append(contentsOf: "\n正在验证授权")
#if os(macOS)
        let mac=getMacAddress()
#else
        let mac=ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print(mac)
        if mac=="" || mac=="00000000-0000-0000-0000-000000000000" {
            txt.append(contentsOf: "\n获取设备信息失败,请检查系统设置或更换设备重试")
            delayFinish()
            return
        }
#endif
        let url = URL(string: "https://devmeteor.cn:8080/suVerifyDevice?hostName=mac%20device&mac=\(mac)")!
        let urlRequest = URLRequest(url:url)
        URLSession.shared.dataTask(with: urlRequest){(data,response,error) in
            if let data = data,
               let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode
            {
                let response=try! JSONDecoder().decode(Response.self, from: data)
                print(response.msg)
                txt.append(contentsOf: "\n\(response.msg)")
            }else{
                txt.append(contentsOf: "\n授权失败，请稍后重试")
            }
            delayFinish()
        }.resume()
    }
    
    private func delayFinish(){
        txt.append(contentsOf: "\n5秒后将自动关闭")
        DispatchQueue.global().asyncAfter(deadline: .now()+5){
            exit(0)
        }
    }
    
    private func requestIDFAPermission(){
        ATTrackingManager.requestTrackingAuthorization{(status) in
            switch status{
            case .denied:
                print("拒绝")
                txt.append(contentsOf: "\n请求跟踪未被允许，请前往设置允许授权工具请求跟踪")
                delayFinish()
                break
            case .authorized:
                print("允许")
                requestApi()
                break
            case .notDetermined:
                print("没选择")
                txt.append(contentsOf: "\n请求跟踪未被允许，请前往设置允许授权工具请求跟踪")
                delayFinish()
                break
            default:
                break
            }
        }
    }
    
    struct Response :Codable{
        let code:Int
        let msg:String
        
        enum CodingKeys:String,CodingKey{
            case code
            case msg
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#if os(macOS)
@discardableResult
private func getMacAddress()->String{
    let task=Process()
    task.launchPath = "/bin/bash"
    task.arguments=["-c","ifconfig en0 | grep ether' ' | cut -d' ' -f 2"]
    let pipe=Pipe()
    task.standardOutput=pipe
    task.launch()
    task.waitUntilExit()
    let data=pipe.fileHandleForReading.readDataToEndOfFile()
    let output:String=NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    as! String
    return output.replacingOccurrences(of: "\n", with: "")
}
#endif
