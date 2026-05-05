import UIKit
import Kingfisher

// MARK: - ImagesListCell

protocol ImagesListCellDelegate: AnyObject {

    func imageListCellDidTapLike(_ cell: ImagesListCell)

}


final class ImagesListCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    
    // MARK: - Private Properties
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked
            ? UIImage(named: "like_button_on")
            : UIImage(named: "like_button_off")
        
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setupGradient() {
        let topColor = UIColor(
            hue: 233.0/360.0,
            saturation: 0.24,
            brightness: 0.13,
            alpha: 0.0
        )
        let bottomColor = UIColor(
            hue: 233.0/360.0,
            saturation: 0.24,
            brightness: 0.13,
            alpha: 1.0
        )
        
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.opacity    = 0.2
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
