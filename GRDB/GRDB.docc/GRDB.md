# ``GRDB``

A toolkit for SQLite databases, with a focus on application development

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

## Topics

### Database Connections

- ``Configuration``
- ``Database``
- ``DatabasePool``
- ``DatabaseQueue``
- ``DatabaseSnapshot``
- ``DatabaseReader``
- ``DatabaseWriter``

### Database Rows and Values

- ``DatabaseValue``
- ``Row``
- ``DatabaseDateComponents``
- ``DatabaseValueConvertible``
- ``StatementColumnConvertible``
- ``StatementBinding``

### Records

- ``Record``
- ``FetchableRecord``
- ``EncodableRecord``
- ``PersistableRecord``
- ``MutablePersistableRecord``
- ``TableRecord``
- ``ColumnAssignment``
- ``InsertionSuccess``
- ``PersistenceSuccess``
- ``PersistenceConflictPolicy``
- ``PersistenceContainer``
- ``PersistenceError``
- ``DatabaseColumnDecodingStrategy``
- ``DatabaseColumnEncodingStrategy``
- ``DatabaseDateDecodingStrategy``
- ``DatabaseDateEncodingStrategy``
- ``DatabaseUUIDEncodingStrategy``

### Cursors

- ``Cursor``
- ``DatabaseCursor``
- ``DatabaseValueCursor``
- ``FastDatabaseValueCursor``
- ``RecordCursor``
- ``RowCursor``

### Migrations

- ``DatabaseMigrator``

### Database Observation

- ``ValueObservation``
- ``SharedValueObservation``
- ``DatabaseRegionObservation``
- ``TransactionObserver``
- ``SharedValueObservationExtent``
- ``DatabaseEvent``
- ``DatabasePreUpdateEvent``
- ``DatabaseEventKind``

### Requests

- ``DerivableRequest``
- ``FetchRequest``
- ``SQLRequest``
- ``QueryInterfaceRequest``
- ``AdaptedFetchRequest``
- ``AnyFetchRequest``
- ``PreparedRequest``

### SQL Interpolation

- ``SQL``
- ``SQLInterpolation``

### Query Interface

- ``QueryInterfaceRequest``
- ``Table``
- ``CommonTableExpression``
- ``TableAlias``

### Query Interface: Expressions

- ``Column``
- ``ColumnExpression``
- ``SQLExpression``
- ``SQLExpressible``
- ``SQLSpecificExpressible``
- ``abs(_:)-5l6xp``
- ``abs(_:)-43n8v``
- ``average(_:)``
- ``count(_:)``
- ``count(distinct:)``
- ``dateTime(_:_:)``
- ``julianDay(_:_:)``
- ``length(_:)-41me0``
- ``length(_:)-9dr2v``
- ``max(_:)``
- ``min(_:)``
- ``sum(_:)``
- ``total(_:)``
- ``SQLDateModifier``

### Query Interface: Selection

- ``AllColumns``
- ``SQLSelection``
- ``SQLSelectable``

### Query Interface: Orderings

- ``SQLOrderingTerm``
- ``SQLOrdering``

### Query Interface: Subqueries

- ``SQLSubquery``
- ``SQLSubqueryable``

### Query Interface: Associations

- ``Association``
- ``AssociationToOne``
- ``AssociationToMany``
- ``AssociationAggregate``
- ``BelongsToAssociation``
- ``HasManyAssociation``
- ``HasManyThroughAssociation``
- ``HasOneAssociation``
- ``HasOneThroughAssociation``
- ``JoinAssociation``
- ``ForeignKey``
- ``Inflections``

### Full-Text Search

- ``FTS3``
- ``FTS3Pattern``
- ``FTS3TokenizerDescriptor``
- ``FTS4``
- ``FTS5``
- ``FTS5Pattern``
- ``FTS5TokenizerDescriptor``

### Row Adapters

- ``splittingRowAdapters(columnCounts:)``
- ``RowAdapter``
- ``ColumnMapping``
- ``EmptyRowAdapter``
- ``RangeRowAdapter``
- ``RenameColumnAdapter``
- ``ScopeAdapter``
- ``SuffixRowAdapter``
