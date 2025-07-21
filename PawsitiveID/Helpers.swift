//
//  Helper.swift
//  PawsitiveID
//
//  Created by Bi Nguyen on 7/19/25.
//

import Foundation

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func logIssue(message: String, data: Any?) -> Void {
    print("==PawsitiveID Log==", message, data ?? "NO_DATA", separator: " -- ")
}
