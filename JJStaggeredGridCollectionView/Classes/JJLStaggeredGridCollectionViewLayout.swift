//
//  JJStaggeredGridCollectionViewLayout.swift
//  JJStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 18/1/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import UIKit

public enum JJStaggeredGridCellPositionArrangeType : Int
{
    case Default = 0
    case SmallestVertical = 1
}
public class JJStaggeredGridCollectionViewLayout: UICollectionViewFlowLayout {
    
    fileprivate var rects:[IndexPath:NSValue] = [:]
    fileprivate var suplementaryViews:[IndexPath:[String:NSValue]] = [:]
    fileprivate var maxY:[CGFloat] = []
    
    @IBInspectable public var numColumns: Int = 2 {
        didSet {
            self.invalidateLayout()
            self.resetY()
        }
    }
    
    @IBInspectable public var cellPositionType : JJStaggeredGridCellPositionArrangeType = .Default
    {
        didSet{
            self.invalidateLayout()
            self.resetY()
        }
    }
    
    fileprivate func resetY(){
        maxY.removeAll()
        for _ in 0..<self.numColumns{
            maxY.append(0)
        }
    }

}

extension JJStaggeredGridCollectionViewLayout
{
    
    fileprivate func ensureSuplementaryCanAddValueForIndexPath( dict: inout [IndexPath:[String:NSValue]], indexPath:IndexPath){
        if dict[indexPath] == nil {
            dict[indexPath] = [:]
        }
    }
    
