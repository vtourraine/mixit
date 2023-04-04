//
//  MixitClient.swift
//  mixit
//
//  Created by Vincent Tourraine on 05/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import Foundation
import CoreData

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601Mixit = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        if let date = dateFormatter.date(from: string) {
            return date
        }
        else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: " + string)
        }
    }
}

class MixitClient: ObservableObject {

    var context: NSManagedObjectContext?

    static let baseURL = URL(string: "https://mixitconf.org/api/")!
    static let currentYear = 2023
    static let pastYears = [2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2021, 2022]

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601Mixit
        return decoder
    }()

    @discardableResult
    func fetchTalks(for year: Int = MixitClient.currentYear, session: URLSession = .shared) -> URLSessionDataTask {
        let url = MixitClient.baseURL.appendingPathComponent("\(year)/talk")
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                else {
                    print("Error: no data")
                }
                return
            }

#if DEBUG
            if #available(iOS 16.0, macOS 13.0, *) {
                let path = NSTemporaryDirectory().appending("data.json")
                try? data.write(to: URL(filePath: path))
                print("Path: \(path)")
            }
#endif

            do {
                let objects = try self.decoder.decode([TalkResponse].self, from: data)
                DispatchQueue.main.async {
                    self.context?.update(with: objects)
                    try? self.context?.save()
                }
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
        }

        task.resume()
        return task
    }

    @discardableResult
    func fetchUsers(for year: Int = MixitClient.currentYear, session: URLSession = .shared) -> URLSessionDataTask {
        let url = MixitClient.baseURL.appendingPathComponent("\(year)/speaker")
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                else {
                    print("Error: no data")
                }
                return
            }

#if DEBUG
            if #available(iOS 16.0, macOS 13.0, *) {
                let path = NSTemporaryDirectory().appending("data.json")
                try? data.write(to: URL(filePath: path))
                print("Path: \(path)")
            }
#endif

            do {
                let objects = try self.decoder.decode([UserResponse].self, from: data)
                DispatchQueue.main.async {
                    self.context?.update(with: objects)
                    try? self.context?.save()
                }
            }
            catch {
                print("Error: \(error.localizedDescription)")
            }
        }

        task.resume()
        return task
    }
}
