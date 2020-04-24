//
// Created by Nickolay Sheika on 5/20/16.
// Copyright (c) 2016 Alterplay. All rights reserved.
//

import Foundation
import ObjectiveC

final class Box<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}

private func box<T>(x: T) -> Box<T> {
    return Box(x)
}

func setAssociatedObject<T>(object: AnyObject, value: T, associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
    if let v: AnyObject = value as? AnyObject {
        objc_setAssociatedObject(object, associativeKey, v, policy)
    } else {
        objc_setAssociatedObject(object, associativeKey, box(x: value), policy)
    }
}

func getAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
    if let v = objc_getAssociatedObject(object, associativeKey) as? T {
        return v
    } else if let v = objc_getAssociatedObject(object, associativeKey) as? Box<T> {
        return v.value
    } else {
        return nil
    }
}
