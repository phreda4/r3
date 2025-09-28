# R3 Database System Documentation

## Overview

`db2.r3` provides a lightweight, file-based database system for R3 applications. It uses a simple text format with delimiter-separated fields and supports both static database loading and incremental record processing. The system is designed for applications requiring simple data persistence without the overhead of complex database engines.

## Dependencies
- `r3/lib/console.r3` - Console output for debugging

## Database Format

### Text-Based Structure
The database uses ASCII text with specific delimiters:
- **Field separator**: `|` (ASCII 124) - separates fields within a record
- **Record separator**: `^` (ASCII 94) - marks end of record
- **Group separator**: `,` (ASCII 44) - separates sub-fields within a field

### Example Database Format
```
John Doe|25|Engineer,Software|Active^
Jane Smith|30|Manager,Operations|Active^
Bob Johnson|28|Developer,Frontend,JavaScript|Inactive^
```

This represents three records with fields for name, age, role information, and status.

## Core Data Structures

### Field Management
```r3
#flds * 512          // Field pointer array (128 fields max)
#flds>               // Current position in field array
#memflds * 8192      // Field content storage (8KB)
#memflds>            // Current position in field storage
#rowdb               // Current row index for incremental loading
```

## File Management Functions

### Directory Navigation
```r3
getnfilename | index "path" -- "filename"/0    // Get nth file from directory
loadnfile    | "path" -- "filename"           // Load next file in sequence
```

These functions enable processing multiple database files in sequence, useful for batch operations or data migration.

## Static Database Operations

### Loading Complete Database
```r3
loaddb       | "filename" -- db_pointer       // Load entire database into memory
```

Loads the complete database file into a contiguous memory block, suitable for read-only operations or when the entire dataset fits in memory.

### Record Navigation
```r3
getdbrow     | row_index db_pointer -- row_address    // Get specific row
>>line       | address -- next_line_address/0        // Skip to next record
cntdbrow     | db_pointer -- row_count               // Count total records
```

### Field Access
```r3
getdbfld     | field_index row_address -- field_address   // Get field from row
>>fld        | address -- next_field_address             // Skip to next field
cpydbfld     | field_address buffer --                   // Copy field to buffer
cpydbfldn    | max_length field_address buffer --       // Copy with length limit
```

### Search Operations
```r3
findbrow     | hash db_pointer -- row_address/0      // Find row by hash
```

## Incremental Database Processing

### Record-by-Record Loading
```r3
loaddb-i     | "filename" --                 // Load next record incrementally
prevdb-i     | "filename" --                 // Move to previous record
dbfld        | field_index -- "field_data"  // Get field from current record
```

The incremental system maintains position state in `.now` files, enabling processing of large databases without loading everything into memory.

## Complete Usage Examples

### User Database System
```r3
#user-db

:load-user-database
    "data/users.db" loaddb 'user-db ! ;

:find-user-by-id | user-id -- user-record/0
    user-db getdbrow ;

:get-user-name | user-record -- "name"
    0 swap getdbfld ;               // First field is name

:get-user-age | user-record -- age
    1 swap getdbfld str>nro drop ; // Second field is age

:list-all-users
    user-db cntdbrow
    0 ( over <? 
        dup user-db getdbrow       // Get user record
        dup get-user-name print " - Age: " print
        get-user-age .print cr
        1+
    ) 2drop ;

load-user-database
list-all-users
```

### Configuration File Processing
```r3
#config-data * 1024

:process-config-record | record --
    dup 0 swap getdbfld            // Get setting name
    over 1 swap getdbfld           // Get setting value
    "Setting: " print print " = " print print cr ;

:load-configuration
    "config/settings.db" loaddb
    dup cntdbrow
    0 ( over <?
        dup pick3 getdbrow process-config-record
        1+
    ) 2drop drop ;
```

