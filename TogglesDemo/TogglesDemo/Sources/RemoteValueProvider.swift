//  RemoteValueProvider.swift

import Foundation
import Toggles

public class RemoteValueProvider: ValueProvider {
    
    public var name: String { "Remote" }
    
    private var toggles: [Variable: Value]
    
    public init(jsonURL: URL) throws {
        let content = try Data(contentsOf: jsonURL)
        let dataSource = try JSONDecoder().decode(DataSource.self, from: content)
        self.toggles = Dictionary(grouping: dataSource.toggles, by: \.variable)
            .mapValues { $0.first! }
            .mapValues { $0.value }
    }
    
    public func value(for variable: Variable) -> Value {
        toggles[variable] ?? .none
    }
    
    public func fakeFetchLatestConfiguration(_ completion: () -> Void) {
        self.toggles = toggles.mapValues { value in
            switch value {
            case .none:
                return .none
            case .bool:
                return .bool(Int(arc4random()) % 2 == 0 ? false : true)
            case .int:
                return .int(Int(arc4random()) % 100)
            case .number:
                return .number(Double(Int(arc4random()) % 100) + Double((Int(arc4random()) % 100)) / 100)
            case .string:
                return .string(Int(arc4random()) % 2 == 0 ? "Hello World" : "Ciao mondo")
            case .encrypted:
                return .encrypted(Int(arc4random()) % 2  == 0 ? "€ncrypted" : "3ncrypted")
            }
        }
        completion()
    }
}