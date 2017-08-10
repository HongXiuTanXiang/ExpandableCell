//
//  ExpandableTableView.swift
//  ExpandableCell
//
//  Created by YiSeungyoun on 2017. 8. 6..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit

open class ExpandableTableView: UITableView {
    public var expandableStyle: ExpandableStyle = .openAndClose
    public var animation: UITableViewRowAnimation = .top
    
    fileprivate var expandableProcessor = ExpandableProcessor()
    fileprivate var formerIndexPath: IndexPath?

    public var expandableDelegate: ExpandableDelegate? {
        didSet {
            self.dataSource = self
            self.delegate = self
        }
    }
}

//MARK: Required methods
extension ExpandableTableView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let delegate = expandableDelegate else { return 0 }
        return delegate.numberOfSections(in: self)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let delegate = expandableDelegate else { return }
        delegate.expandableTableView(self, didSelectRowAt: indexPath)

        guard !expandableProcessor.isExpandedCell(at: indexPath) else { return }
        
        if expandableStyle == .normal {
            if expandableProcessor.isExpandable(at: indexPath) {
                open(indexPath: indexPath, delegate: delegate)
            } else {
                close(indexPath: indexPath)
            }
        } else if expandableStyle == .openAndClose {
            if expandableProcessor.isExpandable(at: indexPath) {
                let openIndexPath = expandableProcessor.correct(indexPath: indexPath)
                if let _formerIndexPath = formerIndexPath {
                    close(indexPath: _formerIndexPath)
                }
                print(openIndexPath)
                open(indexPath: openIndexPath, delegate: delegate)
                formerIndexPath = openIndexPath
            } else {
                close(indexPath: indexPath)
                formerIndexPath = nil
            }
        }
    }
    
    private func open(indexPath: IndexPath, delegate: ExpandableDelegate) {
        let originalIndexPath = expandableProcessor.original(indexPath: indexPath)
        guard let expandedCells = delegate.expandableTableView(self, expandedCellsForRowAt: originalIndexPath) else { return }
        guard let expandedHeights = delegate.expandableTableView(self, heightsForExpandedRowAt: originalIndexPath) else { return }
        
        expandableProcessor.insert(indexPath: indexPath, expandedCells: expandedCells, expandedHeights: expandedHeights)
        self.insertRows(at: expandableProcessor.indexPathsWhere(indexPath: indexPath), with: animation)
        
        guard let cell = self.cellForRow(at: indexPath) as? ExpandableCell else { return }
        cell.open()
    }
    
    private func close(indexPath: IndexPath) {
        expandableProcessor.delete(indexPath: indexPath)
        guard let indexPaths = expandableProcessor.willRemovedIndexPaths else { return }
        self.deleteRows(at: indexPaths, with: animation)
        
        guard let cell = self.cellForRow(at: indexPath) as? ExpandableCell else { return }
        cell.close()

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let delegate = expandableDelegate else { return 0 }
        return delegate.expandableTableView(self, numberOfRowsInSection: section) + expandableProcessor.numberOfExpandedRowsInSection(section: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = expandableDelegate else { return UITableViewCell() }
        let originalIndexPath = expandableProcessor.original(indexPath: indexPath)

        if let cell = expandableProcessor.expandedCell(at: indexPath) {
            return cell
        } else {
            let cell = delegate.expandableTableView(self, cellForRowAt: originalIndexPath)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let delegate = expandableDelegate else { return 44 }
        let originalIndexPath = expandableProcessor.original(indexPath: indexPath)

        if let height = expandableProcessor.expandedHeight(at: indexPath) {
            return height
        } else {
            let height = delegate.expandableTableView(self, heightForRowAt: originalIndexPath)
            return height
        }
    }
}

//MARK: Optional methods
extension ExpandableTableView {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let delegate = expandableDelegate else { return nil }
        return delegate.expandableTableView(self, titleForHeaderInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let delegate = expandableDelegate else { return 0 }
        return delegate.expandableTableView(self, heightForHeaderInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let delegate = expandableDelegate else { return nil }
        return delegate.expandableTableView(self, viewForHeaderInSection: section)
    }
}
