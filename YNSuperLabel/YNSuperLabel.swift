//
//  YNSuperLabel.swift
//  YNSuperLabel
//
//  Created by Yunan Xu on 10/12/2017.
//  Copyright © 2017 xuyunan0113@gmail.com. All rights reserved.
//

import UIKit

enum YNSuperLabelAttrType {
    case `default`
    case price
    case tel
    case link
}

class YNSuperLabel: UIView {

    var font: UIFont = UIFont.systemFont(ofSize: 14)
    var textColor: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.00)
    var text: String = "" {
        didSet {
            self.parse(text: self.text)
            self.frame = self.suggestedFrame()
        }
    }
    
    var attrs = [YNSuperLabelAttr]()
    var filteredText: String = ""   // 过滤特殊格式后的字符串
    var ctframe: CTFrame?
    var globalAttrs: Dictionary<NSAttributedStringKey, Any> {
        get {
            var dict = [NSAttributedStringKey:Any]()
            dict[NSAttributedStringKey.font] = self.font;
            dict[NSAttributedStringKey.foregroundColor] = self.textColor;
            return dict
        }
    }
    var attrString: NSAttributedString {
        get {
            let attStr = NSMutableAttributedString(string: self.filteredText)
            attStr.addAttributes(self.globalAttrs, range:NSMakeRange(0, attStr.length))
            for item in attrs {
                if let color = item.textColor, let range = item.range {
                    attStr.addAttribute(.foregroundColor, value: color, range: range)
                }
            }
            return attStr
        }
    }
    
    var clickHandler: ((_ attr: YNSuperLabelAttr) -> Void)?    //  点击回调
    
    // 自定义样式
    
    var defaultStyle:(() -> (YNSuperLabelStyle))?
    var priceStyle:(() -> (YNSuperLabelStyle))?
    var telStyle:(() -> (YNSuperLabelStyle))?
    var linkStyle:(() -> (YNSuperLabelStyle))?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1, y: -1)
        
        let attrStr = self.attrString
        
        let range: CFRange = CFRangeMake(0, attrStr.length)
        let path = CGMutablePath()
        path.addRect(bounds)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrStr as CFAttributedString)
        self.ctframe = CTFramesetterCreateFrame(framesetter, range, path, nil)
        CTFrameDraw(self.ctframe!, context)
    }
    
    // 解析特定格式
    
    func parse(text: String) {
        self.filteredText = text
        self.filteredText = self.parse(price: self.filteredText)
        self.filteredText = self.parse(tel: self.filteredText)
        self.filteredText = self.parse(link: self.filteredText)
    }
    
    func parse(price text: String) -> String {
        let pattern = "\\^price\\([^\\(]*\\)"
        return self.parse(pattern: pattern, in: text, type: .price)
    }
    
    func parse(tel text: String) -> String {
        let pattern = "\\^tel\\([^\\(]*\\)"
        return self.parse(pattern: pattern, in: text, type: .tel)
    }
    
    func parse(link text: String) -> String {
        let pattern = "\\^link\\([^\\(]*\\)"
        return self.parse(pattern: pattern, in: text, type: .link)
    }
    
    func parse(pattern: String, in text: String, type: YNSuperLabelAttrType) -> String {
        guard let exp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            print("Error: NSRegularExpression")
            return ""
        }
        
        let count = exp.numberOfMatches(in: text, options: .reportProgress, range: NSMakeRange(0, text.count))
        var temp = text
        for _ in 0..<count {
            temp = self.replaceFistMatch(with: pattern, in: temp, type: type)
        }
        return temp
    }
    
    
    /// 替换匹配到第一个字符串
    ///
    /// - Parameters:
    ///   - pattern: <#pattern description#>
    ///   - string: <#string description#>
    ///   - type: <#type description#>
    /// - Returns: <#return value description#>
    func replaceFistMatch(with pattern: String, in string: String, type: YNSuperLabelAttrType) -> String {
    
        guard let exp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            print("Error: NSRegularExpression")
            return ""
        }
    
        guard let result = exp.firstMatch(in: string, options: .reportProgress, range: NSMakeRange(0, string.count)) else {
            print("Error: firstMatch")
            return ""
        }
        
        let s = string as NSString
        
        var attr = YNSuperLabelAttr()
        attr.content = self.valueInBracket(text: s.substring(with: result.range))
        attr.range = NSMakeRange(result.range.location, attr.content!.count)
        attr.textColor = self.textColor
        attr.type = type
        
        switch type {
        case .default:
            if let style = self.defaultStyle {
                let s = style()
                attr.textColor = s.textColor
            }
        case .price:
            if let style = self.priceStyle {
                let s = style()
                attr.textColor = s.textColor
            }
        case .tel:
            if let style = self.telStyle {
                let s = style()
                attr.textColor = s.textColor
            }
        case .link:
            if let style = self.linkStyle {
                let s = style()
                attr.textColor = s.textColor
            }
        }
        
        attrs.append(attr)
        return string.replacingCharacters(in: Range(result.range, in: string)!, with: attr.content!)
    }
    
    
    /// 将内容取出
    /// ^price(¥311.20) -> (¥311.20) -> ¥311.20
    ///
    /// - Parameter text: <#text description#>
    /// - Returns: <#return value description#>
    func valueInBracket(text: String) -> String {
        let pattern = "\\([^\\(]*\\)"
        
        guard let exp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            print("Error: NSRegularExpression")
            return ""
        }
        
        guard let result = exp.firstMatch(in: text, options: .reportProgress, range: NSMakeRange(0, text.count)) else {
            print("Error: firstMatch")
            return ""
        }
    
        let t = text as NSString
        var str = t.substring(with: result.range)
        str = str.replacingOccurrences(of: "(", with: "")
        str = str.replacingOccurrences(of: ")", with: "")
        return str
    }
    
    func suggestedFrame() -> CGRect {
        let attStr = self.attrString
        let framesetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attStr.length), self.globalAttrs as CFDictionary, CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude), nil)
        let vFrame = self.frame
        return CGRect(x: vFrame.origin.x, y: vFrame.origin.y, width: size.width, height: size.height)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.tapCount == 1 {
            let point = touch!.location(in: self)
            self.checkSpecialAction(point: point)
        }
    }
    
    
    /// 处理点击事件
    ///
    /// - Parameter point: <#point description#>
    func checkSpecialAction(point: CGPoint) {
        guard let frame = self.ctframe else {
            print("ctframe have no value")
            return
        }
        
        let lines: CFArray = CTFrameGetLines(frame)
        var lineOrigins = Array(repeatElement(CGPoint.zero, count: CFArrayGetCount(lines)))
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &lineOrigins)
        
        let lineCount = CFArrayGetCount(lines)
        
        for lineIndex in 0..<lineCount {
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, lineIndex), to: CTLine.self) // C指针类型转OC类型
            let origin = lineOrigins[lineIndex]
            let runs = CTLineGetGlyphRuns(line)
            let runCount = CFArrayGetCount(runs)
            for runIndex in 0..<runCount {
                let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, runIndex), to: CTRun.self)
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                let width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading)
                let range = CTRunGetStringRange(run)
                
                let offset = CTLineGetOffsetForStringIndex(line, range.location, nil)
                let height: CGFloat  = ascent + descent;  // Not cantain leading
                let y = self.bounds.size.height - origin.y + descent - height
                let rect = CGRect(x: origin.x + offset, y: y, width: CGFloat(width), height: ascent + descent)
                
                if rect.contains(point) {
                    let index = CTLineGetStringIndexForPosition(line, CGPoint(x: point.x, y: 0))
                    
                    for item in attrs {
                        if let range = item.range {
                            if index >= range.location && index <= range.location + range.length {
                                if let handler = self.clickHandler {
                                    handler(item)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct YNSuperLabelAttr {
    var type: YNSuperLabelAttrType?
    var range: NSRange?
    var content: String?
    var textColor: UIColor?
}

struct YNSuperLabelStyle {
    var textColor: UIColor?
}
