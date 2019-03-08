import Foundation
import UIKit

class ServiceItem {
    var title: String
    var image: UIImage?
    var selectedImage: UIImage?
    var isSelected: Bool
    var attribute: Attribute?
    var service: Service?
    var isRectangle: Bool?

    init(title: String, image: UIImage? = nil, selectedImage: UIImage? = nil, isSelected: Bool = false, attribute: Attribute? = nil, service: Service? = nil, isRectangle: Bool? = nil) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.isSelected = isSelected
        self.attribute = attribute
        self.service = service
        self.isRectangle = isRectangle
    }

}
