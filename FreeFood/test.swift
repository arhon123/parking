import UIKit
import MapKit


class test: UIViewController, MKMapViewDelegate {
    
    var tit = ""
    var geos = ""
    
    var annotations = [MKPointAnnotation]()

    @IBOutlet var myMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(geos , completionHandler: { placemarks, error in
            
            if error != nil {
                print(error!)
                return
            }
            
            if let myPlacemarks = placemarks {
                let myPlacemark = myPlacemarks[0]
                
                let annotation = MKPointAnnotation()
                annotation.title = self.tit
            
        if let myLocation = myPlacemark.location {
            annotation.coordinate = myLocation.coordinate
            self.annotations.append(annotation)
                }
            }
            self.myMapView.showAnnotations(self.annotations, animated: true)
            self.myMapView.addAnnotations(self.annotations)
        
    })
}
}