### Incremental Log Processing
```r3
#log-entry * 256

:process-log-entry
    0 dbfld                        // Timestamp field
    "Timestamp: " print print cr
    
    1 dbfld                        // Event type field  
    "Event: " print print cr
    
    2 dbfld                        // Message field
    "Message: " print print cr cr ;

:process-log-file
    "logs/system.db"
    
    ( loaddb-i                     // Try to load next record
        process-log-entry
    ) ;                            // Continue until no more records

process-log-file
```

### Data Export System
```r3
:export-to-csv | "input.db" "output.csv" --
    over loaddb >r                 // Load source database
    fopen dup >r                   // Open output file
    
    r@ cntdbrow 0 ( over <?        // For each record
        dup r@ getdbrow            // Get record
        
        | Export all fields as CSV
        0 ( field-count <?
            dup pick2 getdbfld     // Get field
            r> over fprint         // Write to file
            dup field-count 1- <>? ( "," r@ fprint ) drop
            1+
        ) drop
        
        "\n" r@ fprint            // End of record
        1+
    ) 3drop
    
    r> fclose r> drop ;            // Close file

"users.db" "users.csv" export-to-csv
```

### Database Search and Filter
```r3
:search-users-by-age | min-age max-age --
    user-db cntdbrow 0 ( over <?
        dup user-db getdbrow       // Get record
        dup get-user-age           // Get age
        
        pick4 pick4 between? (     // Age in range?
            dup get-user-name print
            " (Age: " print get-user-age .print ")" print cr
        ; ) drop
        
        1+
    ) 2drop 2drop ;

25 35 search-users-by-age          // Find users aged 25-35
```

### Database Merge Utility
```r3
:merge-databases | "db1" "db2" "output" --
    >r >r >r                       // Store filenames
    
    r@ loaddb >r                   // Load first database
    r@ loaddb >r                   // Load second database  
    
    r> fopen >r                    // Open output file
    
    | Copy records from first database
    r@ cntdbrow 0 ( over <?
        dup r@ getdbrow copy-record-to-file
        1+
    ) 2drop
    
    | Copy records from second database
    r> cntdbrow 0 ( over <?
        dup over getdbrow copy-record-to-file
        1+
    ) 3drop
    
    r> fclose ;                    // Close output

"users1.db" "users2.db" "merged.db" merge-databases
```

### Validation and Cleanup
```r3
:validate-record | record -- valid?
    | Check required fields are present
    dup 0 swap getdbfld count 0? ( drop 0 ; )    // Name required
    dup 1 swap getdbfld isNro 0? ( drop 0 ; )    // Age must be number
    drop 1 ;                                      // Valid record

:clean-database | "input" "output" --
    over loaddb >r                 // Load source
    fopen >r                       // Open output
    
    r@ cntdbrow 0 ( over <?
        dup r@ getdbrow            // Get record
        dup validate-record (      // If valid
            copy-record-to-output
        ; ) drop
        1+
    ) 2drop
    
    r> fclose r> drop ;

"messy.db" "clean.db" clean-database
```

## Performance Characteristics

### Memory Usage
- **Static loading**: Entire database in memory (fast access)
- **Incremental loading**: Single record in memory (low memory usage)
- **Field storage**: Temporary buffers for current record processing

### Access Patterns
- **Sequential access**: Optimal for full table scans
- **Random access**: Requires record index calculation
- **Search operations**: Linear search through records

### File I/O
- **Batch operations**: Load entire files for multiple operations
- **Streaming**: Process large files incrementally
- **State persistence**: Position tracking in `.now` files

## Best Practices

1. **File Organization**: Use consistent naming and directory structure
2. **Field Design**: Keep fields simple and avoid complex nesting
3. **Memory Management**: Use incremental loading for large datasets
4. **Validation**: Always validate data when loading from external sources
5. **Backup Strategy**: Maintain backup copies of important databases

## Integration Patterns

### With File System
```r3
:backup-database | "source" --
    dup ".bak" + swap loaddb save ;
```

### With User Interface
```r3
:display-record | record --
    | Format record for UI display
    format-user-info
    ui-display-text ;
```

This database system provides a simple yet effective solution for applications requiring structured data persistence without the complexity of full database engines, maintaining R3's philosophy of predictable performance and minimal dependencies.