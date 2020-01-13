//
//  EventCollectionViewCell.swift
//  Community Calendar
//
//  Created by Jordan Christensen on 12/16/19.
//  Copyright © 2019 Mazjap Co. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath? // To be removed
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    var eventController: EventController?
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var districtNameLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
        observeImage()
    }
    
    func updateViews() {
        guard let event = event, let _ = eventController else { return }
        eventImageView.layer.cornerRadius = 3
        eventTitleLabel.text = event.title
        setImage()
        districtNameLabel.text = event.locations.first?.city.uppercased()
        setDate()
//        guard let startDate = event.startDate, let endDate = event.endDate else { return }
//        timeLabel.text = "\(cellDateFormatter.string(from: startDate).lowercased()) - \(cellDateFormatter.string(from: endDate).lowercased())"
    }
    
    private func setImage() {
        if let imageURL = event?.images.first, !imageURL.isEmpty {
            eventController?.loadImage(for: imageURL)
        } else {
            if let indexPath = indexPath {
                eventImageView.image = UIImage(named: "placeholder\(indexPath.row % 6)")
            } else {
                eventImageView.image = UIImage(named: "lambda")
            }
        }
    }
    
    @objc
    func receiveImage(_ notification: Notification) {
        guard let imageNot = notification.object as? ImageNotification else {
            assertionFailure("Object type could not be inferred: \(notification.object as Any)")
            return
        }
        if let eventImageUrl = event?.images.first, imageNot.url == eventImageUrl {
            DispatchQueue.main.async {
                self.eventImageView.image = imageNot.image
            }
            
        }
    }
    
    private func setDate() {
        guard let startDate = event?.startDate else {
            NSLog("\(#file):L\(#line): startDate: \(String(describing: event?.startDate)) is nil! Check \(#function)")
            return
        }
        timeLabel.text = featuredEventDateFormatter.string(from: startDate)
        
        if let endDate = event?.endDate {
            timeLabel.text = "\(cellDateFormatter.string(from: startDate).lowercased()) - \(cellDateFormatter.string(from: endDate).lowercased())"
        } else {
            timeLabel.text = cellDateFormatter.string(from: startDate).lowercased()
        }
    }
    
    func observeImage() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveImage), name: .imageWasLoaded, object: nil)
    }
}