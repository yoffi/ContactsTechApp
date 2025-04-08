//
//  ContactDetailViewModel.swift
//  ContactsTechApp
//
//  Created by Joffrey Bocquet on 04/04/2025.
//

import Foundation

final class ContactDetailViewModel: Sendable {
  private let randomUserService: RandomUserServiceInterface
  private let userID: String

  init(randomUserService: RandomUserServiceInterface, userID: String) {
    self.randomUserService = randomUserService
    self.userID = userID
  }
  
  func loadDetails() async -> ContactDetailViewModelItem? {
    do {
      let user = try await randomUserService.fetchUser(id: userID)
      return buildViewModel(user: user)
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  func buildViewModel(user: any UserInterface) -> ContactDetailViewModelItem {
    let fullname = PersonNameComponentsFormatter.longStyle.fullNameFormatted(
      with: user.name.title,
      first: user.name.first,
      last: user.name.last)

    return ContactDetailViewModelItem(
      fullname: fullname,
      pictureURL: user.picture.large,
      sections: buildSections(user: user)
    )
  }
  
  func buildSections(user: any UserInterface) -> [ContactDetailSecionViewModelItem] {
    return [
      buildBasicInfo(user: user),
      buildContactInfo(user: user),
      buildLocationSection(location: user.location),
      buildLoginSection(login: user.login),
      buildIDSections(id: user.id)
    ]
  }
  
  func buildBasicInfo(user: any UserInterface) -> ContactDetailSecionViewModelItem {
    let dobFormatted = DateFormatter.BirthdayDataFormatter.string(from: user.dob.date)
    let ageFormatted = DateComponentsFormatter.YearDurationFormatter.string(from: user.dob.age)
    
    return ContactDetailSecionViewModelItem(
      title: "Basic Information",
      systemName: "person.fill",
      rows:[
      ContactDetailSectionRowViewModelItem(label: "Gender", value: user.gender),
      ContactDetailSectionRowViewModelItem(label: "Nationality", value: user.nat),
      ContactDetailSectionRowViewModelItem(label: "Date of Birth", value: dobFormatted),
      ContactDetailSectionRowViewModelItem(label: "Age", value: String(ageFormatted))
    ])
  }
  
  func buildContactInfo(user: any UserInterface) -> ContactDetailSecionViewModelItem {
    let formattedPhone = NumberFormatter.PhoneFormatter.string(from: user.phone)
    let formattedCell = NumberFormatter.PhoneFormatter.string(from: user.cell)

    return ContactDetailSecionViewModelItem(
      title: "Contact Information",
      systemName: "envelope.fill",
      rows: [
        ContactDetailSectionRowViewModelItem(label: "Phone", value: formattedPhone),
        ContactDetailSectionRowViewModelItem(label: "Cell", value: formattedCell)
      ])
  }
  
  func buildLocationSection(location: any LocationInterface) -> ContactDetailSecionViewModelItem {
    let fullStreet = "\(location.street.number) \(location.street.name)"
    let coordinatesFormatted = NumberFormatter.CoordinateFromatter.string(
      latitude: location.coordinates.latitude,
      longitude: location.coordinates.longitude)
    
    return ContactDetailSecionViewModelItem(
      title: "Location",
      systemName: "mappin.and.ellipse",
      rows: [
        ContactDetailSectionRowViewModelItem(label: "Street", value: fullStreet),
        ContactDetailSectionRowViewModelItem(label: "City", value: location.city),
        ContactDetailSectionRowViewModelItem(label: "State", value: location.state),
        ContactDetailSectionRowViewModelItem(label: "Country", value: location.country),
        ContactDetailSectionRowViewModelItem(label: "Postcode", value: location.postcode),
        ContactDetailSectionRowViewModelItem(label: "Coordinates", value: coordinatesFormatted)
      ]
    )
  }
  
  func buildLoginSection(login: any LoginInterface) -> ContactDetailSecionViewModelItem {
    let maskedPassword = String(repeating: "•", count: (1...login.password.count).randomElement() ?? 4)
    return ContactDetailSecionViewModelItem(
      title: "Login Information",
      systemName: "lock.fill",
      rows: [
        ContactDetailSectionRowViewModelItem(label: "Username", value: login.username),
        ContactDetailSectionRowViewModelItem(label: "UUID", value: login.uuid),
        ContactDetailSectionRowViewModelItem(label: "Password", value: maskedPassword)
      ]
    )
  }
  
  func buildIDSections(id: any IDInterface) -> ContactDetailSecionViewModelItem {
    let resolvedID = id.value ?? "Not Available"
    return ContactDetailSecionViewModelItem(
      title: "ID Information",
      systemName: "person.text.rectangle.fill",
      rows: [
        ContactDetailSectionRowViewModelItem(label: "ID Type", value: id.name),
        ContactDetailSectionRowViewModelItem(label: "ID Value", value: resolvedID),
      ]
    )
  }
  
  func buildRegistrationSection(anniversary: any AnniversaryInterface) -> ContactDetailSecionViewModelItem {
    let formattedDate = DateFormatter.EventDataFormatter.string(from: anniversary.date)
    let formattedAge = DateComponentsFormatter.YearDurationFormatter.string(from: anniversary.age)

    return ContactDetailSecionViewModelItem(
      title: "ID Information",
      systemName: "calendar.badge.clock",
      rows: [
        ContactDetailSectionRowViewModelItem(label: "Registered Date", value: formattedDate),
        ContactDetailSectionRowViewModelItem(label: "Duration", value: formattedAge)
      ]
    )
  }
}

// MARK: - ViewModel Reponse

struct ContactDetailViewModelItem {
  let fullname: String
  let pictureURL: URL
  let sections: [ContactDetailSecionViewModelItem]
}

struct ContactDetailSecionViewModelItem {
  let title: String
  let systemName: String
  let rows: [ContactDetailSectionRowViewModelItem]
}

struct ContactDetailSectionRowViewModelItem {
  let label: String
  let value: String
}
