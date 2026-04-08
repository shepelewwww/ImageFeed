import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
    }
    
    // MARK: - Setup
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    // MARK: - Appearance
    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "YP Black")
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
