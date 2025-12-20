# R3Forth Random Number Library (rand.r3)

A collection of pseudo-random number generators (PRNGs) for R3Forth, offering various algorithms with different characteristics for speed, quality, and period length.

## Overview

This library provides four different random number generators:
- **8-bit PRNG** - Simple, fast, short period
- **MulAdd** - Linear Congruential Generator (LCG)
- **Xorshift** - Fast, good quality, medium period
- **Xorshift128+** - High quality, long period
- **LoopMix128** - Advanced PRNG with excellent statistical properties

---

## 8-bit Random Number Generator

A simple PRNG suitable for games and non-cryptographic purposes.

### Functions

- **`rand8`** `( -- r8 )` - Generate 8-bit random number (0-255)
  ```r3forth
  rand8  | Returns value 0-255
  ```
  - Uses simple shift and XOR operations
  - Fast but short period
  - Good for basic randomness needs

### Seed

- **`seed8`** - 8-bit generator seed (default: 12345)
  ```r3forth
  42 'seed8 !  | Set custom seed
  ```

---

## MulAdd Generator (Linear Congruential)

A classic Linear Congruential Generator with full 64-bit output.

### Seed Management

- **`seed`** - Main generator seed (default: `$a3b195354a39b70d`)

- **`rerand`** `( s1 s2 -- )` - Reseed generator with two values
  ```r3forth
  msec date rerand  | Seed with time and date
  ```
  - Combines two values for seed
  - Use different sources for better randomness

### Random Functions

- **`rand`** `( -- rand )` - Generate 64-bit random number
  ```r3forth
  rand  | Full 64-bit signed integer
  ```
  - Full range: -9223372036854775808 to 9223372036854775807
  - Uses multiply-add algorithm

- **`randmax`** `( max -- rand )` - Generate random number 0 to max
  ```r3forth
  100 randmax  | Returns 0-99
  ```
  - Result is always positive
  - Inclusive range: [0, max-1]

- **`randminmax`** `( min max -- rand )` - Generate random in range
  ```r3forth
  10 50 randminmax  | Returns 10-49
  ```
  - Inclusive range: [min, max-1]

---

## Xorshift Generator

Fast and high-quality PRNG using XOR and shift operations.

### Functions

- **`rnd`** `( -- rand )` - Generate 64-bit random number
  ```r3forth
  rnd  | Full 64-bit signed integer
  ```
  - Uses xorshift algorithm
  - Better quality than LCG
  - Same seed as `rand` functions

- **`rndmax`** `( max -- rand )` - Generate random 0 to max
  ```r3forth
  1000 rndmax  | Returns 0-999
  ```

- **`rndminmax`** `( min max -- rand )` - Generate random in range
  ```r3forth
  -10 11 rndminmax  | Returns -10 to 10
  ```

**Note:** Xorshift uses the same `seed` variable as MulAdd generator.

---

## Xorshift128+ Generator

High-quality PRNG with very long period (2^128 - 1).

### State Variables

- **`state0`** - First state variable (default: 1)
- **`state1`** - Second state variable (default: 2)

### Functions

- **`rnd128`** `( -- n )` - Generate 64-bit random number
  ```r3forth
  rnd128  | High-quality random number
  ```
  - Period: 2^128 - 1
  - Excellent statistical properties
  - Suitable for Monte Carlo simulations
  - Passes most statistical tests

### Seeding

```r3forth
| Custom seed
12345 'state0 !
67890 'state1 !
```

**Important:** Both states must be non-zero. Never set both to 0.

---

## LoopMix128 Generator

Advanced PRNG with excellent statistical properties and long period.

### State Variables

- **`fast_loop`** - Fast loop state (default: `$DEADBEEF12345678`)
- **`slow_loop`** - Slow loop state (default: `$ABCDEF0123456789`)
- **`mix`** - Mix state (default: `$123456789ABCDEF`)

### Functions

