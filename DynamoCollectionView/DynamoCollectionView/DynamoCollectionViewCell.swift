//
//  DynamoCollectionViewCell.swift
//  DynamoCollectionView
//
//  Created by Shawn Miller on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Hero

enum DynamoDisplayMode {
    case Top
    case Normal
}

//protocol to make sure that this function adhers to the blueprint of the dynamoCollectionViewCellDelegate and includes this method
//the sender part lets us know where the message is and can be sent from
protocol DynamoCollectionViewCellDelegate: NSObjectProtocol {
    func dynamoCollectionViewCellDidSelect(sender: UICollectionViewCell)
}

public class DynamoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Variables
    var delegate: DynamoCollectionViewCellDelegate?
    
    //simple image view created to contain the picture in each view
    public var backgroundImageView: UIImageView = {
        let firstImage = UIImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleToFill
        return firstImage
    }()
    
    //creates a title variable that is a string that is settable and 
    public var title:String? {
        set {
            nameLabel.text = newValue
        }
        get {
            return nameLabel.text
        }
    }
    
    //creates a day variable that is a string that is settable and gettable
    public var day:String? {
        set {
            dayLabel.text = newValue
        }
        get {
            return dayLabel.text
        }
    }
    //creates a month variable that is a string that is settable and gettable
    public var month:String? {
        set {
            monthLabel.text = newValue
        }
        get {
            return monthLabel.text
        }
    }
    
    //sets a topViewRatio for the collectionViewCell that is created
    public var topViewRatio: CGFloat = 0.6
    //tags which lets you know if we are the top cell or the normal/bottom cell
    //An integer that you can use to identify view objects in your application.
    //the get function for this tag also serves the function of letting the app know which cell and ultimately what information will be presented upon clicking of the cell and presentation of the event detail screen
    override public var tag: Int {
        set {
            super.tag = newValue
            setDisplayMode(newValue >= 0 ? .Normal : .Top)
        }
        get {
            return super.tag
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Action
    
    public func refreshView() {
        if let img = backgroundImageView.image {
            let (complementaryColor, complementaryOpacity) = DynamoUtils.computeComplementaryColor(image: img)
            self.calenderUnit.backgroundColor = complementaryColor
            self.calenderUnit.layer.shadowColor = complementaryColor.cgColor
            self.darkOverlayImageView.alpha = complementaryOpacity
            darkOverlayImageView.image = darkOverlayImageView.image?.featheredImageWithImage()
        }
    }
    
    // MARK: - Private variables

    private var nameLabel:UILabel!
    private var nameLabelLeading:NSLayoutConstraint!
    private var nameLabelWidth:NSLayoutConstraint!
    private var nameLabelHeight:NSLayoutConstraint!
    private var calenderToNameLabel:NSLayoutConstraint!
    private var calenderUnit:UIView!
    private var overlayTextView:UIView!
    private var calenderUnitBottom:NSLayoutConstraint!
    private var overlayTextViewBottom:NSLayoutConstraint!
    private var dayLabel:UILabel!
    private var monthLabel:UILabel!
    private var darkOverlayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dark_overlay", in: Bundle(for: DynamoCollectionView.self), compatibleWith: nil)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    //private var overlayButton:UIButton!
    
    //will set up the actual dynamoCollectionViewCell
    private func setupViews() {
        self.addSubview(self.backgroundImageView)
        self.backgroundColor = UIColor.white
        
        NSLayoutConstraint.activateViewConstraints(self.backgroundImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
  //will create a UIView that will function as the little calendar square you notice in the collectionViewCell, this just controls where it is placed in the cell and how it looks
        self.calenderUnit = UIView()
        self.calenderUnit.layer.cornerRadius = 5.0
        self.calenderUnit.translatesAutoresizingMaskIntoConstraints = false
        self.calenderUnit.layer.shadowOpacity = 0.5
        self.calenderUnit.layer.shadowOffset = CGSize.zero
        self.calenderUnit.layer.shadowRadius = 3.0
        self.addSubview(self.calenderUnit)
        NSLayoutConstraint.activateViewConstraints(self.calenderUnit, inSuperView: self, withLeading: 10.0, trailing: nil, top: nil, bottom: nil, width: 30.0, height: 30.0)
        self.calenderUnitBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.calenderUnit, superView: self, andSeparation: 5.0)
        
        // will add the dark overlay to each image view
        self.addSubview(self.darkOverlayImageView)
        NSLayoutConstraint.activateViewConstraints(self.darkOverlayImageView, inSuperView: self, withLeading: 0.0, trailing: 0, top: 0, bottom: 0)
        //overlayTextView is a UIView that will contain the month and date labels for the square in the bottom left
        self.overlayTextView = UIView()
        self.overlayTextView.layer.cornerRadius = 5.0
        self.overlayTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.overlayTextView)
        NSLayoutConstraint.activateViewConstraints(self.overlayTextView, inSuperView: self, withLeading: 10.0, trailing: nil, top: nil, bottom: nil, width: 30.0, height: 30.0)
        self.overlayTextViewBottom = NSLayoutConstraint.activateBottomConstraint(withView: self.overlayTextView, superView: self, andSeparation: 5.0)
        
        //will do the job of creating, presenting, and positioning the label that controls the day portion of the date/day(number) in the little date square
        self.dayLabel = UILabel()
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
        self.dayLabel.textColor = .white
        self.dayLabel.textAlignment = .center
        self.overlayTextView.addSubview(self.dayLabel)
        NSLayoutConstraint.activateViewConstraints(self.dayLabel, inSuperView: self.overlayTextView, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: nil, width: nil, height: 20.0)
          //will do the job of creating, presenting, and positioning the label that controls the month portion in the little date square
        self.monthLabel = UILabel()
        self.monthLabel.translatesAutoresizingMaskIntoConstraints = false
        self.monthLabel.font = UIFont.systemFont(ofSize: 8.0, weight: UIFont.Weight.light)
        self.monthLabel.textColor = .white
        self.monthLabel.textAlignment = .center
        self.overlayTextView.addSubview(self.monthLabel)
        NSLayoutConstraint.activateViewConstraints(self.monthLabel, inSuperView: self.overlayTextView, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.dayLabel, secondView: self.monthLabel, andSeparation: -5.0)
        _ = NSLayoutConstraint.activateHeightConstraint(view: self.dayLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)
        
      //will do the job of creating, presenting, and positioning the label that controls the name of the event that is presented in the collectionViewCell
        self.nameLabel = UILabel()
        self.nameLabel.numberOfLines = 2
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = UIFont.systemFont(ofSize: 8.0, weight: UIFont.Weight.regular)
        self.nameLabel.textColor = .white
        //self.nameLabel.shadowColor = UIColor.clear
        //self.nameLabel.shadowOffset = CGSize(width: 1, height: -2)
        self.addSubview(self.nameLabel)
        //variable that controls the leading space for the name label
        self.nameLabelLeading = NSLayoutConstraint.activateLeadingConstraint(withView: self.nameLabel, superView: self, andSeparation: 5.0)
        //variable width
        self.nameLabelWidth = NSLayoutConstraint.activateWidthConstraint(view: self.nameLabel, withWidth: min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)/3)
        //variable that controls/allows the vertical space between the calendar and namelabel
        self.calenderToNameLabel = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.calenderUnit, secondView: self.nameLabel, andSeparation: 5.0)
        //controls height of the name label
        self.nameLabelHeight = NSLayoutConstraint.activateHeightConstraint(view: self.nameLabel, withHeight: 1.0, andRelation: .greaterThanOrEqual)

        //will add a tapGesture to the cell so one can interact with it.
        //will control the numberOfTouches/Taps required to trigger some sort of action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delaysTouchesBegan = false
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ recognizer:UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            delegate?.dynamoCollectionViewCellDidSelect(sender: self)
        default:
            break
        }
    }
    //sets whcih display mode we are in for the top or bottom cell
    private func setDisplayMode(_ mode: DynamoDisplayMode) {
        self.nameLabelWidth.constant = self.frame.width
        //when value is not 0 mode is set to normal which would let one know that they will be displaying blocks in the bottom view?
        if mode == .Top {
            //so these constants are directly altering the elements in the cell assuming it is the bottom colletionView and where they are positioned
            //seems to be moving the dark or colored square in the calendar unit as well as the name of the app
            //calendar unit seems to be attached to the name of event so moving one moves both
            self.calenderUnitBottom.constant = -self.frame.height/2.0 + 15.0
            //controls the placement of text in the calendar unit
            self.overlayTextViewBottom.constant = -self.frame.height/2.0 + 15.0
            //controls the leading space for the name label
            self.nameLabelLeading.constant = 10.0
            //controls the space between the calendar unit and the name of the event
            self.calenderToNameLabel.constant =  3.0
            self.nameLabelHeight.constant = 1.0
            NSLayoutConstraint.activateViewConstraints(self.darkOverlayImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0 , bottom: -(1 - self.topViewRatio)*self.frame.size.height)
        }
        else {
            //so these constants are directly altering the elements in the cell assuming it is the bottom colletionView and where they are positioned
            //seems to be moving the dark or colored square in the calendar unit as well as the name of the app
            //calendar unit seems to be attached to the name of event so moving one moves both
            self.calenderUnitBottom.constant = -17.0
            //controls the placement of text in the calendar unit
            self.overlayTextViewBottom.constant = -17.0
            //controls the leading space for the name label
            self.nameLabelLeading.constant = 10.0
            //controls the space between the calendar unit and the name of the event
            self.calenderToNameLabel.constant = 3.0
            self.nameLabelHeight.constant = 1.0
            NSLayoutConstraint.activateViewConstraints(self.darkOverlayImageView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: 0, bottom: 0)
        }
        
    }
}

