//
//  ViewController.swift
//  BestFriend
//
//  Created by Koby Samuel on 12/1/15.
//  Copyright © 2015 Koby Samuel. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import MapKit
import CoreLocation
import MessageUI
import Social

class ViewController: UIViewController, ABPeoplePickerNavigationControllerDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate {
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var email: UILabel!
	@IBOutlet weak var photo: UIImageView!
	@IBOutlet weak var map: MKMapView!
	let locMan: CLLocationManager = CLLocationManager()

	@IBAction func newBFF(sender: AnyObject) {
		let picker: ABPeoplePickerNavigationController = ABPeoplePickerNavigationController()
		picker.peoplePickerDelegate = self
		presentViewController(picker, animated: true, completion: nil)
	}
	
	func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
		let friendName: String = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
		name.text = friendName
		let friendAddressSet: ABMultiValueRef = ABRecordCopyValue(person, kABPersonAddressProperty).takeRetainedValue()
		if(ABMultiValueGetCount(friendAddressSet) > 0) {
			let friendFirstAddress = ABMultiValueCopyValueAtIndex(friendAddressSet, 0).takeRetainedValue() as! NSDictionary
			showAddress(friendFirstAddress)
		}
		let friendEmailAddresses: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
		if(ABMultiValueGetCount(friendEmailAddresses) > 0) {
			let friendEmail: String = ABMultiValueCopyValueAtIndex(friendEmailAddresses, 0).takeRetainedValue() as! String
			email.text = friendEmail
		}
		if(ABPersonHasImageData(person)) {
			photo.image = UIImage(data: ABPersonCopyImageData(person).takeRetainedValue())
		}
	}
	
	func showAddress(fullAddress: NSDictionary) {
		let geocoder: CLGeocoder = CLGeocoder()
		geocoder.geocodeAddressDictionary(fullAddress as [NSObject : AnyObject], completionHandler: { (placemarks, error) -> Void in
			let friendPlacemark: CLPlacemark = placemarks![0] as CLPlacemark
			let mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: (friendPlacemark.location?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
			self.map.setRegion(mapRegion, animated: true)
			let mapPlacemark: MKPlacemark = MKPlacemark(placemark: friendPlacemark)
			self.map.addAnnotation(mapPlacemark)
		})
	}
	
	func mapView(aMapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		let pinDrop: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myspot")
		pinDrop.animatesDrop = true
		pinDrop.canShowCallout = true
		pinDrop.pinColor = MKPinAnnotationColor.Purple
		return pinDrop
	}
	
	@IBAction func sendEmail(sender: AnyObject) {
		let emailAddresses: [String] = [email.text!]
		let mailComposer: MFMailComposeViewController = MFMailComposeViewController()
		mailComposer.mailComposeDelegate = self
		mailComposer.setToRecipients(emailAddresses)
		presentViewController(mailComposer, animated: true, completion: nil)
	}
	
	@IBAction func sendTweet(sender: AnyObject) {
		let geocoder: CLGeocoder = CLGeocoder()
		geocoder.reverseGeocodeLocation(map.userLocation.location!, completionHandler: {
			(placemarks, error) -> Void in
			let myPlacemark = placemarks?[0]
			let tweetText: String = "Hello all - I'm currently in \(myPlacemark?.locality)!"
			let tweetComposer: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
			if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
				tweetComposer.setInitialText(tweetText)
				self.presentViewController(tweetComposer, animated: true, completion: nil)
			}
		})
	}
	
	func promptForAddressBookRequestAccess() {
		let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
		ABAddressBookRequestAccessWithCompletion(addressBookRef) {
			(granted: Bool, error: CFError!) in dispatch_async(dispatch_get_main_queue()) {}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		locMan.requestWhenInUseAuthorization()
		promptForAddressBookRequestAccess()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}

