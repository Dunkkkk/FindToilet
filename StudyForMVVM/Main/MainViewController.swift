//
//  MainViewController.swift
//  StudyForMVVM
//
//  Created by changgyo seo on 2022/07/04.
//

import Foundation
import UIKit
import RxCocoa
import SnapKit
import RxRelay
import RxSwift
import CoreLocation
import SwiftUI

class MainViewController: UIViewController{
    let disposeBag = DisposeBag()
    
    //UI
    let pooslider: UISlider = {
        let temp = UISlider()
        temp.minimumValue = 0
        temp.maximumValue = 100
        
        return temp
    }()
    let backGroundView = UIView()
    let searchButton = UIButton()
    let pooLevelLabel = UILabel()
    var clLocationManager = CLLocationManager()
    let mapView = MTMapView()
    
    
    //Observers
    let currentLocation = PublishSubject<CLLocation>()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        
        bind()
        layout()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(_ viewModel: MainViewModel = MainViewModel()){
        
        searchButton.rx.tap
            .bind(to: viewModel.startLoad)
            .disposed(by: disposeBag)
        
        currentLocation
            .bind(to: viewModel.currentLocation)
            .disposed(by: disposeBag)
        
        pooslider.rx.value
            .asDriver()
            .filter {return $0 >= 0 || $0 <= 100}
            .map {  PooLevel($0).message }
            .drive(self.pooLevelLabel.rx.text)
            .disposed(by: disposeBag)
        
        pooslider.rx.value
            .asDriver()
            .filter {return $0 >= 0 || $0 <= 100}
            .map { PooLevel($0).query }
            .drive(viewModel.keyWord)
            .disposed(by: disposeBag)
        
        
        viewModel.POIDataList
            .map { data -> POIParams in
                let level: PooLevel = { [weak self] in
                    let result = self?.pooslider.value ?? 0
                    switch result {
                    case 0...25:
                        return .Little
                    case 25...50:
                        return .Soso
                    case 50...75:
                        return .IcantAnyMore
                    case 75...100:
                        return .Legend
                    default:
                        return .Little
                    }
                }()
                return POIParams(data, level)
            }
            .map{ data -> POIParams in
                print(data.Documents)
                return data
            }
            .distinctUntilChanged( { $0 == $1 } )
            .drive(self.rx.showAlertAction)
            .disposed(by: disposeBag)
    }
    
    private func attribute(){
        self.title = "대똥여지도"
        
        backGroundView.backgroundColor = .white
        
        searchButton.layer.cornerRadius = 20
        searchButton.tintColor = .black
        searchButton.backgroundColor = .white
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingHeading()
        
        mapView.delegate = self
        mapView.currentLocationTrackingMode = .onWithoutHeading
        mapView.setZoomLevel(1, animated: false)
        
    }
    
    
    private func layout(){
        view.addSubview(backGroundView)
        backGroundView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints{
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(backGroundView.snp.top)
        }
        
        backGroundView.addSubview(pooslider)
        pooslider.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().offset(-40)
            $0.height.equalTo(50)
        }
        
        backGroundView.addSubview(pooLevelLabel)
        pooLevelLabel.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(100)
            $0.bottom.equalTo(pooslider.snp.top).offset(-30)
            $0.height.equalTo(50)
        }
        
        view.addSubview(searchButton)
        searchButton.snp.makeConstraints{
            $0.bottom.equalTo(backGroundView.snp.top).offset(-30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.width.equalTo(50)
        }
        
    }
}

extension MainViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation
            .onNext(CLLocation(latitude: locations.last?.coordinate.latitude ?? 0 , longitude: locations.last?.coordinate.longitude ?? 0))
    }
    
    
}
extension MainViewController: MTMapViewDelegate {
    
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        currentLocation
            .onNext(CLLocation(latitude: mapCenterPoint.mapPointGeo().latitude, longitude: mapCenterPoint.mapPointGeo().longitude))
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        if accuracy == 500{
            currentLocation
                .onNext(CLLocation(latitude: location.mapPointGeo().latitude, longitude: location.mapPointGeo().longitude))
        }
    }
}

