//
//  MainViewModel.swift
//  StudyForMVVM
//
//  Created by changgyo seo on 2022/07/04.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import CoreLocation

struct MainViewModel {
    
    let disposBag = DisposeBag()
    typealias searchParam = (currentLoacation: CLLocation , query: String,distance: Int)
    //viewmodel -> view
    var POIDataList: Driver<[Document]>
    
    //view -> viewmodel
    let startLoad = PublishSubject<Void>()
    var currentLocation = BehaviorSubject<CLLocation>(value: CLLocation(latitude: 126.65752673, longitude: 37.45033226))
    var keyWord = BehaviorSubject<String>(value: "화장실")
    var distance = BehaviorSubject<Int>(value: 500)
    
    init() {
        
        let makeSearchParameterLatest = Observable
            .combineLatest(currentLocation, keyWord, distance)
            .take(1)
            .map{ searchParam($0,$1,$2) }
        
        POIDataList = startLoad
            .flatMap { _ -> Observable<(currentLoacation: CLLocation, query: String, distance: Int)> in
                return makeSearchParameterLatest
            }
            .flatMapLatest{ data -> Observable<[Document]> in
                return NetWorkService.loadPOIData(data.currentLoacation, data.query, data.distance)
            }
            .asDriver(onErrorJustReturn: [])
        
        //out
        
    }
    
}
