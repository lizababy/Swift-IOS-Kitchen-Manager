//
//  DataHelper.swift
//  Kitchen Manager
//
//  Created by Liza Linto on 12/8/15.
//  Copyright © 2015 Liza Linto. All rights reserved.
//

import Foundation

class DataHelper {
    static let sharedInstance = DataHelper()  // singleton object
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    func loadDictionaryFromResource(file : String, type : String) -> NSDictionary? {
        // getting path to GroceryList.plist
        let fileName = file + "." + type
        let filePath = DataHelper.sharedInstance.fileInDocumentsDirectory(fileName)
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        
        if(!fileManager.fileExistsAtPath(filePath)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource(file, ofType: type) {
                do {
                    try fileManager.copyItemAtPath(bundlePath, toPath: filePath)
                }catch let error as NSError {
                    print("Cannot copy file: \(error.localizedDescription)")
                }
            }
        }
        return NSDictionary(contentsOfFile: filePath)
    }
    func loadArrayFromResource(file : String, type : String) -> NSArray? {
        // getting path to GroceryList.plist
        let fileName = file + "." + type
        let filePath = DataHelper.sharedInstance.fileInDocumentsDirectory(fileName)
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        
        if(!fileManager.fileExistsAtPath(filePath)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource(file, ofType: type) {
                do {
                    try fileManager.copyItemAtPath(bundlePath, toPath: filePath)
                }catch let error as NSError {
                    print("Cannot copy file: \(error.localizedDescription)")
                }
            }
        }
        return NSArray(contentsOfFile: filePath)
    }

    
    
    func loadDictionaryFromFile(fileName : String) -> NSDictionary? {
        // getting path to CheckList.plist
        let filePath = DataHelper.sharedInstance.fileInDocumentsDirectory(fileName)
        let fileManager = NSFileManager.defaultManager()
        
        //check if file exists
        if(!fileManager.fileExistsAtPath(filePath)) {
            //create new
            fileManager.createFileAtPath(filePath, contents: nil, attributes: [:])
            if fileName == "FoodPlanDate.plist"{
                let foodPlanForWeek = [String:[String:[String]]]()
                saveDictionaryToFile(foodPlanForWeek as NSDictionary, fileName: "FoodPlanDate.plist")
            }
        }
        return NSDictionary(contentsOfFile: filePath)

    }
    func saveDictionaryToFile(saveDict : NSDictionary, fileName : String){
        // getting path to file
        let filePath = DataHelper.sharedInstance.fileInDocumentsDirectory(fileName)
        let fileManager = NSFileManager.defaultManager()
        if(fileManager.fileExistsAtPath(filePath)) {
            //writing to file
            saveDict.writeToFile(filePath, atomically: false)
            
        }

    }
    func saveArrayToFile(saveDict : NSArray, fileName : String){
        // getting path to file
        let filePath = DataHelper.sharedInstance.fileInDocumentsDirectory(fileName)
        let fileManager = NSFileManager.defaultManager()
        
        if(fileManager.fileExistsAtPath(filePath)) {
            //writing to file
            saveDict.writeToFile(filePath, atomically: false)
            
        }
        
    }

}