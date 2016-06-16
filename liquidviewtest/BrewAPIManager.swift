//
//  BrewAPIManager.swift
//  liquidviewtest
//
//  Created by Songyee Park on 14/6/2016.
//  Copyright © 2016 nbition. All rights reserved.
//

import Foundation
import Alamofire

class BrewAPIManager {
    
    let domain = "http://ARIST_0002:3000/"
    let checkBrewPath = "bp/"
    let startBrewPath = "br/"
    let stopBrewPath = "bs/"
    
    func checkBrewProgress(brewId: String, completion: ((isSuccess:Bool, response:AnyObject)-> Void)) {
        let requestString = domain + checkBrewPath
        let param = ["brewId": brewId]
        sendStandardPostRequest(requestString, param: param) { (isSuccess, response) in
            if isSuccess {
                completion(isSuccess: isSuccess, response: response)
            } else {
                print("Could not call checkBrew")
            }
        }
    }
    
    func startBrew(brewSetting: NSArray, brewId: String, recipeId: String, outcomeId: String, userId: String, completion: ((isSuccess: Bool, response: AnyObject)-> Void)) {
        let requestString = domain + startBrewPath
        let param = ["settings": brewSetting, "recipeId": recipeId, "outcomeId": outcomeId, "user": userId, "brewId": brewId]
        sendStandardPostRequest(requestString, param: param) { (isSuccess, response) in
            if isSuccess {
                completion(isSuccess: isSuccess, response: response)
            } else {
                print("Could not call startBrew")
            }
        }
    }
    
    func stopBrew(brewId: String, completion: ((isSuccess: Bool, response: AnyObject) -> Void)) {
        let requestString = domain + stopBrewPath
        let param = ["brewId": brewId]
        sendStandardPostRequest(requestString, param: param) { (isSuccess, response) in
            if isSuccess {
                completion(isSuccess: isSuccess, response: response)
            } else {
                print("Could not call stopBrew")
            }
        }
    }
    
    struct Static {
        static let instance = BrewAPIManager()
    }
    
    class var sharedInstance: BrewAPIManager {
        return Static.instance
    }
    
    private let curSessionUUID = NSUUID().UUIDString
    
    private func sendStandardGetRequest(urlString:String, completion:((isSuccess:Bool, response:AnyObject)-> Void)){
        sendStandardGetRequest(urlString, parameters: nil, completion: completion)
    }
    
    private func sendStandardGetRequest(urlString:String,parameters:NSDictionary?, completion:((isSuccess:Bool, response:AnyObject)-> Void)){
        let encoding = Alamofire.ParameterEncoding.JSON
        
        var sendingParam = parameters as? [String : AnyObject]
        if var params = parameters as? [String : AnyObject]{
            params["Arist-Session-Id"] = curSessionUUID
            sendingParam = params
        }
        
        
        Alamofire.request(.GET, urlString, parameters: sendingParam, encoding: encoding, headers: nil).validate(statusCode: 200..<300).responseJSON {response in
            do{
                var statusCode = 400
                
                if let responseCode = response.response?.statusCode{
                    statusCode = responseCode
                    print ("APIManager:Standard GET \nurl: \(urlString) \n response statusCode:\(statusCode)")
                }else if  let httpError = response.result.error {
                    statusCode = httpError.code
                    ("APIManager:Standard GET \nurl: \(urlString) \n httpError errorCode:\(statusCode) \n body:\(response)")
                } else {
                    
                }
                //TODO: -Do something with the status code
                let result = response.result
                let isSuccess = result.isSuccess
                
                switch result{
                case .Success:
                    //Cache the response
                    if let urlResponse = response.response, data = response.data, let request = response.request{
                        let cachedResponse = NSCachedURLResponse(response: urlResponse, data: data, userInfo: ["cachedDate":NSDate()], storagePolicy: .Allowed)
                        NSURLCache.sharedURLCache().storeCachedResponse(cachedResponse, forRequest:request )
                    }
                    
                    if statusCode == ServerStatusCode.NO_CONTENT{
                        completion(isSuccess: isSuccess, response: [])
                    }else{
                        let responseData = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.AllowFragments)
                        completion(isSuccess: isSuccess, response: responseData)
                    }
                    
                    break
                case .Failure(_):
                    //TODO: - Error handling
                    
                    completion(isSuccess: false, response: self.turnServerStatusCodeIntoAppErrorCode(statusCode))
                    break
                }
                
                
            }catch{
                
                completion(isSuccess: false, response: AppErrorCode.CAUGHT_UNKNOWN_EXECPTION)
            }
        }
        
    }
    
    private func sendStandardPostRequest(requestStr:String, param:NSDictionary,completion:((isSuccess:Bool, response:AnyObject)-> Void)){
        let encoding = Alamofire.ParameterEncoding.JSON
        var sendingParam = param as? [String : AnyObject]
        if let params = param as? [String : AnyObject]{
            //params["Arist-Session-Id"] = curSessionUUID
            sendingParam = params
        }
        
        Alamofire.request(.POST, requestStr, parameters: sendingParam, encoding: encoding, headers: nil).validate(statusCode: 200..<300).responseJSON {response in
            do{
                let result = response.result
                var isSuccess = true
                switch result{
                case .Success:
                    
                    break
                case .Failure(_):
                    isSuccess = false
                    break
                }
                
                let responseData = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.AllowFragments)
                completion(isSuccess: isSuccess, response: responseData)
            }catch{
                print("ERROR: \(error)")
            }
            
        }
    }


    
    private func turnServerStatusCodeIntoAppErrorCode(statusCode:Int)->String{
        switch statusCode{
        case ServerStatusCode.BAD_REQUEST:
            return AppErrorCode.API_BAD_REQUEST
        case ServerStatusCode.NO_CONTENT:
            break
        case ServerStatusCode.PAGE_NOT_FOUND:
            return AppErrorCode.API_PAGE_NOT_FOUND
        case ServerStatusCode.UNAUTHORIZED:
            return AppErrorCode.API_UNAUTHORIZED
        default:
            break
        }
        return AppErrorCode.CAUGHT_UNKNOWN_EXECPTION
    }

    
    
}

struct ServerStatusCode{
    static let NO_CONTENT = 204
    static let BAD_REQUEST = 400
    static let UNAUTHORIZED = 401
    static let PAGE_NOT_FOUND = 404
    static let OK = 200
    static let INTERNAL_SERVER_ERROR = 500
}

struct AppErrorCode{
    static let Setup_BT_MethodNotFound = "E04001"
    static let Setup_BT_DataArrayNotFound = "E04002"
    static let Setup_WF_HandshakeFailed = "E04003"
    static let WF_BrewFailed = "E04004"
    static let Setup_BT_TIMEOUT = "E04005"
    
    static let Setup_BT_LostConnection = "E----"
    static let CAUGHT_UNKNOWN_EXECPTION = "E00001"
    static let API_SERVER_INTERNAL_ERROR = "E00500"
    static let API_BAD_REQUEST = "E00400"
    static let API_UNAUTHORIZED = "E00401"
    static let API_PAGE_NOT_FOUND = "E00404"
    
}