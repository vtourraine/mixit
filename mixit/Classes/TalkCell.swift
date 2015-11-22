//
//  TalkCell.swift
//  mixit
//
//  Created by Vincent Tourraine on 22/11/15.
//  Copyright © 2015 Studio AMANgA. All rights reserved.
//

import UIKit

class TalkCell: UITableViewCell {

    static let height = 76.0

    @IBOutlet weak var favoritedImageView: UIImageView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        if let textLabel = self.textLabel {
            textLabel.numberOfLines = 0
        }

        let favoritedImageView = UIImageView()
        favoritedImageView.tintColor = UIColor.orangeColor()
        self.contentView.addSubview(favoritedImageView)
        self.favoritedImageView = favoritedImageView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let nameLabelOriginX: CGFloat = 15
        let labelMaxWidth     = CGRectGetWidth(self.contentView.frame) - nameLabelOriginX - 30
        let labelsMaxSize     = CGSizeMake(labelMaxWidth, CGFloat.max)
        let drawingOptions: NSStringDrawingOptions = [
            NSStringDrawingOptions.UsesLineFragmentOrigin,
            NSStringDrawingOptions.UsesFontLeading]

        if let textLabel = self.textLabel,
            let textLabelText = textLabel.text {
                let titleAttributes = [NSFontAttributeName: textLabel.font]
                let titleSize = NSString(string: textLabelText).boundingRectWithSize(
                    labelsMaxSize,
                    options:drawingOptions,
                    attributes:titleAttributes,
                    context:nil)

                textLabel.frame = CGRectMake(
                    nameLabelOriginX, 5,
                    titleSize.size.width, 44)
        }

        if let detailTextLabel = self.detailTextLabel {
            detailTextLabel.frame = CGRectMake(
                nameLabelOriginX, CGRectGetMaxY(self.contentView.frame) - 24,
                //CGRectGetMaxY(self.textLabel.frame) + 2,
                labelMaxWidth, 20)
        }

        if let favoritedImageView = self.favoritedImageView {
            var favoritedImageViewFrame = CGRectMake(0, 0, 20, 20)
            favoritedImageViewFrame.origin.x = CGRectGetWidth(self.contentView.frame) - 27
            favoritedImageViewFrame.origin.y = CGRectGetMidY(self.contentView.frame) - CGRectGetMidY(favoritedImageViewFrame)
            favoritedImageView.frame = favoritedImageViewFrame
        }
    }
}
