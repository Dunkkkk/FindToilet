//
//  ApIConstant.swift
//  StudyForMVVM
//
//  Created by changgyo seo on 2022/07/04.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation

struct ApiContants{
    static func makeHeader() -> HTTPHeaders{
        return ["Authorization" : "KakaoAK 5f19a19bb386f2aa329de04bc6340fdb"]
    }
    
    static let baseURL = "https://dapi.kakao.com/"
    static let keyWordSearchingURL = "v2/local/search/keyword.json"
}


enum NetworkResult<T>{
    case success(T)
    case requestErr(T)
    case pathErr
    case serverErr
    case networkFail
}
