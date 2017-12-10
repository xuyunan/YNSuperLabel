//
//  ViewController.swift
//  YNSuperLabel
//
//  Created by Yunan Xu on 10/12/2017.
//  Copyright © 2017 xuyunan0113@gmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hintLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example 1
        let label = YNSuperLabel(frame: CGRect(x: 16, y: 100, width: self.view.frame.size.width - 32, height: 0))
        label.priceStyle = {
            var style = YNSuperLabelStyle()
            style.textColor = UIColor(red:0.92, green:0.20, blue:0.25, alpha:1.00)
            return style
        }
        
        label.telStyle = {
            var style = YNSuperLabelStyle()
            style.textColor = UIColor(red:0.46, green:0.26, blue:0.96, alpha:1.00)
            return style
        }
        
        label.linkStyle = {
            var style = YNSuperLabelStyle()
            style.textColor = UIColor(red:0.31, green:0.53, blue:0.93, alpha:1.00)
            return style
        }
        
        label.clickHandler = { (attr: YNSuperLabelAttr) in
            self.hintLabel.text = attr.content
            self.hintLabel.textColor = attr.textColor
        }
        
        label.text = "退款成功: 总额^price(¥311.20), 退款将按原支付方式返回, 预计需要1-5个工作日到账. 涉及资金超过^price(¥10万)的, 可能需要多等2日. \n客服电话:^tel(155xxxx9413). \n官方链接:^link(https://weibo.com/xuyunan2011)"
        self.view.addSubview(label)
        
        // Example 2
        let readme = YNSuperLabel(frame: CGRect(x: 16, y: 280, width: self.view.frame.size.width - 32, height: 0))
        readme.linkStyle = {
            var style = YNSuperLabelStyle()
            style.textColor = UIColor(red:0.31, green:0.53, blue:0.93, alpha:1.00)
            return style
        }
        readme.clickHandler = { (attr: YNSuperLabelAttr) in
            self.hintLabel.text = attr.content
            self.hintLabel.textColor = attr.textColor
        }
        readme.text = "温馨提示: 未注册饿了么账号的手机号, 登录时将自动注册, 且代表您已同意^link(《用户服务协议》)"
        self.view.addSubview(readme)
    }
}

