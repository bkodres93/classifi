//
//  SubmissionViewController.swift
//  Classifi
//
//  Created by Bryce Langlotz on 6/10/14.
//  Copyright (c) 2014 Bryce Langlotz. All rights reserved.
//

import UIKit
import QuartzCore

class SubmissionViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    let SubmissionViewControllerCoursesDownloadingBoxSideLength:CGFloat = 150.0
    let SubmissionViewControllerCoursesDownloadingBoxCornerRadius:CGFloat = 15.0
    let SubmissionViewControllerCoursesDownloadingBoxLabelHeight:CGFloat = 75.0
    
    var requestedCourses:String[] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationController.title = "Classifi"
    }
    
    init(coder aDecoder: NSCoder!)
    {
        super.init(coder: aDecoder)
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.requestedCourses.count + 8;
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:SubmissionViewCell = self.tableView.dequeueReusableCellWithIdentifier("submissionViewCell") as SubmissionViewCell
        return cell
    }
    
    func removeKeyboard() {
        self.view.endEditing(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(SubmissionViewCell.self, forCellReuseIdentifier: "submissionViewCell")
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeKeyboard"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var coursesDownloadingBox = UIView(frame: CGRectMake(
            (CGRectGetWidth(self.view.bounds) / 2.0) - (SubmissionViewControllerCoursesDownloadingBoxSideLength / 2.0),
            (CGRectGetHeight(self.view.bounds) / 2.0) - SubmissionViewControllerCoursesDownloadingBoxSideLength,
            SubmissionViewControllerCoursesDownloadingBoxSideLength,
            SubmissionViewControllerCoursesDownloadingBoxSideLength))
        coursesDownloadingBox.layer.cornerRadius = SubmissionViewControllerCoursesDownloadingBoxCornerRadius
        coursesDownloadingBox.backgroundColor = Colors.asyncBoxBlack()
        
        var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        var frame = spinner.frame
        frame.origin.x = CGRectGetWidth(coursesDownloadingBox.frame) / 2.0 - CGRectGetWidth(frame) / 2.0
        frame.origin.y = CGRectGetWidth(coursesDownloadingBox.frame) / 2.0 - CGRectGetWidth(frame) / 2.0
        spinner.frame = frame
        spinner.startAnimating()
        coursesDownloadingBox.addSubview(spinner)
        
        var downloadingLabel = UILabel(frame: CGRectMake(
            0.0,
            CGRectGetHeight(coursesDownloadingBox.frame) - SubmissionViewControllerCoursesDownloadingBoxLabelHeight,
            CGRectGetWidth(coursesDownloadingBox.frame),
            SubmissionViewControllerCoursesDownloadingBoxLabelHeight))
        downloadingLabel.textAlignment = NSTextAlignment.Center
        downloadingLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        downloadingLabel.font = UIFont.systemFontOfSize(18.0)
        downloadingLabel.text = "Downloading"
        coursesDownloadingBox.addSubview(downloadingLabel)
        
        self.view.addSubview(coursesDownloadingBox)
        
        var myQueue = dispatch_queue_create("download_courses_task", nil);
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        dispatch_async(myQueue, ({
            CourseData.sharedInstance.startConnection()
            dispatch_async(dispatch_get_main_queue(), ({
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                coursesDownloadingBox.removeFromSuperview()
                spinner.stopAnimating()
                }))
            }))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}

class SubmissionViewCell: UITableViewCell, UITextFieldDelegate {
    
    let SubmissionViewCellLeftPadding:CGFloat = 15.0
    let SubmissionViewCellLeftCircleWidth:CGFloat = 10.0
    let SubmissionViewCellTextFieldLeftPadding:CGFloat = 15.0
    
    var statusCircle = UIView(frame: CGRectZero)
    var submissionTextField = UITextField(frame: CGRectZero)
    var scaleAnimation = CABasicAnimation(keyPath:"transform.scale");
    
    init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.statusCircle = UIView(frame: CGRectMake(
            SubmissionViewCellLeftPadding,
            (CGRectGetHeight(self.bounds) - SubmissionViewCellLeftCircleWidth) / 2.0,
            SubmissionViewCellLeftCircleWidth,
            SubmissionViewCellLeftCircleWidth))
        self.statusCircle.layer.cornerRadius = SubmissionViewCellLeftCircleWidth / 2.0;
        self.statusCircle.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(self.statusCircle)
        
        self.submissionTextField = UITextField(frame: CGRectMake(
            SubmissionViewCellLeftCircleWidth + SubmissionViewCellLeftPadding + SubmissionViewCellTextFieldLeftPadding,
            0.0,
            CGRectGetWidth(self.bounds) - SubmissionViewCellLeftCircleWidth,
            CGRectGetHeight(self.bounds)))
        self.submissionTextField.tintColor = Colors.classifiPurple()
        self.submissionTextField.delegate = self
        self.addSubview(self.submissionTextField)
        
        self.scaleAnimation.duration = 0.4;
        self.scaleAnimation.repeatCount = CFloat(Int.max);
        self.scaleAnimation.autoreverses = true;
        self.scaleAnimation.toValue = NSNumber.numberWithFloat(0.8);
        self.scaleAnimation.fromValue = NSNumber.numberWithFloat(1.2);
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let strings = textField.text?.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
            textField.text = strings[0]
        }
        self.statusCircle.layer.addAnimation(scaleAnimation, forKey: "scale")
        UIView.animateWithDuration(0.4, animations: {
            self.statusCircle.backgroundColor = Colors.classifiPurple()
            self.statusCircle.frame = CGRectMake(
                self.SubmissionViewCellLeftPadding,
                (CGRectGetHeight(self.bounds) - self.SubmissionViewCellLeftCircleWidth) / 2.0,
                self.SubmissionViewCellLeftCircleWidth,
                self.SubmissionViewCellLeftCircleWidth)
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField!) {
        self.statusCircle.layer.removeAllAnimations()
        if textField.text == "" {
            UIView.animateWithDuration(0.4, animations: {
                    self.statusCircle.backgroundColor = UIColor.lightGrayColor()
                })
        }
        else if CourseData.sharedInstance.courseExists(textField.text) {
            UIView.animateWithDuration(0.4, animations: {
                    self.statusCircle.frame = CGRectMake(0.0, CGRectGetHeight(self.bounds) / 2.0, 0.0, 0.0)
                })
            for theCourse in CourseData.sharedInstance.courseCodes[textField.text]!.values {
                textField.text = textField.text + " - " + theCourse.title
                break
            }
        }
        else {
            UIView.animateWithDuration(0.4, animations: {
                    self.statusCircle.backgroundColor = UIColor.redColor()
                })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}