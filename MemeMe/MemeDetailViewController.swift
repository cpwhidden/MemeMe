//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Christopher Whidden on 6/5/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    @IBOutlet weak var memeImage: UIImageView!
    var image: UIImage?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        memeImage.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteMeme(sender: AnyObject) {
        appDelegate.memes.removeAtIndex(index!)
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
