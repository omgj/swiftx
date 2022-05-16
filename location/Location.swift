//
//  Location.swift
//  location
//
//  Created by me on 16/3/22.
//

import SwiftUI
import CoreLocation
import UIKit
import Foundation
import MapKit
import Combine
import Contacts

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    var completer: MKLocalSearchCompleter
    @Published var completions: [MKLocalSearchCompletion] = []
    var cancellable: AnyCancellable?
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
        completer.resultTypes = .address
        completer.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
}

extension MKLocalSearchCompletion: Identifiable {}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var addr: String = ""
    @Published var postcode: String = ""

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func ask() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(location)
        
    }
}

struct Addr: Hashable {
    var id: String
    var unit: String = ""
    var num: String
    var street: String
    var postalcode: String
    var adminarea: String
    var country: String
    var sublocality: String
    var locality: String
    var region: String
    var subadmin: String
    var lat: Double
    var lon: Double
}

struct Locationing: View {
    @ObservedObject var locationSearchService = LocationSearchService()
    @State var qtxt = ""
    @State var adds: [Addr] = []
    @FocusState var qfocus
    @StateObject var locationManager = LocationManager()
    @State var postaddr = ""
    var lat: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }
    var lon: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }
    func newadd(addr: String, pcodes: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("\(addr) \(pcodes)") { places, error in
            if error != nil {
                dump(error)
            } else {
                if places != nil {
                    if let place = places?[0] {
                        print(place.region?.identifier ?? "")
                        print(place.region?.description ?? "")
                        let idd = UUID().uuidString
                        var nums = place.subThoroughfare ?? ""
                        let q = addr.split(separator: " ")
                        var ap = ""
                        if nums == "" {
                            if !q.isEmpty {
                                nums = String(q[0])
                            }
                        }
                        var chars = CharacterSet()
                        chars.insert(charactersIn: "0123456789")
                        print(q)
                        if q.count > 1 {
                            let qs = String(q[1])
                            if qs.rangeOfCharacter(from: chars) != nil {
                                ap = String(q[0])
                                nums = String(q[1])
                            }
                        }
                        let a = Addr(id: idd,
                                     unit: ap,
                                     num: nums,
                                     street: place.thoroughfare ?? "",
                                     postalcode: place.postalCode ?? "",
                                     adminarea: place.administrativeArea ?? "",
                                     country: place.isoCountryCode ?? "",
                                     sublocality: place.subLocality ?? "",
                                     locality: place.locality ?? "",
                                     region: place.region?.identifier ?? "",
                                     subadmin: place.subAdministrativeArea ?? "",
                                     lat: place.location?.coordinate.latitude ?? 0,
                                     lon: place.location?.coordinate.longitude ?? 0
                                    )
                        withAnimation {
                            adds.append(a)
                        }
                        
                    }
                }
                
            }
        }
    }
    func regeo() {
        let geocode = CLGeocoder()
        geocode.reverseGeocodeLocation(locationManager.lastLocation!) { (pl, err) in
            if err != nil {
                dump(err)
                return
            } else {
                if let p = pl?[0] {
                    postaddr = p.formattedAddress ?? ""
                } else {
                    print("no places")
                }
            }
        }
    }
    var body: some View {
        VStack {
            if !adds.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 5) {
                        Text("Address Details").font(.system(size: 10))
                        Text("Clear")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                            .onTapGesture {
                                adds.removeAll()
                                qfocus = true
                            }
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
                VStack {
                    HStack {
                        Text("Number:")
                            .foregroundColor(.gray)
                        Text(adds[0].num)
                        if !adds[0].unit.isEmpty {
                            Text("Unit:")
                                .foregroundColor(.gray)
                            Text(adds[0].unit)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    HStack {
                        Text("Street:")
                            .foregroundColor(.gray)
                        Text(adds[0].street)
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    HStack {
                        Text("Postcode:")
                            .foregroundColor(.gray)
                        Text(adds[0].postalcode)
                        if adds[0].locality.isEmpty {
                            Text("Suburb:")
                                .foregroundColor(.gray)
                            Text(adds[0].sublocality)
                        } else {
                            Text("Suburb:")
                                .foregroundColor(.gray)
                            Text(adds[0].locality)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    HStack {
                        Text("State:")
                            .foregroundColor(.gray)
                        Text(adds[0].adminarea)
                        Text("Country:")
                            .foregroundColor(.gray)
                        Text(adds[0].country)
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    HStack {
                        Text("Lat:")
                            .foregroundColor(.gray)
                        Text(String(adds[0].lat))
                            .font(.system(size: 12))
                        Text("Lon:")
                            .foregroundColor(.gray)
                        Text(String(adds[0].lon))
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                .padding(10)
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text("Click Address to Forward Geocode").font(.system(size: 10))
                        if !locationSearchService.searchQuery.isEmpty {
                            Text("Clear")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                                .onTapGesture {
                                    locationSearchService.searchQuery = ""
                                }
                        }
                    }
                    Spacer()
                }
                HStack {
                    TextField("Address Search", text: $locationSearchService.searchQuery)
                        .font(Font.system(size: 18, design: .rounded))
                        .disableAutocorrection(true)
                        .padding()
                        .focused($qfocus)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(locationSearchService.completions, id: \.self) { completion in
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(completion.title).font(.system(size: 16))
                                    Text(completion.subtitle).font(.system(size: 12)).foregroundColor(.gray)
                                }
                                .padding(5)
                                Spacer()
                            }
                            .onTapGesture {
                                newadd(addr: completion.title, pcodes: completion.subtitle)
                            }
                            Divider().padding(5)
                        }
                    }
                }
            }
            Spacer()
            VStack(spacing: 0) {
                HStack {
                    if !postaddr.isEmpty {
                        Text("Postal Address:")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(postaddr)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                if locationManager.statusString == "unknown" {
                    Button(action: {
                        locationManager.ask()
                    }, label: {
                        Text("Detect Location")
                    })
                } else {
                    if locationManager.statusString == "denied" {
                        HStack {
                            Button(action: {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }, label: {
                                Text("Open Settings.")
                                    .font(.system(size: 12))
                            })
                            Text("You denied me access.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button(action: {
                            regeo()
                        }, label: {
                            Text("Click to Reverse Geocode Address")
                                .font(.system(size: 13))
                        })
                    }
                }
                HStack {
                    Text("Permission:")
                        .foregroundColor(.gray)
                    Text(locationManager.statusString)
                }
                HStack {
                    if lat != "0.0" {
                    Text("Lat:")
                        .foregroundColor(.gray)
                        Text(lat)
                    }
                    if lon != "0.0" {
                    Text("Lon:")
                        .foregroundColor(.gray)
                        Text(lon)
                    }
                    Spacer()
                }
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print(locationManager.statusString)
                    if locationManager.statusString == "authorizedWhenInUse" || locationManager.statusString == "authorizedAlways" {
                        locationManager.ask()
                    }
                }
            }
        }
    }
}


extension CLPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: postalAddress)
    }
}
