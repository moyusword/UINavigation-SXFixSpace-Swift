//
//  UIBarButtonItemFixSpace.swift
//  UINavigation-SXFixSpace-Swift
//
//  Created by charles on 2017/11/2.
//  Copyright © 2017年 charles. All rights reserved.
//

import Foundation
import UIKit

public var sx_defultFixSpace: CGFloat = 0

public var sx_disableFixSpace: Bool = false

private var UIImagePickerController_tempDisableFixSpace = "UIImagePickerController_tempDisableFixSpace"

extension UIImagePickerController: UAwake {
    
    var tempDisableFixSpace: Bool {
        get {
            return objc_getAssociatedObject(self, &UIImagePickerController_tempDisableFixSpace) as! Bool
        }
        set {
            objc_setAssociatedObject(self,
                                     &UIImagePickerController_tempDisableFixSpace,
                                     UIImagePickerController_tempDisableFixSpace,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public static func awake() {
        DispatchQueue.once(UUID().uuidString) {
            swizzleMethod(UIImagePickerController.self,
                          originalSelector: #selector(UIImagePickerController.viewWillAppear(_:)),
                          swizzleSelector: #selector(UIImagePickerController.sx_viewWillAppear(_:)))
            
            
            swizzleMethod(UIImagePickerController.self,
                          originalSelector: #selector(UIImagePickerController.viewWillDisappear(_:)),
                          swizzleSelector: #selector(UIImagePickerController.sx_viewWillDisappear(_:)))
        }
    }
    
    @objc private func sx_viewWillAppear(_ animated: Bool) {
        tempDisableFixSpace = sx_disableFixSpace
        sx_disableFixSpace = true
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
        sx_viewWillAppear(animated)
    }
    
    @objc private func sx_viewWillDisappear(_ animated: Bool) {
        sx_disableFixSpace = tempDisableFixSpace
        sx_viewWillDisappear(animated)
    }
}


extension UINavigationBar: UAwake {
    public static func awake() {
        swizzleMethod(UINavigationBar.self,
                      originalSelector: #selector(UINavigationBar.layoutSubviews),
                      swizzleSelector: #selector(UINavigationBar.sx_layoutSubviews))
    }
    
    @objc private func sx_layoutSubviews() {
        sx_layoutSubviews()
        
        if #available(iOS 11.0, *) {
            if sx_disableFixSpace == false {
                layoutMargins = .zero
                let space = sx_defultFixSpace
                for view in subviews {
                    if NSStringFromClass(view.classForCoder).contains("ContentView") {
                        view.layoutMargins = UIEdgeInsetsMake(0, space, 0, space)
                    }
                }
            }
        }
    }
}

extension UINavigationItem {
    
    private enum BarButtonItem: String {
        case left = "_leftBarButtonItem"
        case right = "_rightBarButtonItem"
    }
    
    open override func setValue(_ value: Any?, forKey key: String) {
        
        if #available(iOS 11.0, *) {
            super.setValue(value, forKey: key)
        } else {
            if sx_disableFixSpace == false && (key == BarButtonItem.left.rawValue || key == BarButtonItem.right.rawValue) {
                
                guard let item = value as? UIBarButtonItem else { return }
                let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                space.width = sx_defultFixSpace - 16
                
                if key == BarButtonItem.left.rawValue {
                    leftBarButtonItems = [space, item]
                } else {
                    rightBarButtonItems = [space, item]
                }
            }
        }
    }
}


