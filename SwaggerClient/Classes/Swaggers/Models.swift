// Models.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

protocol JSONEncodable {
    func encodeToJSON() -> Any
}

public enum ErrorResponse : Error {
    case HttpError(statusCode: Int, data: Data?, error: Error)
    case DecodeError(response: Data?, decodeError: DecodeError)
}

open class Response<T> {
    open let statusCode: Int
    open let header: [String: String]
    open let body: T?

    public init(statusCode: Int, header: [String: String], body: T?) {
        self.statusCode = statusCode
        self.header = header
        self.body = body
    }

    public convenience init(response: HTTPURLResponse, body: T?) {
        let rawHeader = response.allHeaderFields
        var header = [String:String]()
        for case let (key, value) as (String, String) in rawHeader {
            header[key] = value
        }
        self.init(statusCode: response.statusCode, header: header, body: body)
    }
}

public enum Decoded<ValueType> {
    case success(ValueType)
    case failure(DecodeError)
}

public extension Decoded {
    var value: ValueType? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
}

public enum DecodeError {
    case typeMismatch(expected: String, actual: String)
    case missingKey(key: String)
    case parseError(message: String)
}

private var once = Int()
class Decoders {
    static fileprivate var decoders = Dictionary<String, ((AnyObject, AnyObject?) -> AnyObject)>()

    static func addDecoder<T>(clazz: T.Type, decoder: @escaping ((AnyObject, AnyObject?) -> Decoded<T>)) {
        let key = "\(T.self)"
        decoders[key] = { decoder($0, $1) as AnyObject }
    }

    static func decode<T>(clazz: T.Type, discriminator: String, source: AnyObject) -> Decoded<T> {
        let key = discriminator
        if let decoder = decoders[key], let value = decoder(source, nil) as? Decoded<T> {
            return value
        } else {
            return .failure(.typeMismatch(expected: String(describing: clazz), actual: String(describing: source)))
        }
    }

    static func decode<T>(clazz: [T].Type, source: AnyObject) -> Decoded<[T]> {
        if let sourceArray = source as? [AnyObject] {
            var values = [T]()
            for sourceValue in sourceArray {
                switch Decoders.decode(clazz: T.self, source: sourceValue, instance: nil) {
                case let .success(value):
                    values.append(value)
                case let .failure(error):
                    return .failure(error)
                }
            }
            return .success(values)
        } else {
            return .failure(.typeMismatch(expected: String(describing: clazz), actual: String(describing: source)))
        }
    }

    static func decode<T>(clazz: T.Type, source: AnyObject) -> Decoded<T> {
        switch Decoders.decode(clazz: T.self, source: source, instance: nil) {
    	    case let .success(value):
                return .success(value)
            case let .failure(error):
                return .failure(error)
        }
    }

    static open func decode<T: RawRepresentable>(clazz: T.Type, source: AnyObject) -> Decoded<T> {
        if let value = source as? T.RawValue {
            if let enumValue = T.init(rawValue: value) {
                return .success(enumValue)
            } else {
                return .failure(.typeMismatch(expected: "A value from the enumeration \(T.self)", actual: "\(value)"))
            }
        } else {
            return .failure(.typeMismatch(expected: "\(T.RawValue.self) matching a case from the enumeration \(T.self)", actual: String(describing: type(of: source))))
        }
    }

    static func decode<T, Key: Hashable>(clazz: [Key:T].Type, source: AnyObject) -> Decoded<[Key:T]> {
        if let sourceDictionary = source as? [Key: AnyObject] {
            var dictionary = [Key:T]()
            for (key, value) in sourceDictionary {
                switch Decoders.decode(clazz: T.self, source: value, instance: nil) {
                case let .success(value):
                    dictionary[key] = value
                case let .failure(error):
                    return .failure(error)
                }
            }
            return .success(dictionary)
        } else {
            return .failure(.typeMismatch(expected: String(describing: clazz), actual: String(describing: source)))
        }
    }

