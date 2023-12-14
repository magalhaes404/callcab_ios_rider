//
// NewTaxiLoader.swift
// NewTaxiLoader
//
//  Created by Manikandan.B
//

import UIKit

open class NewTaxiLoader: UIView {
    
    public let circleLayer = CAShapeLayer()
    open private(set) var isAnimating = false
    open var animationDuration : TimeInterval = 2.0
    let viewLoader = UIView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open func commonInit() {
        viewLoader.frame = CGRect(x: 5, y:0, width: 3 ,height: 2)
        viewLoader.backgroundColor = UIColor.ThemeYellow
        viewLoader.isHidden = true
        self.addSubview(viewLoader)
    }
    
    func makeAnimate()
    {
        if self.isAnimating
        {
            viewLoader.isHidden = false
            self.moveHelpAnimation(imgScroll: viewLoader)
        }
        else
        {
            viewLoader.isHidden = true
        }
    }
    
    func moveHelpAnimation(imgScroll:UIView)
    {
        if !self.isAnimating
        {
            return
        }
        
        UIView.animate(withDuration:  1.2, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            imgScroll.frame = CGRect(x: (self.bounds.size.width-8), y:0, width: 3 ,height: 2)
        }, completion: { (finished: Bool) -> Void in
            self.moveHelp(imgScroll: imgScroll)
            self.moveHelpAnimationAgain(imgScroll:imgScroll)
        })
    }
    
    func moveHelp(imgScroll:UIView)
    {
        UIView.animate(withDuration:  0.6, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            imgScroll.frame = CGRect(x: imgScroll.frame.origin.x, y:0, width: 50 ,height: 2)
        }, completion: { (finished: Bool) -> Void in
        })
    }
    
    
    func moveHelpAnimationAgain(imgScroll:UIView)
    {
        UIView.animate(withDuration: 1.2, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            imgScroll.frame = CGRect(x: 5, y: 0, width: 3,height: 2);
        }, completion: { (finished: Bool) -> Void in
            self.moveHelp(imgScroll: imgScroll)
            self.moveHelpAnimation(imgScroll:imgScroll)
        })
    }

    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    open func forceBeginRefreshing() {
        self.isAnimating = false
        self.beginRefreshing()
    }
    
    open func beginRefreshing()
    {
        self.isAnimating = true
        self.makeAnimate()
    }
    
    open func endRefreshing () {
        self.isAnimating = false
        self.makeAnimate()
    }
    
}
extension UIViewController{
    func startAnimation(isDelete:Bool = false,whereTo:CGFloat,animationView:UIView) {
        var yValue = whereTo
        
        if self.checkDevice() {
            yValue = whereTo + 13
        }
        animationView.frame =  CGRect(x: -20, y: yValue, width: 0, height: 2)
        if isDelete {
            animationView.removeFromSuperview()
            return
        }else {
            animationView.alpha = 1.0
            animationView.removeFromSuperview()
            animationView.backgroundColor = .black
            self.view.addSubview(animationView)
            UIView.animate(withDuration: 1.2,
                           delay: 0.2,
                           options: [.curveEaseIn,.curveEaseOut],
                           animations: { [weak self] in
                            guard let welf = self else{
                                return
                            }
                            animationView.frame = CGRect(x: welf.view.bounds.width, y: yValue, width: 200, height: 2)
            }) { [weak self] (finish) in
                guard let welf = self else{return}
                if isDelete || animationView.superview == nil {
                    animationView.removeFromSuperview()
                    animationView.layer.removeAllAnimations()
                    return
                }else {
                    animationView.frame =  CGRect(x: -20, y: yValue, width: 0, height: 2)
                    welf.startAnimation(isDelete: isDelete, whereTo: whereTo, animationView: animationView)
                }
                
            }
        }
    }

}
