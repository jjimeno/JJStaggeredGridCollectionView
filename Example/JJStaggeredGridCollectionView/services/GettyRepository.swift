//
//  GettyRepository.swift
//  JJLStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 23/2/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import RxOptional
import Moya_ObjectMapper

enum GettyRepositoryError : Swift.Error {
    case parseError
}

public protocol GettyRepository
{
    mutating func searchImages(search : String, pageSize:Int ,numPage : Int) -> Observable<[ImgModel]>
}

struct GettyRepositoryMoyaImp : GettyRepository
{

    let key : String
    let provider : RxMoyaProvider<GettyImagesServices>
    var imageSearch : Observable<[ImgModel]>?
    let endpointClosure:(_:GettyImagesServices) -> (Endpoint<GettyImagesServices>)
    
    init(key:String){
        self.key = key
        self.endpointClosure = { (target: GettyImagesServices) -> Endpoint<GettyImagesServices> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Api-Key": key])
        }
        self.provider  = RxMoyaProvider<GettyImagesServices>(endpointClosure:self.endpointClosure
//                                                             ,plugins:[NetworkLoggerPlugin()]
        )
    }
    
    func searchImages(search: String, pageSize: Int = 50, numPage: Int = 1) -> Observable<[ImgModel]> {
        let innerProvider = provider
        return Observable.create({ observer in
            innerProvider
                .request(GettyImagesServices.searchImages(search: search, pageSize: pageSize, numPage: numPage))
//                .debug()
                .mapObject(GettyRepoImagesResponse.self)
                .subscribe ({ event in
                    switch event{
                    case let .next(response):
                        if let imgs = response.images {
                            observer.onNext(imgs)
                        }
                         else {
                            observer.onNext([])
                        }
                    case let .error(error):
                        observer.onError(error)
                    case .completed:
                        observer.onCompleted()
                    }
                    
                })
        })
        .observeOn(MainScheduler.instance);
    }
}

public class GettyRepositoryFactory
{
    public static func provideRepository(key:String) -> GettyRepository
    {
        return GettyRepositoryMoyaImp(key:key)
    }
}
