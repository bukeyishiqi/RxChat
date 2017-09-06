//
//  HttpClient.swift
//  MallMobile
//
//  Created by 陈琪 on 16/10/12.
//  Copyright © 2016年 Carisok. All rights reserved.
//

import Foundation
import Alamofire

/**
 *  根据RequestModel发起请求，取消请求
 */

public class HttpClient {
    
    /**
     *  网络状态处理
     */
    var isReachable: Bool { return  reachabilityManager.isReachable}
    var isReachableOnWWAN: Bool { return reachabilityManager.isReachableOnWWAN}
    var isReachableOnEthernetOrWiFi: Bool { return reachabilityManager.isReachableOnEthernetOrWiFi}
    
    private var reachabilityManager: NetworkReachabilityManager
    
    /** 请求列表， 根据requestid， 存放请求task*/
    var requestTable: [Int: Request] = [:]
    
    /** 根据requestID， 存储请求RequestSet*/
    var requestSetTable: [Int: RequestSet] = [:]
    
//    /** 续传下载, 根据requestID 存储resumeData*/
//    var resumeDataTable: [String: Data] = [:]
    
    /**
     *  client单例
     */
    public class var shareInstance: HttpClient {
        struct Static {
            static let instance : HttpClient = HttpClient.init()
        }
        return Static.instance
    }

    private init() {
        reachabilityManager = NetworkReachabilityManager()!
        reachabilityManager.startListening()
    }
    
    deinit {
        reachabilityManager.stopListening()
    }
    
    /**
     *  通过requestSet发起网络请求
     */
    func sendRequest(reqeustSet set: RequestSet) -> Int {
        var hash: Int = 0
        switch set.requestType {
        case .Get:
            hash = get(aUrlString: set.url, params: set.parameters, encode: URLEncoding.default, header: set.headers, completion: set.responseBlock)
            break
        case .Post:
            hash = post(aUrlString: set.url, params: set.parameters, encode: URLEncoding.default, header: set.headers, completion: set.responseBlock)
            break
        case .Upload:
            hash = upload(aUrlString: set.url, header: set.headers, resourcePath: set.dataFilePath!, progress: set.uploadProgress, completion: set.responseBlock)
            break
        case .Download:
            hash = download(aUrlString: set.url, params: set.parameters, header: set.headers, savePath: set.dataSavePath!, progress: set.downloadProgress, completion: set.responseBlock)
            break
        }
        HttpClient.shareInstance.requestSetTable[hash] = set
        return hash
    }
    
    
    /**
     *  继续下载
     */
    public func resume(requestID hashNumber: Int) {
        if let request = HttpClient.shareInstance.requestTable[hashNumber] {
            request.task?.resume()
        }
    }
    
    /** 
     *  暂停下载
     */
    public func pasue(requestID hashNumber: Int) {
        if let request = HttpClient.shareInstance.requestTable[hashNumber] {
            if request.task?.state == .running {
                request.task?.suspend()
            }
        }
    }
    
    /**
     *  根据hash number 取消请求
     */
    public func cancelRequest(requestID hashNumber: Int) {
        if let request = HttpClient.shareInstance.requestTable[hashNumber] {
            request.task?.cancel()
            HttpClient.shareInstance.requestTable.removeValue(forKey: hashNumber)
        }
    }
    
    /**
     *  根据列表取消请求
     */
    public func cancelRequestList(requestIDs list: [Int]) {
        for number in list {
            cancelRequest(requestID: number)
        }
    }
}


/**
 *  HTTP请求接口， 返回对应请求ID
 */
extension HttpClient {
    /** GET*/
    func get(aUrlString: String,
                    params: [String: Any]?,
                    encode: ParameterEncoding = URLEncoding.default,
                    header: HTTPHeaders? = nil,
                    completion: @escaping Completion) -> Int {
        return  request(aMethod: .get, urlString: aUrlString, params: params, encode: encode, header: header, completion: completion)
    }
    
    /** POST*/
    func post(aUrlString: String,
             params: [String: Any]?,
             encode: ParameterEncoding = URLEncoding.default,
             header: HTTPHeaders? = nil,
             completion: @escaping Completion) -> Int {
        return request(aMethod: .post, urlString: aUrlString, params: params, encode: encode, header: header, completion: completion)
    }
    
    /** 上传*/
    func upload(aUrlString: String,
                header: HTTPHeaders? = nil,
                resourcePath: String,
                progress: UploadProgress,
                completion: @escaping Completion) -> Int {

       let request = Alamofire.upload(URL.init(fileURLWithPath: resourcePath), to: aUrlString, method: .post, headers: header).uploadProgress { (progress) in
        
        }
        .responseJSON { (responseData) in
            let result: Result = responseData.result
            if result.isSuccess {
                print("*****上传成功：\(result.value)")
                completion(result.value, result.error)
            } else {
                print("*****上传失败：\(result.error?.localizedDescription)")

            }
        }
        
        /** 保存请求*/
        HttpClient.shareInstance.requestTable[(request.task?.taskIdentifier)!] = request

        return (request.task?.taskIdentifier)!
    }
    
    /** 下载*/
    func download(aUrlString: String,
                  params: [String: Any]?,
                  header: HTTPHeaders? = nil,
                  savePath: String,
                  progress: DownloadProgress,
                  completion: @escaping Completion) -> Int {

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (NSURL.fileURL(withPath: savePath), [.removePreviousFile, .createIntermediateDirectories]) /** 下载存储路径设置*/
        }
        
         // 新任务下载
         let request = Alamofire.download(aUrlString, method: .post, parameters: params, encoding: URLEncoding.default, headers: header, to: destination).downloadProgress(closure: { (progress) in
                /** 进度设置*/
            
            }).responseJSON(completionHandler: { (responseData) in
                let result: Result = responseData.result
                if result.isSuccess {
                    print("*****上传成功：\(result.value)")
                    completion(result.value, result.error)
                } else {
                    print("*****上传失败：\(result.error?.localizedDescription)")
                }

            })

        /** 保存请求*/
        HttpClient.shareInstance.requestTable[(request.task?.taskIdentifier)!] = request

        return (request.task?.taskIdentifier)!
    }
    
    // MARK: 普通HTTP请求接口
    private func request(aMethod: HTTPMethod = .get,
                         urlString: String,
                         params: [String: Any]?,
                         encode: ParameterEncoding = URLEncoding.default,
                         header: HTTPHeaders? = nil,
                         completion: @escaping Completion) -> Int {
    
        let request = Alamofire.request(urlString, method:aMethod, parameters: params, encoding: encode, headers: header).validate()
        /** 保存请求*/
        HttpClient.shareInstance.requestTable[(request.task?.taskIdentifier)!] = request

        request.responseJSON(completionHandler: { (responseData) in
            /** 完成后删除保存数据*/
            HttpClient.shareInstance.requestSetTable.removeValue(forKey: (request.task?.taskIdentifier)!)
            
            let result: Result = responseData.result
            if result.isSuccess {
                print("*****请求成功：\(result.value)")
                completion(result.value, result.error)
            } else {
                if let error = result.error {
                
                    print("*****请求失败：\(result.error?.localizedDescription)")
                    
                }
            }
        })
        return (request.task?.taskIdentifier)!
    }

}