    static func decodeOptional<T: RawRepresentable>(clazz: T.Type, source: AnyObject?) -> Decoded<T?> {
        guard !(source is NSNull), source != nil else { return .success(nil) }
        if let value = source as? T.RawValue {
            if let enumValue = T.init(rawValue: value) {
                return .success(enumValue)
            } else {
                return .failure(.typeMismatch(expected: "A value from the enumeration \(T.self)", actual: "\(value)"))
            }
        } else {
            return .failure(.typeMismatch(expected: "\(T.RawValue.self) matching a case from the enumeration \(T.self)", actual: String(describing: type(of: source))))
        }
    }

    static func decode<T>(clazz: T.Type, source: AnyObject, instance: AnyObject?) -> Decoded<T> {
        initialize()
        if let sourceNumber = source as? NSNumber, let value = sourceNumber.int32Value as? T, T.self is Int32.Type {
            return .success(value)
        }
        if let sourceNumber = source as? NSNumber, let value = sourceNumber.int32Value as? T, T.self is Int64.Type {
     	    return .success(value)
        }
        if let intermediate = source as? String, let value = UUID(uuidString: intermediate) as? T, source is String, T.self is UUID.Type {
            return .success(value)
        }
        if let value = source as? T {
            return .success(value)
        }
        if let intermediate = source as? String, let value = Data(base64Encoded: intermediate) as? T {
            return .success(value)
        }

        let key = "\(T.self)"
        if let decoder = decoders[key], let value = decoder(source, instance) as? Decoded<T> {
           return value
        } else {
            return .failure(.typeMismatch(expected: String(describing: clazz), actual: String(describing: source)))
        }
    }

    //Convert a Decoded so that its value is optional. DO WE STILL NEED THIS?
    static func toOptional<T>(decoded: Decoded<T>) -> Decoded<T?> {
        return .success(decoded.value)
    }

    static func decodeOptional<T>(clazz: T.Type, source: AnyObject?) -> Decoded<T?> {
        if let source = source, !(source is NSNull) {
            switch Decoders.decode(clazz: clazz, source: source, instance: nil) {
            case let .success(value): return .success(value)
            case let .failure(error): return .failure(error)
            }
        } else {
            return .success(nil)
        }
    }
    
    static func decodeOptional<T>(clazz: [T].Type, source: AnyObject?) -> Decoded<[T]?> where T: RawRepresentable {
        if let source = source as? [AnyObject] {
            var values = [T]()
            for sourceValue in source {
                switch Decoders.decodeOptional(clazz: T.self, source: sourceValue) {
                case let .success(value): if let value = value { values.append(value) }
                case let .failure(error): return .failure(error)
                }
            }
            return .success(values)
        } else {
            return .success(nil)
        }
    }

    static func decodeOptional<T>(clazz: [T].Type, source: AnyObject?) -> Decoded<[T]?> {
        if let source = source as? [AnyObject] {
            var values = [T]()
            for sourceValue in source {
                switch Decoders.decode(clazz: T.self, source: sourceValue, instance: nil) {
                case let .success(value): values.append(value)
                case let .failure(error): return .failure(error)
                }
            }
            return .success(values)
        } else {
            return .success(nil)
        }
    }

    static func decodeOptional<T, Key: Hashable>(clazz: [Key:T].Type, source: AnyObject?) -> Decoded<[Key:T]?> {
        if let sourceDictionary = source as? [Key: AnyObject] {
            var dictionary = [Key:T]()
            for (key, value) in sourceDictionary {
                switch Decoders.decode(clazz: T.self, source: value, instance: nil) {
                case let .success(value): dictionary[key] = value
                case let .failure(error): return .failure(error)
                }
            }
            return .success(dictionary)
        } else {
            return .success(nil)
        }
    }

