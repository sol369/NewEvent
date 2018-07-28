//
//  ContactUsVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import MessageUI


class ContactUsVC: UIViewController,MFMailComposeViewControllerDelegate {
    
    lazy var contactUsPromptLabel : UILabel = {
        let label = UILabel()
        let customFont = UIFont.systemFont(ofSize: 18)
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = "At Haipe we love to hear from our users, so take the time out to contact us. Tell us what you like about the app. Tell us what you don't like about the app, so we can continously improve how you discover and connect with events.To report anything to us at all just shake your phone and select from the menu of options or you can email us directly by clicking the button below.\n\n -Thanks Haipe "
        return label
    }()
    lazy var sendEmailButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("Contact Us", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setCellShadow()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Futura", size: 14)
        button.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return button
    }()
    
    
  
    
    @objc func sendEmail(){
        print("attempting to send email")
        let mailComposeVC = configureMailController()
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeVC, animated: true, completion: nil)
        }else{
            showMailError()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    @objc func setupViews(){
        navigationItem.title = "Contant Us"
        view.addSubview(contactUsPromptLabel)
        contactUsPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        updateWithSpacing(lineSpacing: 5)
        
        view.addSubview(sendEmailButton)
        sendEmailButton.snp.makeConstraints { (make) in
            make.top.equalTo(contactUsPromptLabel.snp.bottom).offset(30)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: contactUsPromptLabel.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = contactUsPromptLabel.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        contactUsPromptLabel.attributedText = attributedString
        
    }
    
    @objc func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["contacthaipe@gmail.com"])
        mailComposerVC.setSubject("App Feedback")
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
