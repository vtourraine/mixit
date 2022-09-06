//
//  InfoView.swift
//  mixit
//
//  Created by Vincent Tourraine on 05/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI
import MapKit

struct InfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                Image("Logo")
                Text("May 24 & 25, 2022\nLyon, France")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                MapView()
                    .frame(height: 200)
                Button("Open in Maps") {
                    openInMaps()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("Orange"))
                .foregroundColor(Color("Purple"))
                Button("Open MiXiT website") {
                    openWebsite()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("Orange"))
                .foregroundColor(Color("Purple"))
                Spacer()
                HStack {
                    Text("This app isn’t affiliated with the MiXiT team.\nMade by @vtourraine.")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            }
        }
    }

    func openInMaps() {
        let placemark = MKPlacemark(coordinate: MapView.mainLocation)
        let item = MKMapItem(placemark: placemark)
        item.name = "MiXiT"
        item.openInMaps()
    }

    func openWebsite() {
        let url = URL(string: "https://mixitconf.org")!
#if os(iOS)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
#elseif os(macOS)
        NSWorkspace.shared.open(url)
#endif
    }
}

struct MapView: View {
    // CPE coordinates : 45.78392, 4.869014
    // Manufacture des Tabacs coordinates: 45.7481118, 4.8602011
    static let mainLocation = CLLocationCoordinate2D(latitude: 45.7481118, longitude: 4.8602011)
    struct Annotation: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
    let annotations = [
        Annotation(name: "Manufacture des Tabacs", coordinate: mainLocation)]

    @State private var region = MKCoordinateRegion(
        center: mainLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) {
            MapMarker(coordinate: $0.coordinate)
        }
    }
}

struct InfoView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            InfoView()
        }
    }
}
