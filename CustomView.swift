//
//  CustomView.swift
//
//  Created by Ilan B on 25/06/2018.
//  Copyright © 2018 Ilan B. All rights reserved.
//

import Foundation

protocol CustomViewProtocol {
    typealias ShowCompletion = ((Bool) -> Void)?
    
    static func show<T: CustomView>(fromViewController viewController: UIViewController, animated: Bool, completion: ShowCompletion) -> T
    static func show<T: CustomView>(fromView view: UIView, insets: UIEdgeInsets, animated: Bool, completion: ShowCompletion) -> T
    func hide(animated: Bool, completion: ShowCompletion)
}

protocol CustomAnimatable {
    func playAnimation()
    func stopAnimation()
}

class CustomView: UIView, NibLoadable {
    // MARK: Properties

    var animationDuration = 0.3
    fileprivate(set) var isAnimating = false
    
    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureView()
    }
    
    // MARK: - Private methods

    private func configureView() {
        self.alpha = 0
    }
    
    fileprivate func show(animated: Bool = true, completion: ShowCompletion = nil) {
        self.superview?.bringSubview(toFront: self)

        if animated {
            UIView.animate(withDuration: self.animationDuration, animations: { self.alpha = 1 }, completion: completion)
            
            return
        }

        self.alpha = 1
        completion?(true)
    }
}

// MARK: - CustomViewProtocol
extension CustomView: CustomViewProtocol {
    static func show<T: CustomView>(fromViewController viewController: UIViewController, animated: Bool = true, completion: ShowCompletion = nil)
        -> T {
        guard let subview = loadFromNib() as? T else {
            fatalError("The subview is expected to be of type \(T.self)")
        }

        let insets = UIEdgeInsets.zero
        let views: [String: Any] = ["subview": subview, "topGuide": viewController.topLayoutGuide, "bottomGuide": viewController.bottomLayoutGuide]
        subview.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(subview)
        let options: NSLayoutFormatOptions = []
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[subview]-\(insets.right)-|",
                                           options: options, metrics: nil, views: views))
        let format = "V:[topGuide]-\(insets.top)-[subview]-\(insets.bottom)-[bottomGuide]"
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: nil, views: views))
        subview.alpha = 0
        subview.superview?.sendSubview(toBack: subview)
        subview.show(animated: animated) { finished in
            completion?(finished)
            subview.playAnimation()
        }

        return subview
    }
    
    static func show<T: CustomView>(fromView view: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero, animated: Bool = true,
                                    completion: ShowCompletion = nil) -> T {
        guard let subview = loadFromNib() as? T else {
            fatalError("The subview is expected to be of type \(T.self)")
        }

        let views: [String: Any] = ["subview": subview]
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        let options: NSLayoutFormatOptions = []
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(insets.left)-[subview]-\(insets.right)-|", options: options,
                                                           metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(insets.top)-[subview]-\(insets.bottom)-|", options: options,
                                                           metrics: nil, views: views))
        subview.alpha = 0
        subview.superview?.sendSubview(toBack: subview)
        subview.show(animated: animated) { finished in
            completion?(finished)
            subview.playAnimation()
        }

        return subview
    }
    
    func hide(animated: Bool = true, completion: ShowCompletion = nil) {
        self.stopAnimation()

        let closure: (Bool) -> Void = { (finished) in
            self.removeFromSuperview()
        }

        if animated {
            UIView.animate(withDuration: self.animationDuration, delay: 0.25, animations: { self.alpha = 0 }, completion: { (finished) in
                closure(finished)
                completion?(finished)
            })
            
            return
        }

        self.alpha = 0
        closure(true)
        completion?(true)
    }
}

// MARK: - CustomAnimatable
extension CustomView: CustomAnimatable {
    @objc func playAnimation() {
        self.isAnimating = true
    }
    
    @objc func stopAnimation() {
        self.isAnimating = false
    }
}
