<h1 align="center"> 场景化视频直播 </h>

<p align="center">
<a href="https://github.com/rongcloud/rongcloud-scene-video-room-ios">
<img src="https://img.shields.io/cocoapods/v/RCSceneVideoRoom.svg?style=flat">
</a>

<a href="https://github.com/rongcloud/rongcloud-scene-video-room-ios">
<img src="https://img.shields.io/cocoapods/l/RCSceneVideoRoom.svg?style=flat">
</a>

<a href="https://github.com/rongcloud/rongcloud-scene-video-room-ios">
<img src="https://img.shields.io/cocoapods/p/RCSceneVideoRoom.svg?style=flat">
</a>

<a href="https://github.com/rongcloud/rongcloud-scene-video-room-ios">
<img src="https://img.shields.io/badge/%20in-swift%205-orange.svg">
</a>

</p>

## 简介
本仓库是基于 RCLiveVideoLib 实现视频直播的开源代码，主要功能有多人连麦、麦位管理、房间管理、礼物、消息等。

## 集成

### 使用 CocoaPods
1. 终端 cd 至项目根目录
2. 执行 pod init
3. 执行 open -e Podfile
4. 添加导入配置 pod 'RCSceneVideoRoom'
5. 执行 pod install
6. 双击打开 .xcworkspace

### 初始化和连接
视频直播依赖于融云 IM，需要再使用前初始化和连接 IM：

```
func connection() {
        if RCIM.shared().getConnectionStatus() == .ConnectionStatus_Connected {
            return
        }
        guard let token = UserDefaults.standard.rongToken() else {
            return performSegue(withIdentifier: "Login", sender: nil)
        }
        RCIM.shared().initWithAppKey(Environment.rcKey)
        RCIM.shared().connect(withToken: token) { code in
            debugPrint("RCIM db open failed: \(code.rawValue)")
        } success: { userId in
            debugPrint("userId: \(userId ?? "")")
            self.refresh()
        } error: { errorCode in
            debugPrint("RCIM connect failed: \(errorCode.rawValue)")
        }
    }
```

### 创建房间

房间一般由服务器维护，开发者可以调用服务器接口创建房间，可以参考仓库里的 demo 创建房间：
```
let controller = RCVideoRoomController()
/// 采用 Coordinator 实现路由
let _ = VideoRoomCoordinator(rootViewController: navigationController!)
navigationController?.pushViewController(controller, animated: true)
```

### 加入房间

通过接口获取房间列表，选择需要加入的房间，展示直播页面：
```
let controller = RCVideoRoomController(room: rooms[indexPath.row])
navigationController?.pushViewController(controller, animated: true)
```

## 功能
模块           |  简介 |  示图
:-------------------------:|:-------------------------:|:-------------------------:
<span style="width:200px">音视频直播</span> | 音视频发送和接收，聊天室消息发送和展示，<br/>房间内观众连麦，支持最多 8 个观众连麦  |  <img width ="200" src="https://tva1.sinaimg.cn/large/e6c9d24ely1h186gzefevj20an0ir0ua.jpg">
房间音乐 | 基于 Hifive 实现音乐播放，需开通相关业务  |  <img width="200" src="https://tva1.sinaimg.cn/large/e6c9d24ely1h182xszyydj20af0ijq3v.jpg">
赠送礼物 | 支持单人、多人、全服礼物发送，需二次开发对接业务  |  <img width ="200" src="https://tva1.sinaimg.cn/large/e6c9d24ely1h186lx67e3j20af0ijq41.jpg">
房间设置 | 包含常见的房间信息管理  |  <img width ="200" src="https://tva1.sinaimg.cn/large/e6c9d24ely1h186mlgn5jj20an0irwf9.jpg">
布局切换 | 支持 7 种内置布局切换  |  <img width ="200" src="https://tva1.sinaimg.cn/large/e6c9d24ely1h186n95ewtj20an0irgm5.jpg">
跨房间PK | 支持 1v1 跨房间 PK，需要配合服务器实现  |  <img width ="200" src="https://tva1.sinaimg.cn/large/e6c9d24ely1h186nzphnvj20an0ir3zx.jpg">

## 其他
如有任何疑问请提交 issue