- **`loopMix128`** `( -- rand )` - Generate 64-bit random number
  ```r3forth
  loopMix128  | Highest quality random
  ```
  - Uses rotation and mixing operations
  - Excellent uniformity
  - Long period
  - Based on Daniel Cota's LoopMix128 algorithm
  - Best choice for serious statistical applications

### Seeding

```r3forth
| Initialize with three values
msec 'fast_loop !
date 'slow_loop !
time 'mix !
```

---

## Comparison of Generators

| Generator | Speed | Quality | Period | Use Case |
|-----------|-------|---------|--------|----------|
| **rand8** | Fastest | Low | Short | Games, simple random |
| **rand (MulAdd)** | Fast | Medium | 2^64 | General purpose |
| **rnd (Xorshift)** | Fast | Good | 2^64-1 | General purpose, better quality |
| **rnd128** | Medium | Excellent | 2^128-1 | Simulations, scientific |
| **loopMix128** | Medium | Excellent | Very long | Statistical applications |

---

## Usage Examples

### Dice Roll
```r3forth
:roll-dice | -- n
  6 randmax 1+ ;  | Returns 1-6

roll-dice "You rolled: %d" .print
```

### Random Color
```r3forth
:random-color | -- r g b
  256 rndmax
  256 rndmax
  256 rndmax ;

random-color .fgrgb "Colored text" .print
```

### Random Choice
```r3forth
:random-choice | n -- choice
  randmax
  0 =? ( drop "Option A" ; )
  1 =? ( drop "Option B" ; )
  2 =? ( drop "Option C" ; )
  drop "Option D" ;

4 random-choice .print
```

### Shuffle Array
```r3forth
#deck * 53

:chg | a b -- 
	over c@ over c@ | a b a@ b@
	swap rot c! 	| a b@
	swap c! ;
		
:shuffle
	'deck 1+ >a
	0 ( 52 <?
		dup randmax | n rand
		a> + over a> + chg
		1+ ) drop ;

shuffle
```

### Monte Carlo Pi Estimation
```r3forth
:estimate-pi | samples -- pi
  0 over | hits samples
  ( 1? 1-
    rnd128 abs 1.0 mod  | Random x (0-1)
    rnd128 abs 1.0 mod  | Random y (0-1)
    dup *. swap dup *. +  | x² + y²
    1.0 <? ( rot 1+ -rot )  | Inside circle?
    drop ) drop
  1.0 * swap /.  | hits * 1.0 / samples
  4.0 *. ;       | * 4 for full circle

1000000 estimate-pi  | ~3.14159...
```

### Random Walk
```r3forth
#x 0 #y 0

:random-step
  -1 2 rndmax 'x +!
  -1 2 rndmax 'y +!
  ;

:walk | steps --
  ( 1? 1-
    random-step
    x y .at "*" .print
    50 ms
  ) drop ;

100 walk
```

### Weighted Random
```r3forth
:weighted-random | -- nro choice
  100 randmax
  50 <? ( "Common" ; )   | 50% chance
  80 <? ( "Uncommon" ; ) | 30% chance
  95 <? ( "Rare" ; )     | 15% chance
  "Legendary" ;          | 5% chance

weighted-random "%s %d" .print 
```

### Random Password
```r3forth
#charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

:random-char | -- char
  charset count 1- randmax
  charset + c@ ;

:random-password | len --
  mark
  ( 1? 1-
    random-char ,c
  ) drop
  ,eol 
  empty here ;

12 random-password .print  | Generate 12-char password
```

### Gaussian Distribution (Box-Muller)
```r3forth
:gaussian | -- value
  | Box-Muller transform for normal distribution
  rnd128 abs 1.0 mod 0.0001 +  | u1 (avoid log(0))
  rnd128 abs 1.0 mod  | u2
  
  *. cos  | cos(u2)
  swap ln. -2.0 *. sqrt.  | sqrt(-2 * ln(u1))
  *. ;  | multiply

| Generate 1000 values with mean=0, std=1
1000 ( 1? 1-
  gaussian  | Value from standard normal
  | ... process value ...
) drop
```

