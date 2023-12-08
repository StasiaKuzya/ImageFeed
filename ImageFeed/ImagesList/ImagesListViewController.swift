//
//  ViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 06.10.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
//    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagelistServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.ypBlack
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListService.fetchPhotosNextPage()
        notifImagelistServiceObserver()
    }
    
    // MARK: - Override Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = photos[indexPath.row]
            let imageURL = URL(string: photo.largeImageURL)
            viewController.imageURL = imageURL
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

    // MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]

//        print("print \(photos[indexPath.row])")
        imageListCell.pictureImageView.kf.indicatorType = .activity
        imageListCell.pictureImageView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "place_holder"),
            options: nil,
            completionHandler: { result in
                switch result {
                case .success(_):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                case .failure(let error):
                    print("Error loading image for indexPath: \(indexPath), error: \(error)")
                }
            }
        )
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        cell.delegate = self
        
        let photo = photos[indexPath.row]
        
        let likeStateImageName = photo.isLiked ? "Active" : "No Active"
        cell.likeButton.setImage(UIImage(named: likeStateImageName), for: .normal)
        
        let dateString = photo.createdAt
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = inputFormatter.date(from: dateString) {
            let resultString = dateFormatter.string(from: date)
            cell.dateLabel.text = resultString
        } else {
            cell.dateLabel.text = photo.createdAt
        }
    }
}

    // MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else {
            return 0
        }
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - ImagesListService - fetchPhotosNextPage

extension ImagesListViewController {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        //TODO

        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            guard !imagesListService.isFetching else { return }
            DispatchQueue.main.async {
                self.imagesListService.fetchPhotosNextPage()
                print("load next 10")
            }
        }
    }

    func updateTableViewAnimated() {
        DispatchQueue.main.async {
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            self.photos = self.imagesListService.photos

            print("Old count: \(oldCount), New count: \(newCount)")

            if oldCount < newCount {
                self.tableView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                }
            }
            else {
                self.imagesListService.fetchPhotosNextPage()
            }
        }
    }
    
    private func notifImagelistServiceObserver() {
        imagelistServiceObserver =
        NotificationCenter.default
            .addObserver(
                forName: ImagesListService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                print("Received DidChangeNotification")
                print("Photos1 \(imagesListService.photos.count)")
                self.updateTableViewAnimated()
            }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        // Покажем лоадер
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                    // Синхронизируем массив картинок с сервисом
                    self.photos = self.imagesListService.photos
                    // Изменим индикацию лайка картинки
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    print("tap done \(self.photos[indexPath.row].isLiked)")
                    UIBlockingProgressHUD.dismiss()
            case .failure:
                    self.showLikeErrorAlert()
                    UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func showLikeErrorAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так",
            message: "Не удалось поставить лайк",
            primaryButton: AlertButton(
                buttonText: "ОК",
                completion: nil
            ),
            additionalButtons: nil
        )
        
        AlertPresenter.showAlert(alertModel: alertModel, delegate: self)
    }
}
