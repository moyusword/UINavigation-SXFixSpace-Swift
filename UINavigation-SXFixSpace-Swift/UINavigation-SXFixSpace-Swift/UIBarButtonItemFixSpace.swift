//
//  UIBarButtonItemFixSpace.swift
//  UINavigation-SXFixSpace-Swift
//
//  Created by charles on 2017/11/2.
//  Copyright © 2017年 charles. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    static func swizzleMethod(_ cls: AnyClass, originalSelector: Selector, swizzleSelector: Selector){
        
        let originalMethod = class_getInstanceMethod(cls, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(cls, swizzleSelector)!
        let didAddMethod = class_addMethod(cls,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(cls,
                                swizzleSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod,
                                           swizzledMethod)
        }
    }
}


extension UIApplication {
    private static let classSwizzedMethod: Void = {
        UIImagePickerController.sx_swizzleMethod
        UINavigationBar.sx_swizzleMethod
    }()
    
    open override var next: UIResponder? {
        UIApplication.classSwizzedMethod
        return super.next
    }
}

public var sx_defultFixSpace: CGFloat = 0

public var sx_disableFixSpace: Bool = false

extension UIImagePickerController {
    
    private struct AssociatedKeys {
        static var tempDisableFixSpace = "tempDisableFixSpace"
    }
    
    static let sx_swizzleMethod: Void = {
        DispatchQueue.once(UUID().uuidString) {
            swizzleMethod(UIImagePickerController.self,
                          originalSelector: #selector(UIImagePickerController.viewWillAppear(_:)),
                          swizzleSelector: #selector(UIImagePickerController.sx_viewWillAppear(_:)))
            
            
            swizzleMethod(UIImagePickerController.self,
                          originalSelector: #selector(UIImagePickerController.viewWillDisappear(_:)),
                          swizzleSelector: #selector(UIImagePickerController.sx_viewWillDisappear(_:)))
            
        }
    }()
    
    var tempDisableFixSpace: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.tempDisableFixSpace) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.tempDisableFixSpace,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func sx_viewWillAppear(_ animated: Bool) {
        tempDisableFixSpace = sx_disableFixSpace
        sx_disableFixSpace = true
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .automatic
        }
        sx_viewWillAppear(animated)
    }
    
    @objc func sx_viewWillDisappear(_ animated: Bool) {
        sx_disableFixSpace = tempDisableFixSpace
        sx_viewWillDisappear(animated)
    }
}


extension UINavigationBar {

    static let sx_swizzleMethod: Void = {
        DispatchQueue.once(UUID().uuidString) {
            swizzleMethod(UINavigationBar.self,
                          originalSelector: #selector(UINavigationBar.layoutSubviews),
                          swizzleSelector: #selector(UINavigationBar.sx_layoutSubviews))
            
        }
    }()
    
    @objc func sx_layoutSubviews() {
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


