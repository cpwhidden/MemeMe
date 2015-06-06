//
//  ViewController.swift
//  MemeMe
//
//  Created by Christopher Whidden on 6/1/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var aspectConstraint: NSLayoutConstraint?
    
    var memes = [Meme]()
    
    let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.delegate = self
        bottomTextField.delegate = self
        shareButton.enabled = false
        
        // Configure text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]

        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        self.subscribeToKeyboardNotifications()
        memes = appDelegate.memes
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolbar.hidden = true
        bottomToolbar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        
        
        let croppedCG = CGImageCreateWithImageInRect(memedImage.CGImage, self.imageView.frame)
        let croppedImage = UIImage(CGImage: croppedCG)

        topToolbar.hidden = false
        bottomToolbar.hidden = false
        
        return croppedImage!
    }
    
    func save() {
        //Create the meme
        var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image!, memedImage: generateMemedImage())
        
        appDelegate.memes.append(meme)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Determine which control is first responder
        let fr: UIView?
        if topTextField.isFirstResponder() {
            fr = topTextField
        } else if bottomTextField.isFirstResponder() {
            fr = bottomTextField
        } else {
            fr = nil
        }
        
        // Only shift view if necessary and only move the minimum amount necessary
        if let _fr = fr {
            let move = getKeyboardHeight(notification) - self.view.bounds.height + _fr.frame.maxY
            if move > 0 {
                self.view.frame.origin.y -= move
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    @IBAction func pickImage(sender: AnyObject) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .PhotoLibrary
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func captureImage(sender: AnyObject) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .Camera
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.save()
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
            if let constraint = aspectConstraint {
                self.imageView.removeConstraint(constraint)
            }
            let ratio = image.size.width / image.size.height
            aspectConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.imageView, attribute: NSLayoutAttribute.Height, multiplier: ratio, constant: 0)
            aspectConstraint!.priority = 1000
            self.imageView.addConstraint(aspectConstraint!)
            shareButton.enabled = true
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