### Random Terrain Generation
```r3forth
:random-terrain | x y -- type
  + seed8 xor 'seed8 !  | Mix coordinates with seed
  rand8
  128 <? ( "grass" ; )
  192 <? ( "forest" ; )
  224 <? ( "mountain" ; )
  "water" ;

10 5 random-terrain .print drop | Get terrain at (10,5)
```

---

## Best Practices

1. **Seed with time/date for unpredictability**
   ```r3forth
   msec date rerand  | Good initialization
   ```

2. **Choose appropriate generator**
   - Games/graphics: `rand` or `rnd`
   - Simulations: `rnd128` or `loopMix128`
   - Quick random: `rand8`

3. **Don't reseed too frequently**
   ```r3forth
   | Bad: reseeding in loop
   ( msec rerand rand ... )
   
   | Good: seed once at start
   msec date rerand
   ( rand ... )
   ```

4. **Use range functions when possible**
   ```r3forth
   | Good
   1 6 randminmax  | Dice roll
   
   | Avoid
   rand 6 mod 1+   | Biased for large ranges
   ```

5. **Check for zero states in rnd128**
   ```r3forth
   state0 0? ( 1 'state0 ! )
   state1 0? ( 2 'state1 ! )
   ```

---

## Statistical Quality Notes

### Period Length

- **rand8:** ~256 (very short)
- **rand (LCG):** 2^64
- **rnd (Xorshift):** 2^64 - 1
- **rnd128:** 2^128 - 1 (very long)
- **loopMix128:** Implementation dependent (very long)

### Distribution Quality

All generators except `rand8` produce uniform distributions suitable for:
- Games and entertainment
- Procedural generation
- Basic statistical sampling
- Simulations

For cryptographic purposes, none of these generators are suitable. Use OS-provided cryptographic RNGs instead.

---

## Common Patterns

### Random Boolean
```r3forth
:coin-flip | -- 1/0
  2 randmax ;

coin-flip 1? ( "Heads" ; ) "Tails" ;
```

### Random Element from Array
```r3forth
:random-element | array count -- element
  randmax 8 * + @ ;

'colors 4 random-element
```

### Random fixed point (0.0-1.0)
```r3forth
:random-fix | -- f
	1.0 randmax ;

random-fix  | Returns 0.0 to 1.0)
```

### Probability Check
```r3forth
:chance? | percent -- 1/0
  100 randmax <? ( 1 nip ; ) 0 nip ;

75 chance? 1? ( "Success!" .print ; )
```

---

## Performance Tips

1. **Cache random values when possible**
   ```r3forth
   | Generate batch of randoms
   100 ( 1? 1- rand 'table over + ! ) drop
   ```

2. **Use faster generators for non-critical randomness**
   ```r3forth
   | Visual effects
   rand8  | Fast enough
   
   | Physics simulation
   rnd128  | Better quality needed
   ```

3. **Avoid modulo for small ranges**
   ```r3forth
   | Better
   10 randmax
   
   | Slower
   rand abs 10 mod
   ```

---

## Notes

- **Thread safety:** Not thread-safe (uses global state)
- **Deterministic:** Same seed produces same sequence
- **Not cryptographic:** Don't use for security purposes
- **Seeding:** Better seeds = better randomness
- **Range functions:** Automatically handle sign conversion
- **Zero state:** Never set all state variables to zero
- **Bias:** `randmax`/`rndmax` have negligible bias for most ranges

---

## Algorithm References

- **LCG:** Classic Numerical Recipes parameters
- **Xorshift:** George Marsaglia (2003)
- **Xorshift128+:** Sebastiano Vigna (2014)
- **LoopMix128:** Daniel Cota's design

For more information, see:
- [Random Number Generation (Wikipedia)](https://en.wikipedia.org/wiki/Random_number_generation)
- [Xorshift on Wikipedia](https://en.wikipedia.org/wiki/Xorshift)
- [LoopMix128 on GitHub](https://github.com/danielcota/LoopMix128)