//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Анастасия on 22.12.2023.
//

import Foundation
import XCTest
@testable import ImageFeed

class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] = []
    var updateTableViewAnimatedCalled = false
    var updateCellCalled = false
    
    func updateCell(at indexPath: IndexPath) {
        updateCellCalled = true
    }
    
    func showLikeErrorAlert() {
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}
