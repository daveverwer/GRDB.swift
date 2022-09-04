import XCTest
import GRDB

class FetchedResultsTests: GRDBTestCase {
    func testFetchableRecord() throws {
        struct Player: FetchableRecord, PersistableRecord, Codable, Equatable {
            var id: Int64
            var name: String
            var score: Int
        }
        
        let dbPool = try makeDatabasePool()
        try dbPool.write { db in
            try db.create(table: "player") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("score", .integer)
            }
            
            try Player(id: 1, name: "Arthur", score: 10).insert(db)
            try Player(id: 2, name: "Barbara", score: 100).insert(db)
            try Player(id: 3, name: "Craig", score: 50).insert(db)
            try Player(id: 4, name: "Danielle", score: 20).insert(db)
        }
        
        let snapshot = try dbPool.makeSnapshot()
        let results = try Player
            .order(Column("score"))
            .fetchResults(snapshot)
        XCTAssertEqual(Array(results), [
            Player(id: 1, name: "Arthur", score: 10),
            Player(id: 4, name: "Danielle", score: 20),
            Player(id: 3, name: "Craig", score: 50),
            Player(id: 2, name: "Barbara", score: 100),
        ])
    }
    
    func testRow() throws {
        struct Player: FetchableRecord, PersistableRecord, Codable, Equatable {
            var id: Int64
            var name: String
            var score: Int
        }
        
        let dbPool = try makeDatabasePool()
        try dbPool.write { db in
            try db.create(table: "player") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("score", .integer)
            }
            
            try Player(id: 1, name: "Arthur", score: 10).insert(db)
            try Player(id: 2, name: "Barbara", score: 100).insert(db)
            try Player(id: 3, name: "Craig", score: 50).insert(db)
            try Player(id: 4, name: "Danielle", score: 20).insert(db)
        }
        
        let snapshot = try dbPool.makeSnapshot()
        let results = try Player
            .order(Column("score"))
            .asRequest(of: Row.self)
            .fetchResults(snapshot)
        XCTAssertEqual(Array(results), [
            ["id": 1, "name": "Arthur", "score": 10],
            ["id": 4, "name": "Danielle", "score": 20],
            ["id": 3, "name": "Craig", "score": 50],
            ["id": 2, "name": "Barbara", "score": 100],
        ])
    }
    
    func testDatabaseValueConvertible() throws {
        struct Player: FetchableRecord, PersistableRecord, Codable, Equatable {
            var id: Int64
            var name: String
            var score: Int
        }
        
        let dbPool = try makeDatabasePool()
        try dbPool.write { db in
            try db.create(table: "player") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("score", .integer)
            }
            
            try Player(id: 1, name: "Arthur", score: 10).insert(db)
            try Player(id: 2, name: "Barbara", score: 100).insert(db)
            try Player(id: 3, name: "Craig", score: 50).insert(db)
            try Player(id: 4, name: "Danielle", score: 20).insert(db)
        }
        
        let snapshot = try dbPool.makeSnapshot()
        let results = try Player
            .order(Column("score"))
            .select(Column("name"), as: String.self)
            .fetchResults(snapshot)
        XCTAssertEqual(Array(results), [
            "Arthur",
            "Danielle",
            "Craig",
            "Barbara",
        ])
    }
}
