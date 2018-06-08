import Foundation

struct Team: Codable {
    let name: String
    let member: [User]
}

struct User: Codable {
    let id: Int64
    let name: String
    let password: String
    let email: [Email]
    let created_at: String
}

struct Member: Codable {
  let id: Int64
  let name: String
  let password: String
  let email: [Email]
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"

    case id = "id"
    case name = "name"
    case password = "password"
    case email = "email"
  }
}

struct Email: Codable {
    let value: String
    let primary: Bool?
}

let userJson = """
    {
      "id": 219038
    , "name": "James Thunder"
    , "password": "s0r23ndsn0q3mf083259"
    , "created_at": "2015-04-13T14:20:32"
    , "email": [
      {
        "value": "jim@example.com"
      , "primary": true
      }
    ]
    }
"""

let decoder = JSONDecoder()

let userJsonData: Data = userJson.data(using: .utf8)!

let user: User = try! decoder.decode(User.self, from: userJsonData)
let member: Member = try! decoder.decode(Member.self, from: userJsonData)

print(user)
print(member)

let usersJson = "[\(userJson)]"

let users = try! decoder.decode([User].self, from: usersJson.data(using: .utf8)!)

print(users)
