//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 21.10.2023.
//

import Foundation
import UIKit

class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
//    var image: UIImage! {
//        didSet {
//            guard isViewLoaded else { return }
//            imageView.image = image
//            rescaleAndCenterImageInScrollView(image: image)
//        }
//    }
    
    var imageURL: URL!
    
    // MARK: - IBOutlet
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadImage()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
    }
    
    // MARK: - Private Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func loadImage() {
        UIBlockingProgressHUD.show()
        guard let imageURL = imageURL else { return }
        imageView.kf.setImage(
            with: imageURL
            ) { [weak self] result in
            switch result {
            case .success(let value):
                self?.rescaleAndCenterImageInScrollView(image: value.image)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("Error loading image: \(error)")
                UIBlockingProgressHUD.dismiss()
                self?.showFailDownloadFullImageAlert()
            }
        }
    }
    
    private func showFailDownloadFullImageAlert() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так",
            message: "Не удалось загрузить фотографию",
            primaryButton: AlertButton(
                buttonText: "Повторить",
                completion: {self.loadImage()}
            ),
            additionalButtons: [AlertButton(
                buttonText: "Не надо",
                completion: nil
            )]
        )
        
        AlertPresenter.showAlert(alertModel: alertModel, delegate: self)
    }

    // MARK: - IBAction
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
}

    // MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
