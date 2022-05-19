//
//  AppConfigs.swift
//  RCE
//
//  Created by shaoshuai on 2022/3/24.
//

import RCSceneRoom

@objc
public class AppConfigs: NSObject {
    @objc
    public static func config() {
        configRCKey()
        configHiFive()
        configBaseURL()
        configMHBeautyKey()
        configBusinessToken()
    }
    
    static func configRCKey() {
        Environment.rcKey = "pvxdm17jpw7ar"
    }
    
    static func configBaseURL() {
        Environment.url = URL(string: "https://rcrtc-api.rongcloud.net/")!
    }
    
    static func configMHBeautyKey() {
        Environment.MHBeautyKey = ""
    }
    
    static func configHiFive() {
        Environment.hiFiveAppId = ""
        Environment.hiFiveServerCode = ""
        Environment.hiFiveServerVersion = ""
    }
    
    /// 请申请您的 BusinessToken：https://rcrtc-api.rongcloud.net/code
    static func configBusinessToken() {
        let path = Bundle.main.path(forResource: "ENV", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: path)
        Environment.businessToken = config?["businessToken"] as? String ?? ""
    }
}

@objc
public extension AppConfigs {
    static var appKey: String {
        return Environment.rcKey
    }
}
