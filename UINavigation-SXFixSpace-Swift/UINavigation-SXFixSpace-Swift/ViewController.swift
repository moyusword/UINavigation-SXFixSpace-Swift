//
//  ViewController.swift
//  UINavigation-SXFixSpace-Swift
//
//  Created by charles on 2017/11/2.
//  Copyright © 2017年 charles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        view.backgroundColor = UIColor.white
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        btn.backgroundColor = UIColor.orange
        btn.setTitle("进入相册", for: .normal)
        btn.addTarget(self, action: #selector(intoAlbum), for: .touchUpInside)
        view.addSubview(btn)
        
        
        guard let nav = navigationController else { return }
        if nav.viewControllers.count % 2 == 0 {
            navigationItem.titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        } else {
            navigationItem.title = "\(nav.viewControllers.count)"
        }
        
        configBarItem()
        
    }

    func configBarItem() {
        
        guard let nav = navigationController else { return }
        
        if nav.viewControllers.count % 2 != 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_add"), target: self, action: #selector(pushAction))
        } else {
            let btnView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
            
            let btn1 = UIButton(type: .custom)
            btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            btn1.setImage(UIImage(named: "nav_add"), for: .normal)
            btn1.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
            btnView.addSubview(btn1)
            
            let btn2 = UIButton(type: .custom)
            btn2.frame = CGRect(x: 40, y: 0, width: 40, height: 40)
            btn2.setImage(UIImage(named: "nav_add"), for: .normal)
            btn2.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
            btnView.addSubview(btn2)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnView)
        }
        
        if nav.viewControllers.count > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_back"), target: self, action: #selector(popAction))
        }
    }
    
    @objc func pushAction() {
        navigationController?.pushViewController(ViewController(), animated: true)
    }
    
    @objc func popAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func intoAlbum() {
        let vc = UIImagePickerController()
        present(vc, animated: true, completion: nil)
    }

}

