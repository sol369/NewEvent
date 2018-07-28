//
//  SubmitEvent.swift
//  Eventful
//
//  Created by Shawn Miller on 7/11/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class submitEvent: UIViewController, MFMailComposeViewControllerDelegate {
    lazy var submitEventPromptLabel : UILabel = {
        let label = UILabel()
        let customFont = UIFont.systemFont(ofSize: 18)
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = "We are always looking to add to our growing collection of events. To submit an event click the button below. It will will allow you to email us the details of your event directly. In the email include your event name, description, date, time, address, cost, flyer, and optional promotional video. The absence of any of these will postpone the process of getting your event approved. If every thing checks out during the review process your event will be added to the appropriate section on the main page.\n\n -Thanks Haipe "
        return label
    }()
    
    lazy var sendEventButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Event", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setCellShadow()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Futura", size: 14)
        button.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return button
    }()
    override func viewDidLoad() {
        setupViews()
    }
    
    @objc func sendEvent(){
        print("attempting to send event")
        let mailComposeVC = configureMailController()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeVC, animated: true, completion: nil)
        }else{
            showMailError()
        }
    }
    
    @objc func setupViews(){
        navigationItem.title = "Add an Event"
        view.addSubview(submitEventPromptLabel)
        submitEventPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        updateWithSpacing(lineSpacing: 5)
        
        view.addSubview(sendEventButton)
        sendEventButton.snp.makeConstraints { (make) in
            make.top.equalTo(submitEventPromptLabel.snp.bottom).offset(30)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.height.equalTo(30)
            make.width.equalTo(90)
        }
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(self.GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: submitEventPromptLabel.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = submitEventPromptLabel.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        submitEventPromptLabel.attributedText = attributedString
        
    }
    
    @objc func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["haipeevents@gmail.com"])
        mailComposerVC.setSubject("New Event Submission")
        return mailComposerVC
    }
    
    @objc func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            self.GoBack()
        }
    }
}
