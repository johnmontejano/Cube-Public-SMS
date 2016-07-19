////
////  ChatViewController.swift
////  otherChatApp
////
////  Created by John Montejano on 7/13/16.
////  Copyright © 2016 John Montejano. All rights reserved.
////





import UIKit
import JSQMessagesViewController
import MobileCoreServices
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON
import Alamofire



class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var outgoingBubble:JSQMessagesBubbleImage!
    var incomingbubbleImage:JSQMessagesBubbleImage!
    var messages = [JSQMessage]()
    var avatar = [String:JSQMessagesAvatarImage]()
    var chatRooomName: String!
    var ref = FIRDatabase.database().reference()
    var usersId = FIRAuth.auth()?.currentUser?.uid
    
    var user = FIRAuth.auth()?.currentUser
    
    
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        func buttonAction(sender:UIButton!){
        
        //        }
        
        //        self.senderId = "01"
        //        self.senderDisplayName = "John"
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
        self.incomingbubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        //        let button = UIBarButtonItem(title: "Spanish", style: .Default, target: self, action: #selector(sendSpanishMessage)) // let preferred over var here
        //        button.frame = CGRectMake(100, 100, 100, 50)
        //        button.backgroundColor = UIColor.greenColor()
        //        button.setTitle("Button", forState: UIControlState.Normal)
        //        self.view.addSubview(button)
        
        ref.child("PublicChatRoom").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            let info = snapshot.value! as! NSDictionary
            
            let msg = JSQMessage(senderId: info["senderId"] as! String, senderDisplayName: info["senderName"] as! String, date: NSDate.init(timeIntervalSince1970: info["timestamp"] as! Double), text: info["text"] as! String)
            self.messages.append(msg)
            self.setupAvatarColor(msg.senderId, name: msg.senderDisplayName, incoming: true)
            
            
            
            self.finishReceivingMessage()
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let sheet = UIAlertController(title: "Media Messages", message: "Please Select A media", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert: UIAlertAction!) -> Void in
            sheet.dismissViewControllerAnimated(true, completion: nil)
        }
        let sendPhoto = UIAlertAction(title: "Send Photo", style: UIAlertActionStyle.Default){ ( alert: UIAlertAction!) -> Void in
            self.photolibrary()
        }
        sheet.addAction(sendPhoto)
        sheet.addAction(cancel)
        presentViewController(sheet, animated: true, completion: nil)
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        
        
        
        
        
        
        let msg = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        if self.avatar[senderId] == nil {
            self.setupAvatarColor(msg.senderId, name: msg.senderDisplayName, incoming: true)
            
        }
        
        
        let message = text
        // what does this line do?
        var messageForURL = ""
        //does a for loop duhhhhhhh
        // what does this line do?
        for character in message.characters {
            // what does this line do?
            if character == " " {
                // literally gives %20 cause that stands for a space in a url link
                // what does this line do?
                messageForURL += "%20"
                // what does this line do?
            }
                // what does this line do?
            else {
                //append means to add to the chars
                // what does this line do?
                messageForURL.append(character)
                // what does this line do?
            }
            //closes the for loop<>
            // |
            // what does this line do?
        }
        
        
        // what does this line do?
        let apiToContact = "https://www.googleapis.com/language/translate/v2?key=AIzaSyDDTV4qnVy3CK0CwtXLG0h1HYrtKmIWM8c&q=\(messageForURL)&source=en&target=es"
        
        // This code will call the google translate api
        Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    
                    let data = json["data"]["translations"][0]["translatedText"].stringValue
                    
                    print("Data is : " + data)
                    
                    
                    
                    self.ref.child("PublicChatRoom").childByAutoId().setValue(
                        ["text": data,
                            "senderId": senderId,
                            "senderName": senderDisplayName,
                            "timestamp": date.timeIntervalSince1970,
                            "MediaType" : "TEXT" ])
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    
                    
                    
                    self.finishSendingMessageAnimated(true)
                    
                    
                    
                    // Do what you need to with JSON here!
                    // The rest is all boiler plate code you'll use for API requests
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        
        
        
        
    }
    
    //MARK: UIcollectionView new methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        
        if message.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingbubbleImage
        
    }
    
    //picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let img = image
        let jsqImage = JSQPhotoMediaItem(image: img)
        let msg = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate(), media: jsqImage)
        self.messages.append(msg)
        if self.avatar[msg.senderId] == nil {
            self.setupAvatarColor(msg.senderId, name: msg.senderDisplayName, incoming: false)
        }
        self.finishSendingMessage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        return self.avatar[message.senderId] as! JSQMessageAvatarImageDataSource
    }
    
    func setupAvatarColor(id: String, name: String, incoming: Bool){
        let diameter = incoming ? UInt((collectionView?.collectionViewLayout.incomingAvatarViewSize.width)!) : UInt((collectionView?.collectionViewLayout.outgoingAvatarViewSize.width)!)
        let color =  UIColor.lightGrayColor()
        let initials = name.substringToIndex(name.startIndex.advancedBy(min(3,name.characters.count)))
        let userImg  = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(12), diameter: diameter)
        self.avatar[id] = userImg
    }
    
    func photolibrary() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.imagePicker.mediaTypes = [kUTTypeImage as String]
        self.presentViewController(self.imagePicker, animated: true, completion: nil )
    }
    
}



