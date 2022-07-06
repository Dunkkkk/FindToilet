//
//  NetwrokService.swift
//  StudyForMVVM
//
//  Created by changgyo seo on 2022/07/04.
//

import Foundation
import UIKit
import Alamofire
import RxSwift
import RxCocoa
import CoreLocation

class NetWorkService{
    static let shared = NetWorkService()
    
    static func makeParameter(_ currentLoacation: CLLocation ,_ query: String, _ distance: Int) -> Parameters {
        return ["query" : query ,
                "x" : currentLoacation.coordinate.longitude,
                "y" : currentLoacation.coordinate.latitude,
                "radius" : distance]
    }
    
    static func loadPOIData(_ currentLoacation: CLLocation ,_ query: String, _ distance: Int) -> Observable<[Document]> {
        return Observable.create { emitter in
            load(currentLoacation, query, distance){ ResponsData in
                switch ResponsData {
                case .success(let doc):
                    emitter.onNext(doc.documents)
                    emitter.onCompleted()
                case .requestErr(_):
                    emitter.onError(GyoError.unknown)
                    print("requestErr")
                case .pathErr:
                    print("pathErr")
                    emitter.onError(GyoError.unknown)
                case .serverErr:
                    emitter.onError(GyoError.unknown)
                case .networkFail:
                    emitter.onError(GyoError.unknown)
                }
            }
            return Disposables.create()
        }
    }
        
        static func load(_ currentLoacation: CLLocation ,_ query: String, _ distance: Int, completion : @escaping (NetworkResult<DocRes>) -> Void) {
            let url: String = ApiContants.baseURL + ApiContants.keyWordSearchingURL
            let dataRequest = AF.request(url,
                                         method: .get,
                                         parameters: makeParameter(currentLoacation, query, distance),
                                         headers: ApiContants.makeHeader())
            dataRequest.responseData { dataResponse in
                switch dataResponse.result {
                case .success:
                    guard let statusCode = dataResponse.response?.statusCode else {return}
                    guard let value = dataResponse.value else {return}
                    let networkResult = judgeStatus(by: statusCode, value)
                    completion(networkResult)
                case .failure: completion(.pathErr)
                }
            }
            
        }
        
        static func judgeStatus(by statusCode: Int, _ data: Data) -> NetworkResult<DocRes> {
            let decoder = JSONDecoder()
            guard let decodedData = try? decoder.decode(DocRes.self, from: data)
            else {
                return .pathErr}
            switch statusCode {
            case 200: return .success(decodedData)
            case 400: return .requestErr(decodedData)
            case 500: return .serverErr
            default: return .networkFail
            }
        }
    }
    
    enum GyoError: Error {
        case unknown
        
    }
