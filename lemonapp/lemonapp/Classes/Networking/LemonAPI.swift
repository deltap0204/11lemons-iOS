//
//  LemonAPI.swift
//  lemonapp
//
//  Copyright © 2015 11lemons. All rights reserved.
//

import Foundation
import UIKit
import Moya
import SwiftyJSON

enum LemonAPI {
    case login(email: String, password: String)
    case signUp(firstName: String,
        lastName: String,
        email: String,
        password: String,
        mobilePhone: String,
        zipCode: String,
        referralCode: String?,
        referredById: Int?)
    
    case startSession(userId: Int, email: String, password: String)
    case restorePassword(email: String)
    case chagePassword(password: String)
    case addAddress(address: Address)
    case addPaymentCard(paymentCard: PaymentCard)
    case addOrder(order:Order)
    case cancelOrder(orderId: Int)
    case deleteAddress(address: Address)
    case deletePaymentCard(paymentCard: PaymentCard)
    case editAddress(address: Address)
    case editPaymentCard(paymentCard: PaymentCard)
    case editProfile(user: User)
    case getOrders()
    case getOrdersStatuses()
    case getAllOrders()
    case getAddresses()
    case getPaymentCards()
    case getProfileImage(imgURL: String?)
    case getOrderImage(imgURL: String?)
    case deleteOrderImage(orderId: Int, picId: Int)
    case uploadPhoto(photoFile: URL)
    case uploadPhotoNote(photoUrl: URL, forOrder: Order)
    case getProducts()
    case getDeliveryOptions()
    case addComment(text: String)
    case getFaq()
    case getPaymentToken()
    case validateZip(zip: String)
    case validatePromocode(code: String)
    case getWallet(userId: Int)
    case cloudCloset(userId: Int)
    case getServerApiVersion()
    case getOrdersUpdates(userId: Int, lastDate: Date)
    case checkEmail(email: String)
    case checkPhone(phone: String)
    case checkReferral(referralCode: String)
    case archiveWalletTransition(walletTransition: WalletTransition)
    case archiveOrder(order: Order)
    case getCloudCloset(userId: Int)
    case getCloudClosetImage(imgURL: String)
    case editOrder(editedOrder: Order)
    case getPickupETA()
    case setPickupETA(pickupETA: Int)
    case setOrderStatus(editedOrder: Order, status: OrderStatus)
    case addNote(note: Note)
    case getGarmentByBarcode(barcode: String)
    case getServices()
    case deleteService(serviceID: Int)
    case getAllServices()
    case getDepartmentsAll()
    case getDepartments()
    case createDepartment(department: Service)
    case updateDepartment(department: Service)
    case deleteDepartment(departmentID: Int)
    case updateServices(service: Service)
    case createService(service: Service)
    case getAttributeCategories()
    case getAttributeCategoriesByService(serviceID: Int)
    case createAttributeCategory(category: Category)
    case updateAttributeCategory(category: Category)
    case createAttribute(attribute: Attribute)
    case getAttributeImage(imgURL: String?)
    case uploadAttributeImage(imgUrl: URL, forAttributeId: Int)
    case updateAttribute(attribute: Attribute)
    case getOrderDetails(orderId: Int)
    case createOrderDetail(orderDetail: OrderDetail)
    case uploadDepartmentImage(imgURL: URL)
    case deleteAttribute(attributeID: Int)
    case addRelationBtwCategoryAndService(categoryID: Int, serviceID: Int)
    case deleteRelationBtwCategoryAndService(categoryID: Int, serviceID: Int)
    case getRelationBtwCategoryAndService(categoryID: Int)
    case getOrderByID(orderID: Int)
    case deleteCategory(categoryID: Int)
    case createGarment(orderDetail: OrderDetail)
    case updateOrder(order: Order, orderID: Int)
    case deleteOrderDetail(orderDetailID: Int)
    case processPayment(amount: Double, orderID: Int)
    
}

