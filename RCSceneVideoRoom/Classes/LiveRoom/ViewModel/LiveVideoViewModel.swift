//
//  LiveVideoViewModel.swift
//  RCE
//
//  Created by 叶孤城 on 2021/9/8.
//

import UIKit

import RCSceneRoom

let roomThumbImages = [
    RCSCAsset.Images.roomBackgroundImage1.image,
    RCSCAsset.Images.roomBackgroundImage2.image,
    RCSCAsset.Images.roomBackgroundImage3.image,
    RCSCAsset.Images.roomBackgroundImage4.image,
    RCSCAsset.Images.roomBackgroundImage5.image,
    RCSCAsset.Images.roomBackgroundImage6.image
]

struct CreateLiveVideoRoomState {
    var isPrivate = true
    var password = ""
    var roomName = ""
    var roomThumbImage: UIImage?
    
    var needInputPassword: Bool {
        return isPrivate && password.count == 0
    }
}

final class LiveVideoViewModel {
    var createState = CreateLiveVideoRoomState()
    
    func create(_ completion: @escaping (Result<RCSceneWrapper<RCSceneRoom>, NetError>) -> Void) {
        guard createState.roomName.count > 0 else {
            return completion(.failure(NetError("请输入房间名称")))
        }
        guard let image = createState.roomThumbImage else {
            return completion(.failure(NetError("请选择房间图标")))
        }
        if createState.needInputPassword {
            return completion(.failure(NetError("请输入密码")))
        }
        
        let name = createState.roomName
        let isPrivate = createState.isPrivate ? 1 : 0
        let password = createState.password
        upload(image) { [weak self] result in
            switch result {
            case let .success(path):
                self?.create(name,
                       isPrivate: isPrivate,
                       password: password,
                       path: path,
                       completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func upload(_ image: UIImage, completion: @escaping (Result<String, NetError>) -> Void) {
        videoRoomService.upload(data: image.jpegData(compressionQuality: 0.5)!) { result in
            switch result.map(RCSceneWrapper<String>.self) {
            case let .success(response):
                guard let path = response.data else {
                    return completion(.failure(NetError("上传文件失败")))
                }
                let urlString = Environment.url.absoluteString + "/file/show?path=" + path
                completion(.success(urlString))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func create(_ name: String,
                        isPrivate: Int,
                        password: String,
                        path: String,
                        completion: @escaping (Result<RCSceneWrapper<RCSceneRoom>, NetError>) -> Void) {
        videoRoomService.createRoom(name: name, themePictureUrl: path, backgroundUrl: "", kv: [], isPrivate: isPrivate, password: password, roomType: 3) { result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(wrapper):
                completion(.success(wrapper))
                if let room = wrapper.data {
                    RCSensorAction.createRoom(room, enableMic: true, enableCamera: true).trigger()
                }
            case let .failure(error):
                completion(.failure(NetError(error.localizedDescription)))
            }
        }
    }
}
