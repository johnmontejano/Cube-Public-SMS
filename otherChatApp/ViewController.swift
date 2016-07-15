//
//  ViewController.swift
//  otherChatApp
//
//  Created by John Montejano on 7/13/16.
//  Copyright © 2016 John Montejano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var enterChatButton: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
                // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func enterChatButtonStart(sender: AnyObject) {
        if nickNameTextField != ""{
            self.performSegueWithIdentifier("startChatting", sender: self)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ChatViewController {
            destination.senderId = UIDevice.currentDevice().identifierForVendor!.UUIDString
            destination.senderDisplayName = nickNameTextField.text
            destination.chatRooomName = "Public Room Chat"
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}