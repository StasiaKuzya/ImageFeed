//
//  ViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 06.10.2023.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var photos: [Photo] { get set }
    func updateCell(at indexPath: IndexPath)
    func showLikeErrorAlert()
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {

    // MARK: - IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
//    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    var imagesListService: ImagesListServiceProtocol = ImagesListService.shared
    var photos: [Photo] = []
    private var imagelistServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    var presenter: ImagesListPresenterProtocol?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        presenter = ImagesListPresenter(view: self, imagesListService: imagesListService)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.ypBlack
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.fetchPhotos()
        presenter?.notifImagelistServiceObserver()
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
//        print("photo count \(photos.count)")
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]

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

        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
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
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            guard !imagesListService.isFetching else { return }
            DispatchQueue.main.async {
                self.presenter?.fetchPhotos()
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
                self.presenter?.fetchPhotos()
            }
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate{
    
    func updateCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        presenter?.handleLikeButtonTap(for: photo, at: indexPath)
    }
    
    func showLikeErrorAlert() {
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
