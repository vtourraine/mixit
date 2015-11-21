//
//  AboutViewController.swift
//  mixit
//
//  Created by Vincent Tourraine on 21/11/15.
//  Copyright © 2015 Studio AMANgA. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation

@objc class AboutViewController: UITableViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    var mapView: MKMapView?
    let coordinates = CLLocationCoordinate2DMake(45.78392, 4.869014)
    let ButtonCellIdentifier = "Cell"

    enum AboutSections: Int {
        case Map, Links
    }

    init() {
        super.init(style: .Grouped)
        self.title = NSLocalizedString("About Mix-IT", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadNavigationItems()
        self.loadHeaderView()
        self.loadFooterView()

        self.tableView.registerClass(
            UITableViewCell.self,
            forCellReuseIdentifier: self.ButtonCellIdentifier)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let locationManager = CLLocationManager()
        locationManager.delegate = self
        if #available(iOS 8, *) {
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager = locationManager
    }

    func loadNavigationItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: ""),
            style: .Plain,
            target: self,
            action: "dismiss:")
    }

    func loadHeaderView() {
        let headerView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0))

        let logoView = UIImageView(image: UIImage(named: "Logo"))
        logoView.frame = CGRectMake(
            (CGRectGetWidth(headerView.frame) - CGRectGetWidth(logoView.frame))/2,
            2*20,
            CGRectGetWidth(logoView.frame),
            CGRectGetHeight(logoView.frame))
        logoView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        headerView.addSubview(logoView)

        let dateLabel = UILabel(frame: CGRectMake(
            0,
            CGRectGetMaxY(logoView.frame) + 8,
            CGRectGetWidth(headerView.frame),
            80))
        dateLabel.font = UIFont.boldSystemFontOfSize(20)
        dateLabel.numberOfLines = 2
        dateLabel.text = NSLocalizedString("April 21 and 22, 2016\nLyon, France", comment: "")
        dateLabel.textAlignment = .Center
        dateLabel.autoresizingMask = [.FlexibleWidth]
        headerView.addSubview(dateLabel)

        let mapView = MKMapView(frame: CGRectMake(
            0,
            CGRectGetMaxY(dateLabel.frame) + 20,
            CGRectGetWidth(headerView.frame),
            200))
        mapView.autoresizingMask = [.FlexibleWidth]
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title      = NSLocalizedString("Mix-IT", comment: "")
        annotation.subtitle   = NSLocalizedString("CPE Lyon", comment: "")
        mapView.addAnnotation(annotation)
        mapView.region = MKCoordinateRegionMake(self.coordinates, MKCoordinateSpanMake(0.05, 0.05))
        headerView.addSubview(mapView)
        self.mapView = mapView

        let topBorder = UIView(frame: CGRectMake(
            0,
            CGRectGetMinY(mapView.frame),
            CGRectGetWidth(headerView.frame),
            1/UIScreen.mainScreen().scale))
        topBorder.backgroundColor = UIColor(white: 0.75, alpha:1)
        topBorder.autoresizingMask = [.FlexibleWidth]
        headerView.addSubview(topBorder)

        headerView.frame = CGRectMake(
            0, 0,
            CGRectGetWidth(self.view.frame),
            CGRectGetMaxY(mapView.frame))
        self.tableView.tableHeaderView = headerView
    }

    func loadFooterView() {
        let label = UILabel(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 150))
        label.numberOfLines = 0
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(13)
        label.userInteractionEnabled = true
        label.text = NSLocalizedString("This app isn’t affiliated with the Mix-IT team.\nMade by @vtourraine.", comment: "")
        self.tableView.tableFooterView = label

        let recognizer = UITapGestureRecognizer(target: self, action: "openVTourraine:")
        recognizer.numberOfTapsRequired = 1;
        label.addGestureRecognizer(recognizer)
    }

    // MARK: - Actions

    @IBAction func openInMaps(sender: AnyObject) {
        let placemark = MKPlacemark(coordinate: self.coordinates, addressDictionary:nil)
        let item = MKMapItem(placemark: placemark)
        item.name = NSLocalizedString("Mix-IT", comment: "")

        item.openInMapsWithLaunchOptions(
            [MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: self.coordinates)])
    }

    @IBAction func openInSafari(sender: AnyObject) {
        let URL = NSURL(string: "http://www.mix-it.fr/")
        if let URL = URL {
            UIApplication.sharedApplication().openURL(URL)
        }
    }

    @IBAction func openVTourraine(sender: AnyObject) {
        let URL = NSURL(string: "http://www.vtourraine.net?mixit")
        if let URL = URL {
            UIApplication.sharedApplication().openURL(URL)
        }
    }

    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            self.ButtonCellIdentifier,
            forIndexPath:indexPath)

        if let textLabel = cell.textLabel {
            textLabel.textAlignment = .Center
            textLabel.font = UIFont.systemFontOfSize(17)
            textLabel.textColor = self.view.tintColor

            let section = AboutSections(rawValue: indexPath.section)
            if let section = section {
                switch section {
                case AboutSections.Map:
                    textLabel.text = NSLocalizedString("Open in Maps", comment: "")

                case AboutSections.Links:
                    textLabel.text = NSLocalizedString("Open Mix-IT website in Safari", comment: "")
                }
            }
        }

        return cell
    }


    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = AboutSections(rawValue: indexPath.section)
        if let section = section {
            switch section {
            case AboutSections.Map:
                self.openInMaps(tableView)

            case AboutSections.Links:
                self.openInSafari(tableView)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }


    // MARK: - Location manager delegate

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if #available(iOS 8, *) {
            if status == .AuthorizedWhenInUse {
                if let mapView = self.mapView {
                    mapView.showsUserLocation = true
                }
            }
        }
    }
}
