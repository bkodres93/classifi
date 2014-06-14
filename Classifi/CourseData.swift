//
//  CourseData.swift
//  Classifi
//
//  Created by Bryce Langlotz on 6/13/14.
//  Copyright (c) 2014 Bryce Langlotz. All rights reserved.
//

import Foundation

class Course {
    var crn, course, num, courseCode, title, courseType, teacher, days1, days2, days3, location1, location2, location3:String
    var timeBegin1, timeBegin2, timeBegin3, timeEnd1, timeEnd2, timeEnd3, credits:Int
    
    init(crn:String, course:String, num:String, title:String, courseType:String, teacher:String, days1:String, days2:String, days3:String, location1:String, location2:String, location3:String,  timeBegin1:Int, timeBegin2:Int, timeBegin3:Int, timeEnd1:Int, timeEnd2:Int, timeEnd3:Int,credits:Int) {
        self.crn = crn
        self.course = course
        self.num = num
        self.courseCode = course + num
        self.title = title
        self.courseType = courseType
        self.teacher = teacher
        self.days1 = days1
        self.days2 = days2
        self.days3 = days3
        self.location1 = location1
        self.location2 = location2
        self.location3 = location3
        self.timeBegin1 = timeBegin1
        self.timeBegin2 = timeBegin2
        self.timeBegin3 = timeBegin3
        self.timeEnd1 = timeEnd1
        self.timeEnd2 = timeEnd2
        self.timeEnd3 = timeEnd3
        self.credits = credits
    }
}

class CourseData {
    
    var courseCodes = Dictionary<String, Dictionary<String, Course>>()
    var courseCRNs = Dictionary<String, Course>()
    @lazy var data = NSMutableData()
    
    class var sharedInstance: CourseData {
    struct Static {
        static var instance: CourseData?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CourseData()
        }
        
        return Static.instance!
    }
    
    func courseExists(course:String) -> Bool {
        if let theCourse = courseCodes[course] {
            return true
        }
        else if let theCourse = courseCRNs[course] {
            return true
        }
        return false
    }
    
    func startConnection(){
        let urlPath: String = "http://brycelanglotz.com/Classifi/VirginiaTech.json"
        parseJSON(getJSON(urlPath))
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest))
    }
    
    func parseJSON(inputData: NSData) {
        var error: NSError?
        var downloadedCourseDataArray: NSArray = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSArray
        
        var crn, course, num, courseCode, title, courseType, teacher, days1, days2, days3, location1, location2, location3:String
        var timeBegin1 = 0, timeBegin2 = 0, timeBegin3 = 0, timeEnd1 = 0, timeEnd2 = 0, timeEnd3 = 0, credits = 0
        var tempCourse:Course

        
        for courseInfo : AnyObject in downloadedCourseDataArray {
            crn = courseInfo["CRN"] as String
            course = courseInfo["Course"] as String
            num = courseInfo["Num"] as String
            
            if let aCourse = courseCodes[course + num] {
                
            }
            else {
                title = courseInfo["Title"] as String
                courseType = courseInfo["Type"] as String
                teacher = courseInfo["Teacher"] as String
                days1 = courseInfo["Days1"] as String
                days2 = courseInfo["Days2"] as String
                days3 = courseInfo["Days3"] as String
                location1 = courseInfo["Location1"] as String
                location2 = courseInfo["Location2"] as String
                location3 = courseInfo["Location3"] as String
                timeBegin1 = courseInfo["timeBegin1"] as Int
                timeBegin2 = courseInfo["timeBegin2"] as Int
                timeBegin3 = courseInfo["timeBegin3"] as Int
                timeEnd1 = courseInfo["timeEnd1"] as Int
                timeEnd2 = courseInfo["timeEnd2"] as Int
                timeEnd3 = courseInfo["timeEnd3"] as Int
                credits = courseInfo["credits"] as Int
                tempCourse = Course(crn: crn, course: course, num: num, title: title, courseType: courseType, teacher: teacher, days1: days1, days2: days2, days3: days3, location1: location1, location2: location2, location3: location3, timeBegin1: timeBegin1, timeBegin2: timeBegin2, timeBegin3: timeBegin3, timeEnd1: timeEnd1, timeEnd2: timeEnd2, timeEnd3: timeEnd3, credits: credits)
                println("New Course Code: " + course + num)
            }
        }
    }
}