//
//  PaymentCard.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation


enum PaymentCardType: String {
    
    static let DEFAULT_NUMBER_PATTERN = [4,4,4,4]
    static let DEFAULT_NUMBER_LENGTH = 16
    static let DEFAULT_CVC_LENGTH = 3
    static let DEFAULT_LABEL_PATTERN = "**** "
    
    case None
    case VISA
    case MASTER_CARD
    case AMERICAN_EXPRESS
    case UNION_PAY
    case MAESTRO
    case DINERS
    case DISCOVER
    case JCB
    
    var cvcLength: Int {
        switch self {
        case .AMERICAN_EXPRESS:
            return 4
        default:
            return PaymentCardType.DEFAULT_CVC_LENGTH
        }
    }
    
    var numberLength: Int {
        switch self {
        case .AMERICAN_EXPRESS:
            return 15
        default:
            return PaymentCardType.DEFAULT_NUMBER_LENGTH
        }
    }
    
    var numberPattern: [Int] {
        switch self {
        case .AMERICAN_EXPRESS:
            return [4,6,5]
        default:
            return PaymentCardType.DEFAULT_NUMBER_PATTERN
        }
    }
    
    var labelPattern: String {
        switch self {
        case .AMERICAN_EXPRESS:
            return "****** *"
        default:
            return PaymentCardType.DEFAULT_LABEL_PATTERN
        }
    }
    
    var regex: String {
        switch self {
        case .VISA:
            return "^4[0-9]{6,}$"
        case .MASTER_CARD:
            return "^5[1-5][0-9]{5,}$"
        case .AMERICAN_EXPRESS:
            return "^3[47][0-9]{5,}$"
        case .UNION_PAY:
            return "^(62|88)\\d+$"
        case .MAESTRO:
            return "^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\\d+$"
        case .DINERS:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
        case .DISCOVER:
            return "^6(?:011|5[0-9]{2})[0-9]{12}$"
        case .JCB:
            return "^(?:2131|1800|35\\d{3})\\d{11}$"
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        var imageName = ""
        switch self {
        case .VISA:
            imageName = "ic_visa"
        case .MASTER_CARD:
            imageName = "ic_master_card"
        case .AMERICAN_EXPRESS:
            imageName = "ic_american_express"
        case .UNION_PAY:
            imageName = "ic_union_pay"
        case .MAESTRO:
            imageName = "ic_maestro"
        case .DINERS:
            imageName = "ic_diners"
        case .DISCOVER:
            imageName = "ic_discover"
        case .JCB:
            imageName = "ic_jcb"
        default:
            imageName = ""
        }
        return UIImage(named: imageName)
    }
    
    var darkImage: UIImage? {
        var imageName = ""
        switch self {
        case .VISA:
            imageName = "ic_visa_dark"
        case .MASTER_CARD:
            imageName = "ic_master_card_dark"
        case .AMERICAN_EXPRESS:
            imageName = "ic_american_express_dark"
        case .UNION_PAY:
            imageName = "ic_union_pay_dark"
        case .MAESTRO:
            imageName = "ic_maestro_dark"
        case .DINERS:
            imageName = "ic_diners_dark"
        case .DISCOVER:
            imageName = "ic_discover_dark"
        case .JCB:
            imageName = "ic_jcb_dark"
        default:
            imageName = ""
        }
        return UIImage(named: imageName)
    }
    
    static let allValues = [VISA, MASTER_CARD, AMERICAN_EXPRESS, UNION_PAY, MAESTRO, DINERS, DISCOVER, JCB]
}

final class PaymentCard: Copying, Equatable {
    
    fileprivate var _type: PaymentCardType? = nil
    
    var id: Int?
    var label: String {
        if number.count >= 4 {
            return type.labelPattern + number.substring(from: number.index(number.endIndex, offsetBy: -4))
        } else {
            return ""
        }
    }
    var type: PaymentCardType {
        for type in PaymentCardType.allValues {
            if let type = _type {
                return type
            }
            let test = NSPredicate(format:"SELF MATCHES %@", type.regex)
            if test.evaluate(with: number) {
                return type
            }
        }
        return .None
    }
    var number: String
    var expiration: String
    var secCode: String
    var deleted: Bool
    var userId: Int
    var token: String?
    var billingAddress: BillingAddress?
    
    var expMonth: String {
        return expiration.splitWithPattern([2]).first ?? ""
    }
    
    var expYear: String {
        if expiration.count > 3 {
            if let yearPart = expiration.splitWithPattern([3,2]).last {
                return "20\(yearPart)"
            }
        }
        return ""
    }

    init (id: Int? = nil,
        number: String = "",
        type: String = "",
        expiration: String = "",
        secCode: String = "",
        deleted: Bool = false,
        userId: Int,
        token: String? = nil,
        billingAddress: BillingAddress? = nil) {
            self.id = id
            self.number = number
            if let type = PaymentCardType(rawValue: type) {
                _type = type
            }
            self.expiration = expiration
            self.secCode = secCode
            self.deleted = deleted
            self.userId = userId
            self.token = token
            self.billingAddress = billingAddress ?? BillingAddress()
    }
    
    convenience init(original: PaymentCard) {
        self.init(id: original.id,
            number: original.number,
            expiration: original.expiration,
            secCode: original.secCode,
            deleted: original.deleted,
            userId: original.userId,
            token: original.token,
            billingAddress: original.billingAddress)
    }
    
    init(entity: PaymentCardEntity) {
        self.id = entity.id.value
        self.number = entity.number
        self.expiration = entity.expiration
        self.secCode = entity.secCode
        self.deleted = entity.deleted
        self.userId = entity.userId
        self.token = entity.token
        
        if let billAddress = entity.billingAddress {
            self.billingAddress = BillingAddress(entity: billAddress)
        } else {
            self.billingAddress = nil
        }
        
        if let paymentType = entity.type {
            self._type = PaymentCardType(rawValue: paymentType)
        } else {
            self._type = nil
        }
    }
    
    func sync(_ paymentCard: PaymentCard) {
        self.id = paymentCard.id
        self.number = paymentCard.number
        self.expiration = paymentCard.expiration
        self.secCode = paymentCard.secCode
        self.deleted = paymentCard.deleted
        self.userId = paymentCard.userId
        self.billingAddress = paymentCard.billingAddress
    }
}


extension PaymentCard: PaymentCardProtocol {

    var image: UIImage? {
        return self.type.darkImage
    }
    
    var lightImage: UIImage? {
        return self.type.image
    }
}

func == (left: PaymentCard, right: PaymentCard) -> Bool {
    return left.id == right.id
}
