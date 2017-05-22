//
//  JJStaggeredGridCollectionViewLayout.swift
//  JJStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 18/1/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import UIKit
/// Type of position cell calculation for the staggered grid
public enum JJStaggeredGridCellPositionArrangeType : Int
{
    /// This is the default value, each cell position are calculated taking the column positions  sequentially
    case Default = 0
    // Each cell position are calculated taking the minimum Y of the current columns
    case Smallest = 1
}

/// Staggered Grid UICollectionViewFlowLayout
///
public class JJStaggeredGridCollectionViewLayout: UICollectionViewFlowLayout {
    
    fileprivate var rects:[IndexPath:NSValue] = [:]
    fileprivate var suplementaryViews:[IndexPath:[String:NSValue]] = [:]
    fileprivate var maxPos:[CGFloat] = []
    
    /// number of columns the grid has
    @IBInspectable public var numColumns: Int = 2 {
        didSet {
            self.invalidateLayout()
            self.resetMaxPos()
        }
    }
    /// cell position type to calculate cell positions
    @IBInspectable public var cellPositionType : JJStaggeredGridCellPositionArrangeType = .Default
    {
        didSet{
            self.invalidateLayout()
            self.resetMaxPos()
        }
    }
    
    fileprivate func resetMaxPos(){
        maxPos = [CGFloat](repeatElement(0, count: self.numColumns))
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
        case .Smallest:
            var minIndex = 0
            var min = CGFloat.greatestFiniteMagnitude
            for a in 0..<columnPoints.count
            {
                let colPoint = self.scrollDirection == UICollectionViewScrollDirection.vertical ? columnPoints[a].y : columnPoints[a].x
                if colPoint < min {
                    minIndex = a
                    min = colPoint
                }
            }
            return ( minIndex, CGRect(x: columnPoints[minIndex].x, y: columnPoints[minIndex].y, width: size.width, height: size.height ) )
            
        }
    }
    
    static fileprivate func calculateWidthOrHeightToAddEachCell(fullBounds:CGRect, sectionInsets: UIEdgeInsets, numRowsOrCols:Int, interItemSpacing:CGFloat, scrollDirection: UICollectionViewScrollDirection) -> CGSize
    {
        var size = CGSize(width: 0, height: 0)
        switch scrollDirection {
        case .vertical:
        let fullWidth:CGFloat = (fullBounds.size.width - sectionInsets.left - sectionInsets.right) - (CGFloat(numRowsOrCols - 1) * interItemSpacing)
            size.width = ceil(fullWidth/CGFloat(numRowsOrCols))
            break
        case .horizontal:
        let fullHeight:CGFloat = (fullBounds.size.height - sectionInsets.top - sectionInsets.bottom) - (CGFloat(numRowsOrCols - 1) * interItemSpacing)
            size.height = ceil(fullHeight / CGFloat(numRowsOrCols))
        }
        return size
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
            self.resetMaxPos()
            
            var minPos :CGPoint = CGPoint(x: 0, y: 0)
            var origins : [CGPoint] = [CGPoint](repeating: CGPoint(x: minPos.x, y: minPos.y), count: self.numColumns)
            for section in 0..<dataSource.numberOfSections!(in: colView) {
                
                let headerSize = delegate.collectionView?(colView, layout: self, referenceSizeForHeaderInSection: section) ?? self.headerReferenceSize
                let interItemSpacing = delegate.collectionView?(colView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
                let sectionInsets = delegate.collectionView?(colView, layout: self, insetForSectionAt: section) ?? self.sectionInset
                let size = JJStaggeredGridCollectionViewLayout.calculateWidthOrHeightToAddEachCell(fullBounds: colView.bounds, sectionInsets: sectionInsets, numRowsOrCols: self.numColumns, interItemSpacing: interItemSpacing, scrollDirection: self.scrollDirection)
                let lineSpacing = delegate.collectionView?(colView, layout: self, minimumLineSpacingForSectionAt: section) ?? self.minimumLineSpacing
                
                if ( self.scrollDirection == .vertical){
                    minPos.y = maxPos.max()! + sectionInsets.top
                    minPos.x = sectionInsets.left
                }else{
                    minPos.x = maxPos.max()! + sectionInsets.left;
                    minPos.y = sectionInsets.top
                }
                
                //header
                let headerFooterIndexPath = IndexPath(row: 0, section: section)
                self.ensureSuplementaryCanAddValueForIndexPath(dict: &suplementaryViews, indexPath: headerFooterIndexPath)
                suplementaryViews[headerFooterIndexPath]?[UICollectionElementKindSectionHeader] = NSValue(cgRect:CGRect(x: minPos.x, y: minPos.y, width: headerSize.width, height: headerSize.height))
                if ( self.scrollDirection == .vertical){
                    minPos.y += headerSize.height
                }else
                {
                    minPos.x += headerSize.width
                }
                
                for i in 0..<self.numColumns
                {
                    origins[i] = CGPoint(x: minPos.x, y: minPos.y)
                    if ( self.scrollDirection == .vertical){
                        minPos.x += size.width + interItemSpacing
                    }else
                    {
                        minPos.y += size.height + interItemSpacing
                    }
                }
                var currentColOrRow = 0
                for cellIndex in 0..<dataSource.collectionView(colView, numberOfItemsInSection: section){
                    let indexPath = IndexPath(row: cellIndex, section: section)
                    let size = delegate.collectionView!(colView, layout: self, sizeForItemAt: indexPath)
                    let (index, rect) = self.framePosition(positionType: self.cellPositionType, columnPoints: origins, currentColumn: currentColOrRow, size: size)
                    
                    currentColOrRow = index
                    if ( self.scrollDirection == .vertical){
                        origins[currentColOrRow].y += rect.size.height + lineSpacing
                        maxPos[currentColOrRow] = origins[currentColOrRow].y
                    }else{
                        origins[currentColOrRow].x += rect.size.width + lineSpacing
                        maxPos[currentColOrRow] = origins[currentColOrRow].x
                    }
                    rects[indexPath] = NSValue(cgRect: rect)
                    
                    currentColOrRow = currentColOrRow + 1
                    currentColOrRow %= self.numColumns
                }
                //footer
                let footerSize = delegate.collectionView?(colView, layout: self, referenceSizeForFooterInSection: section) ?? self.footerReferenceSize
                if ( self.scrollDirection == .vertical){
                    minPos.y = maxPos.max()!
                    minPos.x = 0
                }else{
                    minPos.x = maxPos.max()!
                    minPos.y = 0
                }
                self.ensureSuplementaryCanAddValueForIndexPath(dict: &suplementaryViews, indexPath: headerFooterIndexPath)
                suplementaryViews[headerFooterIndexPath]?[UICollectionElementKindSectionFooter] = NSValue(cgRect:CGRect(x: minPos.x, y: minPos.y, width: footerSize.width, height: footerSize.height))
                if ( self.scrollDirection == .vertical){
                    minPos.y += footerSize.height + sectionInsets.bottom
                    maxPos[0] = minPos.y      //to take the footer into account for the height
                }else
                {
                    minPos.x += footerSize.width + sectionInsets.right
                    maxPos[0] = minPos.x      //to take the footer into account for the width
                }
                
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
        if ( self.scrollDirection == .vertical){
            contentSize.height = maxPos.max()!
        }else{
            contentSize.width = maxPos.max()!
        }
        return contentSize
    }
    
}
