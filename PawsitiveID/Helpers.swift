//
//  Helper.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/19/25.
//

import Foundation
import PhotosUI

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func isValidPhoneNumber(_ phone: String) -> Bool {
    let phoneRegex = #"^\+?[0-9|*|\-|,]+[0-9]$"#
    let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return phonePred.evaluate(with: phone)
}

func logIssue(message: String, data: Any?) {
    print("==PawsitiveID Log==", message, data ?? "NO_DATA", separator: " -- ")
}

func getPetApiName(type: AnimalType) -> String {
    switch type {
    case .Dog:
        return "DOG"
    case .Cat:
        return "CAT"
    case .Rabbit:
        return "RABBIT"
    case .Bird:
        return "BIRD"
    default:
        return "OTHER"
    }
}

func getPetType(type: String) -> String {
    switch type {
    case "DOG":
        return "Dog"
    case "CAT":
        return "Cat"
    case "RABBIT":
        return "Rabbit"
    case "BIRD":
        return "Bird"
    default:
        return "Other"
    }
}

func getFormattedDate(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-MM-d"

    if let date = dateFormatter.date(from: dateString) {
        return date.formatted(date: .long, time: .omitted)
    } else {
        return dateString
    }
}

func getFormattedDateTime(_ dateTimeString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y-MM-d HH:mm:ss"

    if let date = dateFormatter.date(from: dateTimeString) {
        return date.formatted(date: .long, time: .shortened)
    } else {
        return dateTimeString
    }
}

func deletePet(id: String, callback: @escaping () -> Void) {
    let url = URL(
        string: "https://unrealpixels.app/api/pawsitive-id/pet.php?id=\(id)"
    )!
    var request = URLRequest(url: url)
    request.setValue(
        "application/json; charset=utf-8",
        forHTTPHeaderField: "Content-Type"
    )
    request.httpMethod = "DELETE"

    let session = URLSession.shared.dataTask(with: request) {
        data,
        response,
        error in
        if error != nil || data == nil {
            logIssue(message: "Failed to POST pet chat", data: error)
            return
        }

        callback()
    }
    session.resume()
}

func resizeImage(photo: Data?) -> String? {
    if photo == nil {
        return nil
    }

    let width: CGFloat = 512
    let uiImage = UIImage(data: photo!)!
    let scale = width / uiImage.size.width
    let newHeight = uiImage.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(width, newHeight))
    uiImage.draw(in: CGRectMake(0, 0, width, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return "data:image/png;base64,"
        + (newImage?.pngData()?.base64EncodedString() ?? "")
}
