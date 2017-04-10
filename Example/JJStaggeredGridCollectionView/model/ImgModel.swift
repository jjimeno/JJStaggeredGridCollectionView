//
//  ImgModel.swift
//  JJLStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 21/2/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ImgDimens : Mappable{
    var w:Int?
    var h:Int?
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        w <- map["width"]
        h <- map["height"]
    }
}

public struct ImgSize: Mappable{
    var isWatermarked:Bool?
    var name:String?
    var uri:String?
    
    public init?(map: Map){}
    
    public mutating func mapping(map: Map) {
        isWatermarked <- map["is_watermarked"]
        name <- map["name"]
        uri <- map["uri"]
    }
}

public struct ImgModel :Mappable {
    var identifier:NSString?
    var sizes:Array<ImgSize>?
    var name:String?
    var dimens:ImgDimens?
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        identifier <- map["id"]
        sizes <- map["display_sizes"]
        name <- map["title"]
        dimens <- map["max_dimensions"]
    }
}

public struct GettyRepoImagesResponse : Mappable {
    var numImgs:NSString?
    var images:[ImgModel]?
    
    public init?(map: Map){}
    
    public mutating func mapping(map: Map) {
        numImgs <- map["result_count"]
        images <- map["images"]
    }
}

