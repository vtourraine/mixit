//
//  AddEventController.swift
//  Mixit
//
//  Created by Tourraine, Vincent (ELS-HBE) on 14/03/2024.
//  Copyright © 2024 Studio AMANgA. All rights reserved.
//

#if os(iOS)

import UIKit
import EventKit
import EventKitUI

// Based on: https://github.com/bvechiato/new-event-app

class AddEventController: UIViewController, EKEventEditViewDelegate {
    let eventStore = EKEventStore()
    var talk: Talk?
    var isFirstDidAppear = true

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        parent?.dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard isFirstDidAppear else {
            return
        }

        let handler: EKEventStoreRequestAccessCompletionHandler = { (granted, error) in
            DispatchQueue.main.async {
                guard granted && error == nil else {
                    let alert = UIAlertController(title: NSLocalizedString("Cannot Add Event", comment: ""), message: NSLocalizedString("Please allow calendar access in Settings.", comment: ""), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { _ in
                        self.parent?.dismiss(animated: true, completion: nil)
                    })
                    alert.view.tintColor = .miXiTOrange
                    self.present(alert, animated: true)
                    return
                }

                let eventController = EKEventEditViewController()
                eventController.eventStore = self.eventStore
                eventController.editViewDelegate = self
                eventController.modalPresentationStyle = .overCurrentContext
                eventController.modalTransitionStyle = .crossDissolve

                if let talk = self.talk {
                    let event = EKEvent(eventStore: self.eventStore)
                    event.title = talk.title
                    event.startDate = Date()
                    event.location = talk.room
                    event.notes = talk.summary
                    event.startDate = talk.startDate
                    event.endDate = talk.endDate
                    // event.calendar = self.eventStore.defaultCalendarForNewEvents
                    event.url = MixitClient.webURL
                    eventController.event = event
                }

                self.present(eventController, animated: true, completion: nil)
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestWriteOnlyAccessToEvents(completion: handler)
        }
        else {
            eventStore.requestAccess(to: .event, completion: handler)
        }

        isFirstDidAppear = false
    }
}

#endif
