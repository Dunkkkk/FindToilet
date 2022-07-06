//
//  CommonEnum.swift
//  StudyForMVVM
//
//  Created by changgyo seo on 2022/07/06.
//

import Foundation

struct POIParams: Equatable {
    let Documents: [Document]?
    let level: PooLevel?
    
    init(_ D: [Document], _ p: PooLevel) {
        Documents = D
        level = p
    }
    
    static func == (lhs: POIParams, rhs: POIParams) -> Bool {
        var temp = true
        lhs.Documents?.forEach { i in
            if ((rhs.Documents?.contains(i)) ?? false == false)  {  temp = false }
        }
        return temp && lhs.level == rhs.level
    }
    
}

enum PooLevel : Equatable{
    case Little
    case Soso
    case IcantAnyMore
    case Legend
    
    init(_ f: Float){
        switch f {
            case 0...25:
                self = .Little
            case 25...50:
                self = .Soso
            case 50...75:
                self = .IcantAnyMore
            case 75...100:
                self = .Legend
            default:
                self = .Little
        }
    }
    
    var message: String{
        switch self {
        case .Legend:
            return "1초뒤 바지에 투하"
        case .IcantAnyMore:
            return "진짜 클났으요!!"
        case .Soso:
            return "후 일단을 참을 수 있겠어ㅡㅡ"
        case .Little:
            return "당장은 괜찮지만...."
        }
    }
    var query: String{
        switch self {
        case .Legend:
            return "카페"
        case .IcantAnyMore:
            return "식당"
        case .Soso:
            return "지하철역"
        case .Little:
            return "화장실"
        }
    }
    
    
    
    
}
