extension ValueReducers {
    /// A reducer which passes raw fetched values through.
    public struct SnapshotFetch<Value>: SnapshotReducer {
        private let __fetch: (DatabaseSnapshot) throws -> Value
        
        /// Creates a reducer which passes raw fetched values through.
        init(fetch: @escaping (DatabaseSnapshot) throws -> Value) {
            self.__fetch = fetch
        }
        
        /// :nodoc:
        public func _fetch(_ snapshot: DatabaseSnapshot) throws -> Value {
            return try __fetch(snapshot)
        }
        
        /// :nodoc:
        public func _value(_ fetched: Value) -> Value? {
            fetched
        }
    }
}
