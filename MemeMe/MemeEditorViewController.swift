//
//  FirstViewController.swift
//  MemeMe
//
//  Created by Michael Recachinas on 7/13/15.
//  Copyright (c) 2015 Michael Recachinas. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    // MARK: - IBOutlets
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // MARK: - Constants
    
    let TOP_DEFAULT_TEXT = "TOP"
    let BOTTOM_DEFAULT_TEXT = "BOTTOM"
    
    var oldText: String = ""
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]
    
    // MARK: - view appear, load, and disappear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField(topTextField)
        setupTextField(bottomTextField)
    }

    override func viewWillAppear(animated: Bool) {
        // if there's an image in the imageView, enable the share button
        if let _ = imageView.image {
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
        
        // if there's a camera in the hardware, enable the camera button
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // set up the keyboard observers for when the keyboard is toggled
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove keyboard observers
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - keyboard-related methods
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // only fire on bottom text field
        if bottomTextField.isFirstResponder() {
            
            // if the view hasn't shifted yet, shift it up
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // shift the view back to 0
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - textField related methods
    
    func setupTextField(textField: UITextField) {
        // set the text field attributes
        textField.defaultTextAttributes = memeTextAttributes
        
        // center the text fields
        textField.textAlignment = NSTextAlignment.Center
        
        textField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // keep track of the old text before clearing it
        oldText = textField.text!
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // this will re-populate the "placeholder" (not an actual placeholder though)
        // if the user hits "return" and the field is empty
        if textField.text!.isEmpty {
            textField.text = oldText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // on hitting "return", the keyboard should close
        textField.resignFirstResponder()
        return true
    }
    
    func resetText() {
        topTextField.text = TOP_DEFAULT_TEXT
        bottomTextField.text = BOTTOM_DEFAULT_TEXT
    }
    
    // MARK: - helpers for creating Meme
    
    func hideStatusBarAndToolbar() {
        topToolbar.hidden = true
        bottomToolbar.hidden = true
    }
    
    func showStatusBarAndToolbar() {
        topToolbar.hidden = false
        bottomToolbar.hidden = false
    }
    
    func takeScreenshot() -> UIImage {
        // uses the context approach
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func generateMemedImage() -> UIImage {
        hideStatusBarAndToolbar()
        let memedImage = takeScreenshot()
        showStatusBarAndToolbar()
        
        return memedImage
    }
    
    // MARK: - Save/Cancel
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }

    func cancel() {
        imageView.image = nil
        resetText()
        shareButton.enabled = false
    }
    
    // MARK: - ImagePickerController-related methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // if the image exists, set the imageView to that image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickImageFromSource(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func pickAnImage(sender: UIBarButtonItem) {
        pickImageFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickFromCamera(sender: UIBarButtonItem) {
        pickImageFromSource(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func shareAction(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (s: String?, ok: Bool, items: [AnyObject]?, err: NSError?) -> Void in
            if ok {
                self.save()
                NSLog("Successfully saved image.")
            } else if err != nil {
                NSLog("Error: \(err)")
            } else {
                NSLog("Unknown cancel -- user likely clicked \"cancel\" to dismiss activity view.")
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        cancel()
    }
}

