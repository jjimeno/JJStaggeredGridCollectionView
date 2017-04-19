//
//  ConfigurationViewController.swift
//  JJLStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 3/4/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JJStaggeredGridCollectionView

public struct JJStaggeredConfiguration
{
    public var numColumns: Variable<Int>
    public var itemSpacing : Variable<Int>
    public var lineSpacing: Variable<Int>
    public var sectionInset: Variable<UIEdgeInsets>
    public var positionType: Variable<JJStaggeredGridCellPositionArrangeType>
    
    init() {
        self.numColumns = Variable(Int(3))
        self.itemSpacing = Variable(Int(0))
        self.lineSpacing = Variable(Int(0))
        self.sectionInset = Variable(UIEdgeInsetsMake(0, 0, 0, 0))
        self.positionType = Variable(JJStaggeredGridCellPositionArrangeType.Default)
    }
}

public class ConfigurationViewController: UIViewController {
    
    fileprivate var config : JJStaggeredConfiguration = JJStaggeredConfiguration()
    let disposeBag = DisposeBag()
    
    @IBOutlet public var txtNumColumns: UITextField!
    @IBOutlet public var txtItemSpacing : UITextField!
    @IBOutlet public var txtLineSpacing : UITextField!
    @IBOutlet public var txtSectionInsetTop : UITextField!
    @IBOutlet public var txtSectionInsetLeft : UITextField!
    @IBOutlet public var txtSectionInsetBottom : UITextField!
    @IBOutlet public var txtSectionInsetRight : UITextField!
    @IBOutlet public var txtPositionType : UITextField!
    @IBOutlet public var btnBack:UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.txtNumColumns.text = String(self.config.numColumns.value)
        self.txtItemSpacing.text = String(self.config.itemSpacing.value)
        self.txtLineSpacing.text = String(self.config.lineSpacing.value)
        self.txtSectionInsetTop.text = String(Int(self.config.sectionInset.value.top))
        self.txtSectionInsetLeft.text = String(Int(self.config.sectionInset.value.left))
        self.txtSectionInsetBottom.text = String(Int(self.config.sectionInset.value.bottom))
        self.txtSectionInsetRight.text = String(Int(self.config.sectionInset.value.right))
        self.txtPositionType.text = String(Int(self.config.positionType.value.rawValue))
        self.configureRX()
    }
    
    private func configureRX()
    {
        self.txtNumColumns
            .rx
            .text
            .distinctUntilChanged {$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false}
                return value > 0 && value < 5 && self.config.numColumns.value != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( { event in
            switch event
            {
            case .next(let number):
                self.config.numColumns.value = number
                break
            default:
                break
            }
        })
        .disposed(by: self.disposeBag)
        
        self.txtItemSpacing
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                    guard let value = Int(txt!) else { return false }
                    return value > 0 && value < 31 && self.config.itemSpacing.value != value
            }.map { txt -> Int in
                    return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    self.config.itemSpacing.value = number
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        self.txtLineSpacing
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false }
                return value > 0 && value < 21 && self.config.lineSpacing.value != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    self.config.lineSpacing.value = number
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        self.txtSectionInsetTop
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false }
                return Int(self.config.sectionInset.value.top) != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    self.config.sectionInset.value.top = CGFloat(number)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        self.txtSectionInsetLeft
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false }
                return Int(self.config.sectionInset.value.left) != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    self.config.sectionInset.value.left = CGFloat(number)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        self.txtSectionInsetBottom
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false }
                return Int(self.config.sectionInset.value.bottom) != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    self.config.sectionInset.value.bottom = CGFloat(number)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        self.txtSectionInsetRight
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false }
                return Int(self.config.sectionInset.value.right) != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    self.config.sectionInset.value.right = CGFloat(number)
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        self.txtPositionType
            .rx
            .text
            .distinctUntilChanged{$0 == $1}
            .filter { txt -> Bool in
                guard let value = Int(txt!) else { return false }
                return value >= 0 && value < 2 && self.config.positionType.value.rawValue != value
            }.map { txt -> Int in
                return Int(txt!)!
            }.subscribe( {event in
                switch event{
                case .next(let number):
                    switch number{
                    case 1:
                        self.config.positionType.value = JJStaggeredGridCellPositionArrangeType.Smallest
                    default:
                        self.config.positionType.value = JJStaggeredGridCellPositionArrangeType.Default
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)

        
        self.btnBack
            .rx
            .tap
            .subscribe({event in
                switch event
                {
                case .next(_):
                    self.dismiss(animated: true, completion: nil)
                default:break
                }
            })
        .addDisposableTo(disposeBag)
        
    }
}

extension ConfigurationViewController :UIViewControllerTransitioningDelegate {
    public static func showFromViewController(viewController:UIViewController,config:JJStaggeredConfiguration) -> ConfigurationViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ConfigurationViewController") as! ConfigurationViewController
        controller.config = config
        if let navController = viewController.navigationController{
            navController.pushViewController(controller, animated: true)
        }else{
            controller.modalPresentationStyle = UIModalPresentationStyle.custom
            controller.transitioningDelegate = controller
            viewController.present(controller, animated: true, completion: nil)
        }
        return controller;
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presentingViewController)
    }
}

class HalfSizePresentationController : UIPresentationController {
    override open var frameOfPresentedViewInContainerView: CGRect { get {
            return CGRect(x: 0, y: self.containerView!.bounds.height/2, width: self.containerView!.bounds.width, height: self.containerView!.bounds.height/2)
        }
    }
}
