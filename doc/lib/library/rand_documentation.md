# R3 Random Number Generator Library Documentation

## Overview

`rand.r3` provides multiple high-quality pseudo-random number generators (PRNGs) for R3, each optimized for different use cases. The library includes simple 8-bit generators, fast linear congruential generators, XorShift variants, and advanced generators like LoopMix128.

## Generator Types

### 1. Simple 8-bit Generator
Fast, lightweight generator for basic random byte generation.

### 2. Linear Congruential Generator (LCG) 
High-performance 64-bit generator using multiply-add operations.

### 3. XorShift Generators
Fast generators using XOR and bit-shift operations with good statistical properties.

### 4. LoopMix128
Advanced generator with excellent statistical properties and long period.

## 8-Bit Random Generator

### State Variable
```r3
#seed8 12345              // 8-bit generator seed
```

### Functions
```r3
rand8     | -- r8         // Generate 8-bit random number (0-255)
```

**Example:**
```r3
rand8                     // Get random byte
255 rand8 *              // Scale to larger range
```

**Use Cases:**
- Color component generation
- Simple probability tests
- Lightweight applications

## Linear Congruential Generator (LCG)

### State Variable
```r3
#seed $a3b195354a39b70d  // 64-bit LCG seed
```

### Functions
```r3
rerand    | s1 s2 --      // Reseed generator with two values
rand      | -- rand       // Generate 64-bit random number
randmax   | max -- rand   // Generate random in range [0, max)
randminmax| min max -- rand // Generate random in range [min, max)
```

**Examples:**
```r3
12345 67890 rerand        // Seed with two values
rand                      // Get full 64-bit random
100 randmax              // Random 0-99
50 150 randminmax        // Random 50-149
```

**Characteristics:**
- **Speed**: Very fast generation
- **Period**: 2^64 
- **Quality**: Good for most applications
- **Memory**: Single 64-bit state

## XorShift Generator

### State Variable
```r3
#seed $a3b195354a39b70d  // XorShift seed (reuses LCG seed)
```

### Functions
```r3
rnd       | -- rand       // Generate 64-bit XorShift random
rndmax    | max -- rand   // Generate random in range [0, max)
rndminmax | min max -- rand // Generate random in range [min, max)
```

**Examples:**
```r3
rnd                       // Get XorShift random number
dice rndmax 1 +          // Roll die (1-6)
-10 10 rndminmax         // Random between -10 and 10
```

**Characteristics:**
- **Speed**: Extremely fast
- **Period**: 2^64 - 1
- **Quality**: Excellent statistical properties
- **Memory**: Single 64-bit state

## XorShift128+ Generator

### State Variables
```r3
#state0 1                 // First 64-bit state
#state1 2                 // Second 64-bit state
```

### Functions
```r3
rnd128    | -- n          // Generate XorShift128+ random number
```

**Example:**
```r3
rnd128                    // Get 128+ random number
```

**Characteristics:**
- **Speed**: Very fast
- **Period**: 2^128 - 1
- **Quality**: Superior statistical properties
- **Memory**: Two 64-bit states
- **Use**: High-quality applications requiring long period

## LoopMix128 Generator

### State Variables
```r3
#fast_loop $DEADBEEF12345678    // Fast loop state
#slow_loop $ABCDEF0123456789    // Slow loop state  
#mix       $123456789ABCDEF     // Mix state
```

### Constants
```r3
GR $9e3779b97f4a7c15     // Golden ratio constant
```

### Functions
```r3
loopMix128 | -- rand     // Generate LoopMix128 random number
rotLeft5   | x -- v      // Rotate left by 5 bits
rotLeft47  | x -- v      // Rotate left by 47 bits
```

**Example:**
```r3
loopMix128               // Get high-quality random number
```

**Characteristics:**
- **Speed**: Moderate (more complex than XorShift)
- **Period**: Extremely long
- **Quality**: Cryptographically strong
- **Memory**: Three 64-bit states
- **Use**: Applications requiring highest quality randomness

## Usage Examples

### Game Development

#### Random Enemy Spawning
```r3
:spawn-enemy
    | Random position
    800 randmax 'enemy-x !     // X: 0-799
    600 randmax 'enemy-y !     // Y: 0-599
    
    | Random type (0-2)
    3 randmax 'enemy-type !
    
    | Random health (50-100)
    50 100 randminmax 'enemy-health ! ;
```

