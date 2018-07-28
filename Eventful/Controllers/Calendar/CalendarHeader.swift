//
//  CalendarHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 6/25/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import JTAppleCalendar

class CalendarHeader: JTAppleCollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    var dayStackView: UIStackView?

    
    let sunLabel : UILabel =  {
        let sunLabel = UILabel()
        sunLabel.text = "Sun"
        sunLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        sunLabel.textAlignment = .center
        return sunLabel
    }()
    
    let monLabel : UILabel =  {
        let monLabel = UILabel()
        monLabel.text = "Mon"
        monLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        monLabel.textAlignment = .center
        return monLabel
    }()
    
    let tuesLabel : UILabel =  {
        let tuesLabel = UILabel()
        tuesLabel.text = "Tue"
        tuesLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        tuesLabel.textAlignment = .center
        return tuesLabel
    }()
    let wedsLabel : UILabel =  {
        let wedsLabel = UILabel()
        wedsLabel.text = "Wed"
        wedsLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        wedsLabel.textAlignment = .center
        return wedsLabel
    }()
    let thursLabel : UILabel =  {
        let thursLabel = UILabel()
        thursLabel.text = "Thu"
        thursLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        thursLabel.textAlignment = .center
        return thursLabel
    }()
    let friLabel : UILabel =  {
        let friLabel = UILabel()
        friLabel.text = "Fri"
        friLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        friLabel.textAlignment = .center
        return friLabel
    }()
    let satLabel : UILabel =  {
        let satLabel = UILabel()
        satLabel.text = "Sat"
        satLabel.font = UIFont(name:"HelveticaNeue", size: 16.5)
        satLabel.textAlignment = .center
        return satLabel
    }()
    
    @objc func setupViews(){
        dayStackView = UIStackView(arrangedSubviews: [sunLabel,monLabel,tuesLabel,wedsLabel,thursLabel,friLabel,satLabel])
        dayStackView?.distribution = .fillEqually
        dayStackView?.axis = .horizontal
        addSubview(dayStackView!)
        dayStackView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        })
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