    fileprivate func framePosition( positionType: JJStaggeredGridCellPositionArrangeType, columnPoints:[CGPoint],  currentColumn:Int, size:CGSize) -> (pointSelected : Int, frame:CGRect )
    {
        switch positionType {
        case .Default:
            return ( currentColumn, CGRect(x: columnPoints[currentColumn].x, y: columnPoints[currentColumn].y, width: size.width, height: size.height) )
        case .SmallestVertical:
            var minIndex = 0
            var min = CGFloat.greatestFiniteMagnitude
            for a in 0..<columnPoints.count
            {
                if columnPoints[a].y < min {
                    minIndex = a
                    min = columnPoints[a].y
                }
            }
            return ( minIndex, CGRect(x: columnPoints[minIndex].x, y: columnPoints[minIndex].y, width: size.width, height: size.height ) )
            
        }
    }
    
    
    // The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
    // The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
    // Subclasses should always call super if they override.
    override open func prepare()
    {
        super.prepare()
        assert((self.collectionView?.delegate?.conforms(to: UICollectionViewDelegateFlowLayout.self))!, "collectionViewDelegate does not conform to protocol UICollectionViewDelegateFlowLayout.")
        
        if let colView = self.collectionView, let dataSource = colView.dataSource, let delegate = colView.delegate as? UICollectionViewDelegateFlowLayout {
            rects.removeAll()
            suplementaryViews.removeAll()
            self.resetY()
            
            var minY :CGFloat = 0
            var origins : [CGPoint] = [CGPoint](repeating: CGPoint(x: 0, y: minY), count: self.numColumns)
            for section in 0..<dataSource.numberOfSections!(in: colView) {
                let headerSize = delegate.collectionView?(colView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
                let interItemSpacing = delegate.collectionView?(colView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
                let sectionInsets = delegate.collectionView?(colView, layout: self, insetForSectionAt: section) ?? self.sectionInset
                let w = ceilf(Float((colView.bounds.width - sectionInsets.left - sectionInsets.right  - (CGFloat(numColumns - 1) * interItemSpacing)) / CGFloat(numColumns)))
                let lineSpacing = delegate.collectionView?(colView, layout: self, minimumLineSpacingForSectionAt: section) ?? self.minimumLineSpacing
                
                minY = maxY.max()! + sectionInsets.top
                //header
                let headerFooterIndexPath = IndexPath(row: 0, section: section)
                self.ensureSuplementaryCanAddValueForIndexPath(dict: &suplementaryViews, indexPath: headerFooterIndexPath)
                suplementaryViews[headerFooterIndexPath]?[UICollectionElementKindSectionHeader] = NSValue(cgRect:CGRect(x: 0, y: minY, width: headerSize.width, height: headerSize.height))
                minY += headerSize.height
                var xValue :CGFloat = sectionInsets.left
                for i in 0..<self.numColumns
                {
                    origins[i] = CGPoint(x: xValue, y: minY)
                    xValue += CGFloat(w) + interItemSpacing
                }
                var currentCol = 0
                for cellIndex in 0..<dataSource.collectionView(colView, numberOfItemsInSection: section){
                    let indexPath = IndexPath(row: cellIndex, section: section)
                    let size = delegate.collectionView!(colView, layout: self, sizeForItemAt: indexPath)
                    let (index, rect) = self.framePosition(positionType: self.cellPositionType, columnPoints: origins, currentColumn: currentCol, size: size)
                    
                    currentCol = index
                    origins[currentCol].y += rect.size.height + lineSpacing
                    rects[indexPath] = NSValue(cgRect: rect)
                    maxY[currentCol] = origins[currentCol].y
                    
                    currentCol = currentCol + 1
                    currentCol %= self.numColumns
                }
                //footer
                let footerSize = delegate.collectionView?(colView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
                minY = maxY.max()!
                self.ensureSuplementaryCanAddValueForIndexPath(dict: &suplementaryViews, indexPath: headerFooterIndexPath)
                suplementaryViews[headerFooterIndexPath]?[UICollectionElementKindSectionFooter] = NSValue(cgRect:CGRect(x: 0, y: minY, width: footerSize.width, height: footerSize.height))
                minY += footerSize.height + sectionInsets.bottom
                maxY[0] = minY      //to take the footer into account for the height
            }
        }
    }
    
    // UICollectionView calls these four methods to determine the layout information.
    // Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
    // Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
    // If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attrs: [UICollectionViewLayoutAttributes] =
            super.layoutAttributesForElements(in: rect)?.map({ (elem:UICollectionViewLayoutAttributes
                ) -> UICollectionViewLayoutAttributes in
                return elem.copy() as! UICollectionViewLayoutAttributes
            }) ??
            []
        
        var cellsFound:[IndexPath] = []
        var supplementariesFound:[IndexPath:[String:NSValue]] = [:]
        for attr in attrs
        {
            switch attr.representedElementCategory {
            case .cell:
                if let value = self.rects[attr.indexPath]{
                    attr.frame = value.cgRectValue
                    cellsFound.append(attr.indexPath)
                }
            case .supplementaryView:
                let indexPath = IndexPath(row: attr.indexPath.row, section: attr.indexPath.section)
                if let supViews = suplementaryViews[indexPath]{
                    if let value = supViews[attr.representedElementKind!]{
                        attr.frame = value.cgRectValue
                        self.ensureSuplementaryCanAddValueForIndexPath(dict: &supplementariesFound, indexPath: indexPath)
                        supplementariesFound[indexPath]?[attr.representedElementKind!] = value
                    }
                }
            default:
                break
            }
        }
        
        //Cells
        let rectsInside = self.rects.filter { (indexPath:IndexPath, value:NSValue) -> Bool in
            return rect.intersects(value.cgRectValue) && !cellsFound.contains(indexPath)
        }
        for case let(indexPath,_) in rectsInside
        {
            let attr = self.layoutAttributesForItem(at: indexPath)!
            attrs.append(attr)
        }
        
        //supplementary Views
        for key in self.suplementaryViews.keys{
            let values:[String:NSValue] = self.suplementaryViews[key]!
            let supFoundsValues:[String:NSValue] = supplementariesFound[key] ?? [:]
            let suplementariesInside = values.filter {(kind:String, value:NSValue) -> Bool in
                return supFoundsValues[kind] == nil && rect.intersects(value.cgRectValue)
            }
            for case let(kind,_) in suplementariesInside
            {
                let attr = self.layoutAttributesForSupplementaryView(ofKind: kind, at: key)!
                attrs.append(attr)
            }
        }
        return attrs
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        if  let rectValue = self.rects[indexPath]{
            attr?.frame = rectValue.cgRectValue
        }
        return attr
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        if let rect = suplementaryViews[indexPath]?[elementKind]?.cgRectValue {
           attr?.frame = rect
        }
        return attr
    }
    
    override open var collectionViewContentSize : CGSize {
        var contentSize = super.collectionViewContentSize
        contentSize.height = maxY.max()!
        return contentSize
    }
    
}