#### Procedural Content
```r3
:generate-terrain | --
    1000 ( 1? 1-
        rand8 4 >>           // 0-15 height
        over + c!            // Store height
        1+
    ) drop ;
```

### Probability Systems

#### Weighted Random Selection
```r3
#drop-table | item probabilities (out of 1000)
500 300 150 50 0    // Common, uncommon, rare, epic

:random-drop | -- item-type
    1000 randmax               // Random 0-999
    'drop-table ( @+           // Check each probability
        over <=? ( nip 'drop-table - 2 >> nip ; )
        - ) 2drop
    4 ;                        // Default to last item
```

#### Critical Hit System
```r3
:critical-chance | chance -- hit?
    100 randmax < ;            // True if random < chance

:calculate-damage | base-damage crit-chance --
    swap
    over critical-chance? ( 2* ) 
    nip ;

| Usage:
50 25 calculate-damage         // 50 damage, 25% crit chance
```

### Simulation and Testing

#### Monte Carlo Estimation
```r3
:estimate-pi | samples -- pi-estimate
    0 swap ( 1? 1-
        2.0 rndminmax 1.0 -    // Random -1 to 1
        dup dup *. 
        2.0 rndminmax 1.0 -    // Random -1 to 1  
        dup *. + 
        1.0 <=? ( swap 1+ swap )
        drop
    ) drop
    4 * ;

10000 estimate-pi              // Estimate π with 10000 samples
```

#### Noise Generation
```r3
:noise-1d | x -- noise
    100 * int.                 // Scale to integer
    dup 'seed !                // Use as seed
    rand                       // Generate noise
    $7fffffff and              // Make positive
    2147483647.0 /.           // Normalize to 0-1
    2.0 *. 1.0 - ;            // Scale to -1 to 1

:perlin-like | x octaves -- noise
    0.0 1.0 rot ( 1? 1-        // sum amplitude octaves
        -rot pick2 over noise-1d *. rot + swap
        2.0 *. swap 0.5 *. swap
    ) 2drop ;
```

## Generator Selection Guide

### Choose `rand8` for:
- Color generation
- Simple probability checks
- Memory-constrained applications
- Non-critical randomness

### Choose `rand/randmax` for:
- General game development
- UI effects and animations  
- Basic simulations
- Good balance of speed/quality

### Choose `rnd/rndmax` for:
- High-performance applications
- Graphics and visual effects
- Physics simulations
- When quality matters

### Choose `rnd128` for:
- Long-running simulations
- Procedural generation
- Applications needing very long period
- Statistical analysis

### Choose `loopMix128` for:
- Cryptographic applications
- High-security random numbers
- Critical simulations
- When maximum quality is required

## Seeding Best Practices

### Time-based Seeding
```r3
:seed-from-time
    msec dup 32 >> rerand ;    // Use system time
```

### Multi-source Seeding
```r3
:secure-seed
    msec                       // Time
    here                       // Memory address
    rerand ;                   // Combine sources
```

### Deterministic Seeding
```r3
:level-seed | level-number --
    12345 + dup 7 << rerand ; // Reproducible per level
```

## Performance Comparison

| Generator | Speed | Quality | Period | Memory | Use Case |
|-----------|--------|---------|--------|---------|-----------|
| rand8     | ★★★★★ | ★★☆☆☆ | 2^8    | 4 bytes | Simple/Fast |
| rand      | ★★★★☆ | ★★★☆☆ | 2^64   | 8 bytes | General |
| rnd       | ★★★★★ | ★★★★☆ | 2^64-1 | 8 bytes | High Performance |
| rnd128    | ★★★★☆ | ★★★★★ | 2^128-1| 16 bytes| Long Period |
| loopMix128| ★★★☆☆ | ★★★★★ | Huge   | 24 bytes| Maximum Quality |

## Thread Safety Note

These generators use global state variables and are **not thread-safe**. For multi-threaded applications:

1. Use separate generator instances per thread
2. Add synchronization mechanisms
3. Consider thread-local storage for state variables

This random number library provides excellent coverage from simple byte generation to cryptographically strong randomness, suitable for any application requiring pseudo-random numbers.