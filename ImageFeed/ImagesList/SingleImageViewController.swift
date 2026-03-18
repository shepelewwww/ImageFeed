//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Артем Шепелев on 6.03.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Private
    private var isInitialLayoutDone = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            if !isInitialLayoutDone {
                guard let image = imageView.image else { return }
                rescaleAndCenterImageInScrollView(image: image)
                isInitialLayoutDone = true
            }
        }
        
    // MARK: - Actions
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
    
    // MARK: - Image Scaling
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        
        let scale = scrollViewSize.width / imageSize.width
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        imageView.frame = CGRect(
            origin: .zero,
            size: CGSize(width: scaledWidth, height: scaledHeight)
        )
                
        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = 1.25
        scrollView.zoomScale = scale
        
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let verticalInset = max((scrollViewSize.height - imageViewSize.height) / 2, 0)
        let horizontalInset = max((scrollViewSize.width - imageViewSize.width) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
