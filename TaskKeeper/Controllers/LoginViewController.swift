//
//  LoginViewController.swift
//  TaskKeeper
//
//  Created by Светлана Шардакова on 06.07.2020.
//  Copyright © 2020 Светлана Шардакова. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate  {
    
    let segueIdentifier = "showTasks"
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification , object: nil)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener ({ [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        scrollView.contentInset.bottom = kbFrameSize.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        scrollView.contentInset.bottom = 0
        
        return false
    }
    
    func displayWarningLabel(withText text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            self?.warnLabel.alpha = 1
        }) { [weak self] complete in
            self?.warnLabel.alpha = 0
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
                guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Info is incorrect")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Error occured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: "showTasks", sender: nil)
                return
            }
            
            self?.displayWarningLabel(withText: "No such user")
        })
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
                displayWarningLabel(withText: "Info is incorrect")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (authResult, error) in
                
                guard error == nil, let user = authResult?.user else {
                    
                    print(error!.localizedDescription)
                    return
                }
                
                let userRef = self?.ref.child(user.uid)
                userRef?.setValue(["email" : user.email])
            })
        }

}

