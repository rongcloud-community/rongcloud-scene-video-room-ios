<h1 align="center"> 场景化聊天室 </h>

<p align="center">
<a href="https://github.com/rongcloud/rongcloud-scene-chatroomkit">
<img src="https://img.shields.io/cocoapods/v/RCSceneChatroomKit.svg?style=flat">
</a>

<a href="https://github.com/rongcloud/rongcloud-scene-chatroomkit">
<img src="https://img.shields.io/cocoapods/l/RCSceneChatroomKit.svg?style=flat">
</a>

<a href="https://github.com/rongcloud/rongcloud-scene-chatroomkit">
<img src="https://img.shields.io/cocoapods/p/RCSceneChatroomKit.svg?style=flat">
</a>

<a href="https://github.com/rongcloud/rongcloud-scene-chatroomkit">
<img src="https://img.shields.io/badge/%20in-swift%205-orange.svg">
</a>

</p>

## 简介
场景话聊天室 Kit 是融云为开发者提供的开源项目，适用于语聊房、电台语音、视频直播等常见社交场景，Kit 封装聊天室消息列表、底部功能栏、输入框等常见的 UI 组件，并且，开发者可以通过 JSON 配置文件自定义 UI 属性，也可以通过远端动态配置。

## 集成

### 使用 CocoaPods
1. 终端 cd 至项目根目录
2. 执行 pod init
3. 执行 open -e Podfile
4. 添加导入配置 pod 'RCSceneChatroomKit'
5. 执行 pod install
6. 双击打开 .xcworkspace

## 功能
场景化聊天室内部按功能分为三个部分：
- 消息列表
<img src= "https://tva1.sinaimg.cn/large/e6c9d24ely1h0e70qlxujj20ku112427.jpg"  height="375" alt="RCSceneChatroomKit">

- 功能栏
<img src= "https://tva1.sinaimg.cn/large/e6c9d24ely1h0e71gh5cwj20ku112422.jpg"  height="375" alt="RCSceneChatroomKit">

- 输入框：

<img src= "https://tva1.sinaimg.cn/large/e6c9d24ely1h0e71zhmqxj20ku112n03.jpg"  height="375" alt="RCSceneChatroomKit">

## 配置项

场景化聊天室可以通过 JSON 文件进行 UI 配置，开发者需要集成 `RCCoreKit`，将 JSON 配置内容写入 `RCCoreKitBundle` 里面的 `KitConfig.json` 文件，场景化聊天室支持的配置项如下

## 使用
### 消息列表
类名：RCChatroomSceneMessageView
#### 创建

```swift
var chatroomView = RCChatroomSceneView()

/// 对外提供的是一个 RCChatroomSceneView，内部持有 messageView ，类型是 RCChatroomSceneMessageView
var messageView = chatroomView.messageView

///设置消息点击事件代理
messageView.setEventDelegate(self)

/// layout
viewOfYourProject.addSubview(messageView)
chatroomView.messageView.snp.makeConstraints { make in
          ///.....
}
```

#### 文本消息展示

```
///上面创建的 messageView 对象调用：
messageView.addMessage(msg)

/// addMessage 是 OC 接口定义：
- (void)addMessage:(id<RCChatroomSceneMessageProtocol>)message;

///	消息对象 msg 要遵守 RCChatroomSceneMessageProtocol 协议：
@protocol RCChatroomSceneMessageProtocol <NSObject>
@optional

/// 气泡颜色
- (UIColor *)bubbleColor;
/// 返回气泡文字颜色，返回 null 采用默认配置
- (UIColor *)bubbleTextColor;
/// 返回气泡文字颜色，返回 null 采用默认配置
- (RCConner *)bubbleCorner;
 
/// 点击事件，eventRange:eventId
/// eventRange：标记事件在 attributeString 中的位置
/// eventId：事件标记，比如：用户 ID、礼物 ID 等
- (NSDictionary<NSValue *, NSString *> *)events;

/// 富文本消息体
- (NSAttributedString *)attributeString;
@end
```


#### 语音消息展示

RCChatroomSceneVoiceMessage 遵守 RCChatroomSceneMessageProtocol 
因此构建消息对象 msg 同时也继承了 RCChatroomSceneMessageProtocol 里面的属性，
也需要去实现协议里对应的方法，返回相关的属性值。

```
///	上面创建的 messageView 对象调用：
messageView.addMessage(msg)

///	这里的语音消息对象 msg 要遵守 RCChatroomSceneVoiceMessage 协议
@protocol RCChatroomSceneVoiceMessage <RCChatroomSceneMessageProtocol>
/// 语音文件本地路径
- (NSString *)voicePath;

/// 语音时长
- (long)voiceDuration;
@end
```

#### 事件响应
```
/// 第1步（创建）里面设定的事件代理对象：
messageView.setEventDelegate(self)

setEventDelegate是Objective-C接口定义：
- (void)setEventDelegate:(id<RCChatroomSceneEventProtocol>)trackDelegate;

///这里的语音消息对象self要遵守RCChatroomSceneEventProtocol协议：
@protocol RCChatroomSceneEventProtocol <NSObject>
///得到消息bubble内容点击的回调，以及消息bubble所对应的UITableViewCell
- (void)cell:(UITableViewCell *)cell didClickEvent:(NSString *)eventId;
@end
```


### 工具栏
类名：RCChatroomSceneToolBar
#### 创建

```swift
/// 同创建 RCChatroomSceneMessageView 机理一样，RCChatroomSceneView 内部持有 RCChatroomSceneToolBar：
var chatroomView = RCChatroomSceneView()
var toolBar = chatroomView.toolBar

/// 设置代理对象
toolBar.delegate = self

/// layout
viewOfYourProject.addSubview(toolBar)
toolBar.snp.makeConstraints { make in
          ///.....
}
```

 
#### 配置 ToolBar按钮
`RCChatroomSceneToolBar` 横向包含三个部分：
- 左边唤起输入按钮
- 中间的按钮排列组(属性命名为 commonActions )
- 右边的按钮排列组(属性命名为 actions )

<img src= "https://tva1.sinaimg.cn/large/e6c9d24ely1h0e73k11stj20kq02ydga.jpg"  height="50" alt="RCSceneChatroomKit">

```
let button1 = YourDefinedUIButon（）
let button2 = YourDefinedUIButon（）
let button3 = YourDefinedUIButon（）
let button4 = YourDefinedUIButon（）

let config = RCChatroomSceneToolBarConfig.default()
/// 最左边唤起输入按钮，是否显示语音输入按钮
config.recordButtonEnable = true

///中间按钮排列组
config.commonActions = [button1, button2]

///右边的按钮排列组
config.actions = [button3, button4]
chatroomView.toolBar.setConfig(config)
```

**上面配置代码生效后，左边的输入唤起按钮会显示语音输入按钮，button1, button2从左到右依次构成中间排列组，button3, button4 从左到右依次构成右边排列组**

#### ToolBar发送文字代理回调

```
/// 文本输入点击发送后调用
/// @param text 文本内容
- (void)textInputViewSendText:(NSString *)text;
```

#### ToolBar 语音输入相关事件代理回调

```
/// 开始录音
- (void)audioRecordDidBegin;
/// 取消录音
- (void)audioRecordDidCancel;
/// 录音完成
/// @param NSData 音频文件
/// @param time 音频文件时长，单位：秒
- (void)audioRecordDidEnd:(nullable NSData *)data time:(NSTimeInterval)time;
```

## 其他
如有任何疑问请提交 issue
