//
//  imageModel.swift
//  BLEMultiConnectSample
//
//  Created by TomoyukiKoyanagi on 2019/08/10.
//  Copyright © 2019 hiro. All rights reserved.
//

import Foundation
import UIKit

struct Model {
    let name : String
    let image1 : UIImage
    let image2 : UIImage

}

//ここにバシバシ例を追加する
let test = Model(name: "test", image1:#imageLiteral(resourceName: "apple1"), image2:#imageLiteral(resourceName: "apple2"))
let apple = Model(name:"apple", image1:#imageLiteral(resourceName: "apple1") , image2:#imageLiteral(resourceName: "apple2"))
let tomato = Model(name:"tomato", image1:#imageLiteral(resourceName: "tomato1") , image2:#imageLiteral(resourceName: "tomato2"))
let milk = Model(name:"milk", image1:#imageLiteral(resourceName: "milk1") , image2:#imageLiteral(resourceName: "milk2"))
let egg = Model(name:"egg", image1:#imageLiteral(resourceName: "egg1") , image2:#imageLiteral(resourceName: "egg2"))
let lettuce = Model(name:"lettuce", image1:#imageLiteral(resourceName: "lettuce1") , image2:#imageLiteral(resourceName: "lettuce2"))


func getModel(str: String) ->Model{
    if str == "Apple" {
        return apple
    }
    else if str == "Tomato" {
        return tomato
    }
    else if str == "Milk" {
        return milk
    }
    else if str == "Egg" {
        return egg
    }
    else if str == "Lettuce" {
        return lettuce
    }
    else {
        return test
    }
}
