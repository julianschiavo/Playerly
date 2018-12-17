//
//  Video.swift
//  Playerly
//
//  Created by Julian Schiavo on 14/12/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit

class Video: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

