//
//  EmergencyContact+CoreDataProperties.swift
//  Final app project
//
//  Created by Beees on 9/6/2023.
//
//

import Foundation
import CoreData


extension EmergencyContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmergencyContact> {
        return NSFetchRequest<EmergencyContact>(entityName: "EmergencyContact")
    }

    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var imageData: Data?

}

extension EmergencyContact : Identifiable {

}