extension LemonAPI : TargetType {
    
    var headers: [String : String]? {
        switch self {
        case .login(let email, let password):
            let headers = [
                LemonAPI.USER_ID_HEADER     : email,
                LemonAPI.USER_PASS_HEADER   : password
            ]
            
            return headers
            
        case .startSession(let userId, _, let password):
            let headers = [
                LemonAPI.USER_NAME_HEADER         : "\(userId)",
                LemonAPI.USER_PASSWORD_HEADER     : password,
                LemonAPI.USER_GRANT_TYPE_HEADER   : "password"
            ]
            
            return headers
            
        case .chagePassword(let password):
            var headers: [String:String]? = nil
            if let oldPassword = LemonAPI.userPassword,
                let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    LemonAPI.USER_ID_HEADER         : "\(userId)",
                    LemonAPI.USER_PASS_HEADER       : password,
                    LemonAPI.USER_OLD_PASS_HEADER   : oldPassword,
                    "Authorization": "Bearer \(accessToken)"
                ]
            }
            return headers
            
        case .restorePassword(let email):
            let headers = [
                LemonAPI.USER_ID_HEADER : email
            ]
            return headers
            
        case .getProfileImage,
             .getCloudClosetImage,
             .getAttributeImage:
            
            return nil
            
        case .getOrdersUpdates:
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                
            }
            return headers
            
        case .checkEmail,
             .checkPhone:
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    "Content-Type":  "application/json;charset=UTF-8",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                
            }
            return headers
            
        case .getOrderImage:
            return nil
            
        case .getGarmentByBarcode, .getOrderDetails, .getAllOrders:
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
            }
            return headers
            
        default:
            var headers: [String:String]? = nil
            if let accessToken = LemonAPI.accessToken?.value,
                let userId = LemonAPI.userId {
                headers = [
                    "Authorization": "Bearer \(accessToken)",
                    LemonAPI.USER_ID_HEADER: "\(userId)"
                ]
                
                //print("Authorization: Bearer \(accessToken)")
                //print("User id: \(userId)")
            }
            
            return headers
            
        }
    }
    
    
    var baseURL: URL {
        switch self {
        case .getProfileImage,
             .getCloudClosetImage,
             .getAttributeImage:
            return URL(string: Config.LemonEndpoints.PicsEndpoint.rawValue)!
        case .uploadPhoto:
            return URL(string: Config.LemonEndpoints.UploadPicturesAPIEndpoint.rawValue)!
        case .uploadPhotoNote, .deleteOrderImage:
            return URL(string: Config.LemonEndpoints.UploadPicturesAPIEndpoint.rawValue)!
        case .uploadAttributeImage:
            return URL(string: Config.LemonEndpoints.UploadPicturesAPIEndpoint.rawValue)!
        case .startSession:
            return URL(string: Config.LemonEndpoints.UploadPicturesAPIEndpoint.rawValue)!
        case .getOrderImage(let imageURL):
            return URL(string: imageURL ?? "")!
        default:
            return URL(string: Config.LemonEndpoints.APIEndpoint.rawValue)!
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .startSession:
            return "token"
        case .restorePassword:
            return "forgotpassword"
        case .signUp:
            return "register"
        case .addAddress:
            return "addaddress"
        case .addPaymentCard:
            return "addpayment"
        case .addOrder:
            return "placeorder"
        case .editAddress:
            return "editaddress"
        case .editPaymentCard:
            return "editpayment"
        case .editProfile:
            return "editprofile"
        case .deleteAddress(let address):
            guard let id = address.id else { return "" }
            return "deleteaddress/\(id)"
        case .deletePaymentCard(let paymentCard):
            guard let id = paymentCard.id else { return "" }
            return "deletepayment/\(id)"
        case .getOrders:
            return "getorders"
        case .getAllOrders:
            return "orders"
        case .cancelOrder(let orderId):
            return "cancelorder/\(orderId)"
        case .getOrdersStatuses:
            return "getorderstatuses"
        case .getAddresses:
            return "getaddresses"
        case .chagePassword:
            return "changepassword"
        case .getProfileImage(let imageURL):
            return "lemonpics/" + (imageURL ?? "")
        case .getOrderImage:
            return ""
        case .deleteOrderImage(let orderId, let picId):
            return "deleteorderpic/\(orderId)/\(picId)"
        case .uploadPhoto:
            return "uploadpic"
        case .uploadPhotoNote(_, let order):
            return "uploadorderpicv2/\(order.id)"
        case .getProducts:
            return "getproducts"
        case .getPaymentCards:
            return "getpayments"
        case .getDeliveryOptions:
            return "getdelivery"
        case .addComment:
            return "support"
        case .getFaq:
            return "getfaq"
        case .getPaymentToken:
            return "paymenttoken"
        case .validateZip(let zip):
            return "zipsearch/\(zip)"
        case .validatePromocode(let code):
            return "checkpromo/\(code)"
        case .getWallet(let userId):
            return "getwallet/\(userId)"
        case .cloudCloset(let userId):
            return "cloudcloset/\(userId)"
        case .getServerApiVersion:
            return "version"
        case .getOrdersUpdates(let userId, _):
            return "GetUpdates/\(userId)/"
        case .checkEmail:
            return "Checkemail/"
        case .checkPhone:
            return "Checkphone/"
        case .checkReferral(let referralCode):
            return "CheckReferral/\(referralCode)"
        case .archiveWalletTransition(let walletTransition):
            return "archivewallet/\(walletTransition.id)"
        case .archiveOrder(let order):
            return "archiveorder/\(order.id)"
        case .getCloudCloset(let userId):
            return "cloudcloset/\(userId)"
        case .getCloudClosetImage(let imgURL):
            return "closet/" + imgURL
        case .editOrder(let editedOrder):
            return "editorder/\(editedOrder.id)"
        case .getPickupETA:
            return "getpickupglobal"
        case .setPickupETA(let pickupETA):
            return "changepickupglobal/\(pickupETA)"
        case .setOrderStatus:
            return "orders/changestatus"
        case .addNote:
            return "notes"
        case .getGarmentByBarcode:
            return "garments"
        case .getServices:
            return "services"
        case .deleteService(let serviceID):
            return "services/\(serviceID)"
        case .getAllServices:
            return "services/all"
        case .getDepartments:
            return "department"
        case .getDepartmentsAll:
            return "department/all"
        case .createDepartment:
            return "department"
        case .updateDepartment:
            return "department"
        case .deleteDepartment(let departmentID):
            return "department/\(departmentID)"
        case .updateServices:
            return "services"
        case .createService:
            return "services"
        case .getAttributeCategories:
            return "attributecategories"
        case .createAttributeCategory,
             .updateAttributeCategory:
            return "attributecategories"
        case .createAttribute,
             .updateAttribute:
            return "attributes"
        case .uploadAttributeImage(_, let id):
            return "uploadattributepic/\(id)"
        case .getAttributeImage(let imageURL):
            return "lemonpics/" + (imageURL ?? "")
        case .getOrderDetails:
            return "orderdetails"
        case .createOrderDetail:
            return "orderdetails"
        case .uploadDepartmentImage:
            return "services/uploadimage"
        case .deleteAttribute(let attributeID):
            return "attributes/\(attributeID)"
        case .getAttributeCategoriesByService(let serviceID):
            return "CategoryService/services/\(serviceID)"
        case .addRelationBtwCategoryAndService(let categoryID, let serviceID):
            return "CategoryService/add/\(categoryID)/\(serviceID)"
        case .deleteRelationBtwCategoryAndService(let categoryID, let serviceID):
            return "CategoryService/delete/\(categoryID)/\(serviceID)"
        case .getRelationBtwCategoryAndService(let categoryID):
            return "CategoryService/category/\(categoryID)"
        case .getOrderByID(let orderID):
            return "orders/\(orderID)"
        case .deleteCategory(let categoryID):
            return "attributecategories/\(categoryID)"
        case .createGarment:
            return "orderdetails/garment"
        case .updateOrder(let _, let orderID):
            return "editorder/\(orderID)"
        case .deleteOrderDetail(let orderDetailID):
            return "orderdetails/\(orderDetailID)"
        case .processPayment(let amount, let orderID):
            return "processtransaction2/\(amount)/\(orderID)/"
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .signUp(let firstName, let lastName, let email, let password, let mobilePhone, let zipCode, let referralCode, let referredById):
            var params = [
                "First" : firstName,
                "Last" : lastName,
                "Email" : email,
                "Password" : password,
                "Mobile": mobilePhone,
                "ZipCode": zipCode
            ]
            if let referralCode = referralCode, let referredById = referredById {
                
                params["ReferralCode"] = referralCode
                params["ReferredById"] = "\(referredById)"
            }
            return params as [String : AnyObject]
        case .startSession(_, let email, let password):
            return [
                "username" : email as AnyObject,
                "password" : password as AnyObject,
                "grant_type" : "password" as AnyObject
            ]
        case .addAddress(let address):
            return address.encode()
        case .addPaymentCard(let paymentCard):
            return paymentCard.encode()
        case .addOrder(let order):
            return order.encode()
        case .cancelOrder(let orderId):
            return ["orderid" : orderId as AnyObject]
        case .editAddress(let address):
            return address.encode()
        case .editPaymentCard(let paymentCard):
            return paymentCard.encode()
        case .editProfile(let user):
            return user.encode()
        case .addComment(let text):
            return ["comment": text as AnyObject]
        case .getOrdersUpdates( _, let lastDate):
            return ["date": lastDate.serverString() + ".000" as AnyObject]
        case .checkEmail(let email):
            //return ["email" : email as AnyObject]
            return ["search" : email as AnyObject]
        case .checkPhone(let phone):
            //return ["phone" : phone as AnyObject]
            return ["search" : phone as AnyObject]
        case .editOrder(let order):
            return order.encode()
        case .setOrderStatus(let editedOrder, let status):
            return [
                "OrderId" : editedOrder.id as AnyObject,
                "StatusId" : status.rawValue as AnyObject,
                "UserId" : DataProvider.sharedInstance.userWrapper?.id as AnyObject
            ]
        case .addNote(let note):
            return [
                "Type" : note.type.typeString as AnyObject,
                "Id" : note.ownerId as AnyObject,
                "Note" : note.text as AnyObject
            ]
        case .getGarmentByBarcode(let barcode):
            return ["barcode": barcode as AnyObject]
        case .createDepartment(let department):
            return department.encode()
        case .updateDepartment(let department):
            return department.encode()
        case .updateServices(let service):
            return service.encode()
        case .createService(let service):
            return service.encode()
        case .createAttributeCategory(let category):
            return category.encode()
        case .updateAttributeCategory(let category):
            return category.encode()
        case .createAttribute(let category):
            return category.encode()
        case .updateAttribute(let category):
            return category.encode()
        case .getOrderDetails(let orderId):
            return ["orderId": orderId as AnyObject]
        case .createOrderDetail(let orderDetail):
            return orderDetail.encode()
        case .createGarment(let orderDetail):
            return orderDetail.encode()
        case .getAllOrders:
            return ["$filter": "OrderStatus le 5 or OrderStatus eq 9" as AnyObject]
        case .updateOrder(let order, let _):
            return order.encode()
        default:
            return nil
        }
    }
    
    var parts: [MultipartFormData]? {
        switch self {
        case .uploadPhoto(let photoURL):
            let photoData = MultipartFormData(provider: .file(photoURL), name: "UploadedFile", fileName: "UploadedFile", mimeType: "")
            return [photoData]
        case .uploadPhotoNote(let photoURL, _):
            let photoData = MultipartFormData(provider: .file(photoURL), name: "UploadedFile", fileName: "UploadedFile", mimeType: "")
            return [photoData]
        case .uploadAttributeImage(let imgURL, _):
            let photoData = MultipartFormData(provider: .file(imgURL), name: "UploadedFile", fileName: "UploadedFile", mimeType: "")
            return [photoData]
        case .uploadDepartmentImage(let imgURL):
            let photoData = MultipartFormData(provider: .file(imgURL), name: "UploadedFile", fileName: "UploadedFile", mimeType: "")
            return [photoData]
        default:
            return nil
        }
    }
    
    var task: Task {
        if let params = self.parameters {
            if self.method == .get {
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
            }
            else {
                switch self {
                case .startSession:
                    return .requestParameters(parameters: params, encoding: URLEncoding.default)
                default:
                    return .requestParameters(parameters: params, encoding: JSONEncoding.default)
                }
            }
        }
        else if let parts = self.parts {
            return .uploadMultipart(parts)
        }
        else {
            return .requestPlain
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getOrders,
             .getAllOrders,
             .getOrdersStatuses,
             .getAddresses,
             .getProducts,
             .getPaymentCards,
             .getProfileImage,
             .getDeliveryOptions,
             .validateZip,
             .getWallet,
             .getFaq,
             .cloudCloset,
             .getServerApiVersion,
             .archiveWalletTransition,
             .getCloudCloset,
             .getCloudClosetImage,
             .getOrderImage,
             .getPickupETA,
             .getGarmentByBarcode,
             .getServices,
             .getAllServices,
             .getDepartments,
             .getDepartmentsAll,
             .getAttributeCategories,
             .getAttributeImage,
             .getAttributeCategoriesByService,
             .getRelationBtwCategoryAndService,
             .getOrderByID,
             .getOrderDetails:
            return .get
        case .updateAttributeCategory,
             .updateDepartment,
             .updateServices,
             .updateAttribute:
            return .put
        case .deleteService,
             .deleteAttribute,
             .deleteRelationBtwCategoryAndService,
             .deleteCategory,
             .deleteOrderDetail,
             .deleteDepartment:
            return .delete
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    
    //TODO migration-check
    
    //Before migration code
    
    
    /*
    var parts: [MultipartBodyPart]? {
        switch self {
        case .uploadPhoto(let photoURL):
            let dataProvider = MultipartBodyPart.DataProvider.file(photoURL)
            return [MultipartBodyPart(name: "UploadedFile", provider: dataProvider, length: 0, fileName: "UploadedFile", mimeType: "")]
        case .uploadPhotoNote(let photoURL, _):
            let dataProvider = MultipartBodyPart.DataProvider.file(photoURL)
            return [MultipartBodyPart(name: "UploadedFile", provider: dataProvider, length: 0, fileName: "UploadedFile", mimeType: "")]
        case .uploadAttributeImage(let imgURL, _):
            let dataProvider = MultipartBodyPart.DataProvider.file(imgURL)
            return [MultipartBodyPart(name: "UploadedFile", provider: dataProvider, length: 0, fileName: "UploadedFile", mimeType: "")]
        case .uploadDepartmentImage(let imgURL):
            let dataProvider = MultipartBodyPart.DataProvider.file(imgURL)
            return [MultipartBodyPart(name: "UploadedFile", provider: dataProvider, length: 0, fileName: "UploadedFile", mimeType: "")]
        default:
            return nil
        }
    }
 */
}

//Errors

struct BackendError: ErrorWithDescriptionType {
    
    let title: String
    let message: String    
}

extension UIViewController {
    func handleError(_ error: ErrorWithDescriptionType) {
        showAlert(error.title, message: error.message)
    }
}

extension BackendError: JSONDecodable {
    
    static func decode(_ j: JSON) throws -> BackendError {
        return BackendError(
            title: try j["Title"].value(),
            message: try j["Message"].value()
        )
    }
}

//Helper 
private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
