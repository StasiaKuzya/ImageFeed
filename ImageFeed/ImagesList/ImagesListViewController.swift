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
        // Do any additional setup after loading the view.
        
        tableView.backgroundColor = UIColor.ypBlack
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListService.fetchPhotosNextPage()
        
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
//        updateTableViewAnimated()
  
//        print("Photos2 \(imagesListService.photos.count)")
//        print("Last loaded page \(String(describing: imagesListService.lastLoadedPage))")

    }
    
    // MARK: - Override Methods
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == ShowSingleImageSegueIdentifier {
//            let viewController = segue.destination as! SingleImageViewController
//            let indexPath = sender as! IndexPath
//            let image = UIImage(named: photosName[indexPath.row])
//            viewController.image = image
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == ShowSingleImageSegueIdentifier {
//            let viewController = segue.destination as! SingleImageViewController
//            let indexPath = sender as! IndexPath
//            let photo = photos[indexPath.row]
//            viewController.image = UIImage(named: photo.thumbImageURL)
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }

    // MARK: - Methods

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = "\(indexPath.row)"
        
//        if let image = UIImage(named: imageName) {
//            cell.pictureImageView.image = image
//        } else { return }
        
        let currentDate = Date()
        let dataString = dateFormatter.string( from: currentDate)
        cell.dateLabel.text = dataString
        
        let index = indexPath.row
        let isEvenIndex = index % 2 == 0
        if isEvenIndex {
            cell.likeButton.setImage(UIImage(named: "Active"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "No Active"), for: .normal)
        }
    }
}

    // MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
        print("tableView count \(photos.count)")
        print("tableView count1 \(photos)")
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]

        print("print \(photos[indexPath.row])")
        imageListCell.pictureImageView.kf.indicatorType = .activity
        imageListCell.pictureImageView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "place_holder"),
            options: nil,
            completionHandler: { result in
                switch result {
                case .success(_):
                    // Здесь можно выполнить дополнительные действия после успешной загрузки изображения
                    print("download \(photo.thumbImageURL), \(photo.createdAt), \(photo.isLiked)")
//                    tableView.reloadRows(at: [indexPath], with: .automatic)

                case .failure(let error):
                    // Обработка ошибки загрузки изображения
                    print("Error loading image for indexPath: \(indexPath), error: \(error)")
                }
            }
//                        completionHandler: { result in
//                            switch result {
//                            case .success(_):
//                                DispatchQueue.main.async {
//                                    print("download \(photo.thumbImageURL)")
//                                    tableView.reloadRows(at: [indexPath], with: .automatic)
//                                    }
//
//                            case .failure(_):
//                                print("Error loading image for indexPath: \(indexPath)")
//                            }
//                        }
        )
        
        print("download1 \(photo.thumbImageURL)")
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
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
}
