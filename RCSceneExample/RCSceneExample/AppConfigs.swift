//
//  AppConfigs.swift
//  RCE
//
//  Created by shaoshuai on 2022/3/24.
//

import RCSceneRoom

class AppConfigs {
    static func config() {
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
        Environment.hiFiveAppId = "6f78321c38ee4db3bb4dae7e56d464b1"
        Environment.hiFiveServerCode = "ca41ad68e8054610a2"
        Environment.hiFiveServerVersion = "V4.1.2"
    }
    
    static func configBusinessToken() {
        Environment.businessToken = "vStHYPdrQoImm-7Ur0ks1g"
    }
}
