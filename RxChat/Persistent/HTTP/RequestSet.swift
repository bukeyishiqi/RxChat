//
//  RequestSet.swift
//  MallMobile
//
//  Created by 陈琪 on 16/10/12.
//  Copyright © 2016年 Carisok. All rights reserved.
//

import Foundation

public typealias UploadProgress = (_ bytesReceived: Int64, _ totalBytesReceived: Int64, _ totalBytesExpectedToReceive: Int64) -> Void

public typealias DownloadProgress = (_ bytesSend: Int64,_ totalBytesSend: Int64,_ totalBytesExpectedToSend: Int64) -> Void

public typealias Completion = (_ responseData: Any,_ error: Error?)->Void

//public typealias Failure = (Error)->Void

/**
 *  网络请求方式
 */
public enum RequestType: Int {
    case Get, Post, Upload, Download
}


/**
 *  网络请求接口配置
 */
struct RequestSet {
    
    /** 网络请求完整地址*/
    var url: String
    /** 请求参数*/
    var parameters: [String: Any]?
    /** 请求头*/
    var headers: [String: String]?
    
//    /** 服务器标识*/
//    var server: Server
//    
    /** 网络请求方式*/
    var requestType: RequestType = .Get
    
    /** 请求着陆回调*/
    var responseBlock: Completion = {_,_ in }
    
    init(method: RequestType = .Get, url: String, _ params: [String: Any]? = nil, _ headers: [String: String]? = nil) {
        self.url = url
        self.requestType = method
        self.parameters = params
        self.headers = headers
    }
    
    mutating func configuration(resonseBlock: Completion? = nil) {
        if let respnse = resonseBlock {
            self.responseBlock = respnse
        }
    }
    
    /**
     *  上传、下载配置
     */
    
    var uploadProgress: UploadProgress = {_ in}
    var downloadProgress: DownloadProgress = {_ in }
    
    /** 上传文件获取路径*/
    var dataFilePath: String?
    var fileName: String?
    
    /** 下载文件保存路径*/
    var dataSavePath: String?
    
    mutating func uploadConfig(_ fileName: String? = nil, filePath: String, progress: UploadProgress? = nil, _ response: Completion? = nil) {
        self.fileName = fileName
        self.dataFilePath = filePath
        
        if let progress = progress {
            self.uploadProgress = progress
        }
        if let respnse = response {
            self.responseBlock = respnse
        }
    }
    
    mutating func downloadConfig(savePath: String, _ progress: DownloadProgress? = nil, _ response: Completion? = nil) {
        self.dataSavePath = savePath
        
        if let progress = progress {
            self.downloadProgress = progress
        }
        
        if let respnse = response {
            self.responseBlock = respnse
        }

    }
}



