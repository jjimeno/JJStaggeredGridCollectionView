//
//  ViewController.swift
//  JJLStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 16/1/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import JJStaggeredGridCollectionView

open class ViewController: UIViewController {
    
    @IBOutlet open var collectionView:UICollectionView!
    @IBOutlet open var tfSearchImg: UITextField!;
    @IBOutlet open var btnConfig:UIButton!
    var model:[ImgModel]?
    let disposeBag = DisposeBag()
    private let throttleInterval = 0.1
    var repo = GettyRepositoryFactory.provideRepository(key: Type your Getty Api Key here)
    var curPage = 1
    var config : JJStaggeredConfiguration = JJStaggeredConfiguration()
    var configVC : ConfigurationViewController?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.configureRX()
        
        self.collectionView.delegate = self.provideCollectionViewDelegate()
        self.collectionView.dataSource = self.provideCollectionViewDataSource()
    }
    
    
    private func configureRX(){
        tfSearchImg
            .rx
            .text
            .skip(1)
            .distinctUntilChanged { $0 == $1 }
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe ({ event in
                switch event
                {
                case let .next(result):
                    if let result = result {
                        self.curPage = 1
                        self.loadImagesWithText(text: result, page: self.curPage)
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        config.numColumns
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe ({ event in
                switch event
                {
                case let .next(value):
                    (self.collectionView.collectionViewLayout as! JJStaggeredGridCollectionViewLayout).numColumns = value
                    self.collectionView.reloadData()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        config.itemSpacing
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe({event in
                switch event
                {
                case let .next(value):
                    (self.collectionView.collectionViewLayout as! JJStaggeredGridCollectionViewLayout).minimumInteritemSpacing = CGFloat(value)
                    self.collectionView.reloadData()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        config.lineSpacing
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe({event in
                switch event
                {
                case let .next(value):
                    (self.collectionView.collectionViewLayout as! JJStaggeredGridCollectionViewLayout).minimumLineSpacing = CGFloat(value)
                    self.collectionView.reloadData()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        config.sectionInset
            .asObservable()
            .subscribe({event in
                switch event
                {
                case let .next(value):
                    (self.collectionView.collectionViewLayout as! JJStaggeredGridCollectionViewLayout).sectionInset = value
                    self.collectionView.reloadData()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        config.positionType
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe({event in
                switch event
                {
                case let .next(value):
                    (self.collectionView.collectionViewLayout as! JJStaggeredGridCollectionViewLayout).cellPositionType = value
                    self.collectionView.reloadData()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        self.btnConfig
            .rx
            .tap
            .subscribe({event in
                switch event{
                case .next(_):
                    self.configVC = ConfigurationViewController.showFromViewController(viewController: self, config:self.config)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController
{
    fileprivate func loadImagesWithText(text:String, page:Int){
        self.repo
            .searchImages(search: text, pageSize: 50, numPage: page)
            .subscribe({event in
                switch event
                {
                case let .next(list):
                    self.model = list
                    self.collectionView.reloadData()
                default:
                    //do nothing
                    break
                }
            }).disposed(by: disposeBag)
    }
    
    
}

//MARK: CollectionViewDelegate
extension ViewController : UICollectionViewDelegateFlowLayout
{
    public func provideCollectionViewDelegate()-> UICollectionViewDelegateFlowLayout
    {
        return self
    }
    
    public func modelAtIndexPath(indexPath:IndexPath) -> ImgModel?
    {
       return self.model![indexPath.row]
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let theLayout = collectionViewLayout as! JJStaggeredGridCollectionViewLayout
        let numCols = theLayout.numColumns
        
        var inset = theLayout.sectionInset.left + theLayout.sectionInset.right
        var w = ((collectionView.bounds.size.width - inset ) / CGFloat(numCols)) - theLayout.minimumInteritemSpacing;
        var h = w/2
        if ( theLayout.scrollDirection == .horizontal){
            inset = theLayout.sectionInset.top + theLayout.sectionInset.bottom
            h = ((collectionView.bounds.size.height - inset ) / CGFloat(numCols)) - theLayout.minimumInteritemSpacing;
            w = h/2
        }
        
        if let img = self.modelAtIndexPath(indexPath: indexPath) {
            if ( theLayout.scrollDirection == .vertical){
                h = w * CGFloat(img.dimens!.h!) / CGFloat(img.dimens!.w!)
            }else
            {
                w = h * CGFloat(img.dimens!.w!) / CGFloat(img.dimens!.h!)
            }
        }
        
        return CGSize(width: w, height: h)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return config.sectionInset.value
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let theLayout = collectionViewLayout as! JJStaggeredGridCollectionViewLayout
        if ( theLayout.scrollDirection == .vertical){
            return CGSize(width: collectionView.bounds.size.width, height: 60)
        }else{
            return CGSize(width: 60, height: collectionView.bounds.size.height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let theLayout = collectionViewLayout as! JJStaggeredGridCollectionViewLayout
        if ( theLayout.scrollDirection == .vertical){
            return CGSize(width: collectionView.bounds.size.width, height: 60)
        }else{
            return CGSize(width: 60, height: collectionView.bounds.size.height)
        }
    }
    
}

//MARK: CollectionViewDataSource
extension ViewController : UICollectionViewDataSource
{
    public func provideCollectionViewDataSource()-> UICollectionViewDataSource
    {
        return self
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let model = model{
            return model.count
        }
        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing:DefaultImageCollectionViewCell.self)
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DefaultImageCollectionViewCell
        
        if let img = self.modelAtIndexPath(indexPath: indexPath)
        {
            if let imgUri = img.sizes?.first?.uri{
                cell.imgView.kf.setImage(with:URL(string: imgUri))
            }
            cell.lblTitle.text = img.name
        }else{
            cell.imgView.image = nil
            cell.lblTitle.text = "no image"
        }
        
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = kind == UICollectionElementKindSectionHeader  ? String(describing: HeaderFooterCollectionReusableView.self) : "HeaderFooterCollectionReusableViewFooter"
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        if let cellHeaderFooter = cell as? HeaderFooterCollectionReusableView
        {
            let text = kind == UICollectionElementKindSectionHeader ? "This is the header" : "This is the footer"
            cellHeaderFooter.drawWithText(text:text)
        }
        return cell
    }
}

