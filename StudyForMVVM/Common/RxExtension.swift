import UIKit
import RxSwift
import RxCocoa
import RxRelay
import CoreLocation

extension Reactive where Base: MainViewController {
    var showAlertAction: Binder<POIParams> {
        return Binder(base) { MainVC, data in
            if data.Documents?.isEmpty ?? false == true {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.title = "화장실이 주변에 없습니다."
                if data.level  == .Legend {
                    alert.message = "진짜 여기선 걍 길가에 싸야해 아님 바지"
                }
                else {
                    alert.message = "급한 단계를 올려봐 이 정도 각오로는 안돼"
                }
                let alertCancelAction = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(alertCancelAction)
                base.mapView.removeAllPOIItems()
                MainVC.present(alert, animated: true)
            }
            else {
                let items = data.Documents!
                    .map { result -> MTMapPOIItem in
                        let mapPOIItem = MTMapPOIItem()
                        mapPOIItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(result.y) ?? 0, longitude: Double(result.x) ?? 0))
                        mapPOIItem.markerType = .redPin
                        mapPOIItem.itemName = result.placeName
                        mapPOIItem.showAnimationType = .springFromGround
                        mapPOIItem.tag = Int(result.id) ?? 0
                        return mapPOIItem
                    }
                base.mapView.removeAllPOIItems()
                base.mapView.addPOIItems(items)
            }
        }
    }
}
