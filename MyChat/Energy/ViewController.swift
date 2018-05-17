//
//  ViewController.swift
//  Closio
//
//  Created by Rahul on 24/04/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit
class ViewController: UIViewController, UITextFieldDelegate, SSASideMenuDelegate {
    
    //Outlets
    // Textfields
    @IBOutlet weak var txtEmailID: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    // Buttons
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnLoginWithFB: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    var window: UIWindow?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtEmailID.layer.borderColor = UIColor.white.cgColor
        txtEmailID.layer.borderWidth = 1
        txtEmailID.layer.cornerRadius = 5
        txtEmailID.layer.masksToBounds = true
        
        txtPassword.layer.borderColor = UIColor.white.cgColor
        txtPassword.layer.borderWidth = 1
        txtPassword.layer.cornerRadius = 5
        txtPassword.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func btnForgotPasswordTapped(_ sender: Any) {
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func btnSignInTapped(_ sender: Any) {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //MARK : Setup SSASideMenu
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
        let nav = UINavigationController(rootViewController: vc!)
//        let navItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(SSASideMenu.presentLeftMenuViewController))
//        nav.navigationItem.leftBarButtonItem = navItem
//        nav.navigationBar.isTranslucent = false
        let sideMenu = SSASideMenu(contentViewController: nav, leftMenuViewController: LeftMenuViewController())
        sideMenu.backgroundImage = UIImage(named: "Plain_bg")
        sideMenu.configure(SSASideMenu.MenuViewEffect(fade: true, scale: true, scaleBackground: false))
        sideMenu.configure(SSASideMenu.ContentViewEffect(alpha: 1.0, scale: 0.7))
        sideMenu.configure(SSASideMenu.ContentViewShadow(enabled: true, color: UIColor.black, opacity: 0.6, radius: 6.0))
        sideMenu.delegate = self
        window?.rootViewController = sideMenu
        window?.makeKeyAndVisible()
    }
    
    
    @IBAction func btnLoginWithFBTapped(_ sender: Any) {
    }
    
    
    @IBAction func btnRegisterTapped(_ sender: Any) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEmailID.resignFirstResponder()
        txtPassword.resignFirstResponder()
        return true
    }
    
    func sideMenuWillShowMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        //print("Will Show \(menuViewController)")
    }
    
    func sideMenuDidShowMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        //print("Did Show \(menuViewController)")
    }
    
    func sideMenuDidHideMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        //print("Did Hide \(menuViewController)")
    }
    
    func sideMenuWillHideMenuViewController(_ sideMenu: SSASideMenu, menuViewController: UIViewController) {
        //print("Will Hide \(menuViewController)")
    }
    func sideMenuDidRecognizePanGesture(_ sideMenu: SSASideMenu, recongnizer: UIPanGestureRecognizer) {
        //print("Did Recognize PanGesture \(recongnizer)")
    }
    
    
    
    
    
    
}