    static func decodeOptional<T: RawRepresentable, U: AnyObject>(clazz: T, source: AnyObject) -> Decoded<T?> where T.RawValue == U {
        if let value = source as? U {
            if let enumValue = T.init(rawValue: value) {
                return .success(enumValue)
            } else {
                return .failure(.typeMismatch(expected: "A value from the enumeration \(T.self)", actual: "\(value)"))
            }
        } else {
            return .failure(.typeMismatch(expected: "String", actual: String(describing: type(of: source))))
        }
    }


    private static var __once: () = {
        let formatters = [
            "yyyy-MM-dd",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss"
        ].map { (format: String) -> DateFormatter in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }
        // Decoder for Date
        Decoders.addDecoder(clazz: Date.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<Date> in
           if let sourceString = source as? String {
                for formatter in formatters {
                    if let date = formatter.date(from: sourceString) {
                        return .success(date)
                    }
                }
            }
            if let sourceInt = source as? Int {
                // treat as a java date
                return .success(Date(timeIntervalSince1970: Double(sourceInt / 1000) ))
            }
            if source is String || source is Int {
                return .failure(.parseError(message: "Could not decode date"))
            } else {
                return .failure(.typeMismatch(expected: "String or Int", actual: "\(source)"))
            }
        }

        // Decoder for ISOFullDate
        Decoders.addDecoder(clazz: ISOFullDate.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<ISOFullDate> in
            if let string = source as? String,
               let isoDate = ISOFullDate.from(string: string) {
                return .success(isoDate)
            } else {
            	return .failure(.typeMismatch(expected: "ISO date", actual: "\(source)"))
            }
        }

        // Decoder for [AddResponse]
        Decoders.addDecoder(clazz: [AddResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[AddResponse]> in
            return Decoders.decode(clazz: [AddResponse].self, source: source)
        }

        // Decoder for AddResponse
        Decoders.addDecoder(clazz: AddResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<AddResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? AddResponse() : instance as! AddResponse
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Name"] as AnyObject?) {
                
                case let .success(value): _result.name = value
                case let .failure(error): break
                
                }
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Hash"] as AnyObject?) {
                
                case let .success(value): _result.hash = value
                case let .failure(error): break
                
                }
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Size"] as AnyObject?) {
                
                case let .success(value): _result.size = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "AddResponse", actual: "\(source)"))
            }
        }
        // Decoder for [Key]
        Decoders.addDecoder(clazz: [Key].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[Key]> in
            return Decoders.decode(clazz: [Key].self, source: source)
        }

        // Decoder for Key
        Decoders.addDecoder(clazz: Key.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<Key> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? Key() : instance as! Key
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Name"] as AnyObject?) {
                
                case let .success(value): _result.name = value
                case let .failure(error): break
                
                }
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Id"] as AnyObject?) {
                
                case let .success(value): _result.id = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "Key", actual: "\(source)"))
            }
        }
        // Decoder for [KeyList]
        Decoders.addDecoder(clazz: [KeyList].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[KeyList]> in
            return Decoders.decode(clazz: [KeyList].self, source: source)
        }

        // Decoder for KeyList
        Decoders.addDecoder(clazz: KeyList.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<KeyList> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? KeyList() : instance as! KeyList
                switch Decoders.decodeOptional(clazz: [Key].self, source: sourceDictionary["Keys"] as AnyObject?) {
                
                case let .success(value): _result.keys = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "KeyList", actual: "\(source)"))
            }
        }
        // Decoder for [PinResponse]
        Decoders.addDecoder(clazz: [PinResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[PinResponse]> in
            return Decoders.decode(clazz: [PinResponse].self, source: source)
        }

        // Decoder for PinResponse
        Decoders.addDecoder(clazz: PinResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<PinResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? PinResponse() : instance as! PinResponse
                switch Decoders.decodeOptional(clazz: [String].self, source: sourceDictionary["Pins"] as AnyObject?) {
                
                case let .success(value): _result.pins = value
                case let .failure(error): break
                
                }
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Progress"] as AnyObject?) {
                
                case let .success(value): _result.progress = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "PinResponse", actual: "\(source)"))
            }
        }
        // Decoder for [PublishResponse]
        Decoders.addDecoder(clazz: [PublishResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[PublishResponse]> in
            return Decoders.decode(clazz: [PublishResponse].self, source: source)
        }

        // Decoder for PublishResponse
        Decoders.addDecoder(clazz: PublishResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<PublishResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? PublishResponse() : instance as! PublishResponse
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Name"] as AnyObject?) {
                
                case let .success(value): _result.name = value
                case let .failure(error): break
                
                }
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Value"] as AnyObject?) {
                
                case let .success(value): _result.value = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "PublishResponse", actual: "\(source)"))
            }
        }
        // Decoder for [ResolveResponse]
        Decoders.addDecoder(clazz: [ResolveResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[ResolveResponse]> in
            return Decoders.decode(clazz: [ResolveResponse].self, source: source)
        }

        // Decoder for ResolveResponse
        Decoders.addDecoder(clazz: ResolveResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<ResolveResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? ResolveResponse() : instance as! ResolveResponse
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Path"] as AnyObject?) {
                
                case let .success(value): _result.path = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "ResolveResponse", actual: "\(source)"))
            }
        }
        // Decoder for [KeygenResponse]
        Decoders.addDecoder(clazz: [KeygenResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[KeygenResponse]> in
            return Decoders.decode(clazz: [KeygenResponse].self, source: source)
        }

        // Decoder for KeygenResponse
        Decoders.addDecoder(clazz: KeygenResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<KeygenResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? KeygenResponse() : instance as! KeygenResponse
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Name"] as AnyObject?) {
                
                case let .success(value): _result.name = value
                case let .failure(error): break
                
                }
                switch Decoders.decodeOptional(clazz: String.self, source: sourceDictionary["Id"] as AnyObject?) {
                
                case let .success(value): _result.id = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "KeygenResponse", actual: "\(source)"))
            }
        }
        // Decoder for [ListKeysResponse]
        Decoders.addDecoder(clazz: [ListKeysResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[ListKeysResponse]> in
            return Decoders.decode(clazz: [ListKeysResponse].self, source: source)
        }

        // Decoder for ListKeysResponse
        Decoders.addDecoder(clazz: ListKeysResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<ListKeysResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? ListKeysResponse() : instance as! ListKeysResponse
                switch Decoders.decodeOptional(clazz: [Key].self, source: sourceDictionary["Keys"] as AnyObject?) {
                
                case let .success(value): _result.keys = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "ListKeysResponse", actual: "\(source)"))
            }
        }
        // Decoder for [RemoveKeyResponse]
        Decoders.addDecoder(clazz: [RemoveKeyResponse].self) { (source: AnyObject, instance: AnyObject?) -> Decoded<[RemoveKeyResponse]> in
            return Decoders.decode(clazz: [RemoveKeyResponse].self, source: source)
        }

        // Decoder for RemoveKeyResponse
        Decoders.addDecoder(clazz: RemoveKeyResponse.self) { (source: AnyObject, instance: AnyObject?) -> Decoded<RemoveKeyResponse> in
            if let sourceDictionary = source as? [AnyHashable: Any] {
                let _result = instance == nil ? RemoveKeyResponse() : instance as! RemoveKeyResponse
                switch Decoders.decodeOptional(clazz: [Key].self, source: sourceDictionary["Keys"] as AnyObject?) {
                
                case let .success(value): _result.keys = value
                case let .failure(error): break
                
                }
                return .success(_result)
            } else {
                return .failure(.typeMismatch(expected: "RemoveKeyResponse", actual: "\(source)"))
            }
        }
    }()

    static fileprivate func initialize() {
        _ = Decoders.__once
    }
}
