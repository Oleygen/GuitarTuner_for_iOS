//
//  Sample.swift
//  GuitarTuner
//
//  Created by oleygen ua on 1/10/19.
//  Copyright © 2019 Gennady Oleynik. All rights reserved.
//

import Foundation

struct Sample: CustomStringConvertible
{
    let value: Int16
    
    var description: String
    {
        return "\(value)"
    }
}
