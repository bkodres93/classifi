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
        if courseCodes[course] {
            return true
        }
        else if courseCRNs[course] {
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
        var downloadedCourseDataArray: Dictionary<String, String>[] = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as Dictionary<String, String>[]
        if error {
            println("Could not parse JSON with error: " + error.description)
        }
        else {
            
        }
        var tempCourse:Course
        for courseInfo: Dictionary<String, String> in downloadedCourseDataArray {
            tempCourse = Course(crn: courseInfo["CRN"]!, course: courseInfo["Course"]!, num: courseInfo["Num"]!, title: courseInfo["Title"]!, courseType: courseInfo["Type"]!, teacher: courseInfo["Teacher"]!, days1: courseInfo["Days1"]!, days2: courseInfo["Days2"]!, days3: courseInfo["Days3"]!, location1: courseInfo["Location1"]!, location2: courseInfo["Location2"]!, location3: courseInfo["Location3"]!, timeBegin1: courseInfo["timeBegin1"]!.toInt()!, timeBegin2: courseInfo["timeBegin2"]!.toInt()!, timeBegin3: courseInfo["timeBegin3"]!.toInt()!, timeEnd1: courseInfo["timeEnd1"]!.toInt()!, timeEnd2: courseInfo["timeEnd2"]!.toInt()!, timeEnd3: courseInfo["timeEnd3"]!.toInt()!, credits: courseInfo["credits"]!.toInt()!)
                courseCRNs[courseInfo["CRN"]!] = tempCourse
            // If the course code already has an index add it to the existing index, otherwise add it
            if courseCodes[courseInfo["Course"]! + courseInfo["Num"]!] {
                var theCourseCodeDictionary = courseCodes[tempCourse.courseCode]!
                theCourseCodeDictionary[tempCourse.crn] = tempCourse
            }
            else {
                println(tempCourse.courseCode)
                courseCodes[tempCourse.courseCode] = [tempCourse.crn:tempCourse]
            }
        }
    }
}