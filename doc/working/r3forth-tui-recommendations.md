# R3Forth TUI Library - Analysis and Recommendations

## Executive Summary

The TUI library provides a solid foundation for building terminal user interfaces with good architecture and event handling. However, several widgets are incomplete and there are opportunities for enhancement.

---

## Missing Implementations

### 1. **Check Box Widget**

**Status:** Declared but not implemented

**Suggested Implementation:**
```r3forth
#check-state 0  | 0=unchecked, 1=checked

::tuCheck | 'var "label" --
  tuiw
  6 =? ( over dup @ 1 xor swap ! tuX! tuR! )
  drop
  
  fx fy .at
  over @ 1? ( "[X] " ) ( "[ ] " ) .write
  .write
  
  tuif 0? ( drop ; )
  uikey [enter] =? ( 
    dup dup @ 1 xor swap ! tuX! tuR!
  )
  [tab] =? ( focus>> )
  [shift+tab] =? ( focus<< )
  drop ;
```

### 2. **Radio Button Widget**

**Status:** Declared but not implemented

**Suggested Implementation:**
```r3forth
| Radio group: 'var holds selected index (0-n)

::tuRadio | n 'var "label" --
  tuiw
  6 =? ( pick2 pick2 ! tuX! tuR! )
  drop
  
  fx fy .at
  over @ pick2 =? ( "(•) " ) ( "( ) " ) .write
  .write
  
  tuif 0? ( drop ; )
  uikey [enter] =? ( pick2 pick2 ! tuX! tuR! )
  [tab] =? ( focus>> )
  [shift+tab] =? ( focus<< )
  drop ;
```

### 3. **Combo Box / Dropdown**

**Status:** Declared but not implemented

**Concept:**
- Shows selected item
- Expands to show list on click
- Collapses after selection

**Suggested Implementation:**
```r3forth
#combo-expanded? 0

::tuCombo | 'var "list" --
  combo-expanded? 0? (
    | Show selected value
    tuiw
    6 =? ( 1 'combo-expanded? ! tuR! )
    drop
    
    fx fy .at
    over @ uiNindx
    fw 1- swap lwrite "▼" .write
  ) (
    | Show list
    tuList
    tuX? 1? ( 0 'combo-expanded? ! tuR! ) drop
  ) drop ;
```

### 4. **Slider Widget**

**Status:** Declared but not implemented

**Suggested Implementation:**
```r3forth
| 'var: current value
| min max: range

::tuSlider | 'var min max --
  tuiw
  3 =? ( | Dragging
    evtmx fx - fw * 
    pick2 pick2 - /
    pick2 + clamp0
    pick3 !
    tuR!
  )
  drop
  
  fx fy .at
  fw "─" .rep
  
  | Calculate position
  over @ pick3 - fw *
  pick2 pick3 - /
  fx + fy .at "●" .write
  
  2drop ;
```

### 5. **Progress Bar Widget**

**Status:** Declared but not implemented

**Suggested Implementation:**
```r3forth
::tuProgress | percent --
  fx fy .at
  fw over * 100 / "█" .rep
  .Reset ;
```

---

## Critical Issues

### 1. **Input Field UTF-8 Support**

**Problem:** Comment indicates UTF-8 cursor positioning is incomplete
```r3forth
pad> padi> - + | !! falta utf
```

**Impact:** Cursor position incorrect with UTF-8 characters

**Fix:** Use `utf8count` to get character position:
```r3forth
:get-cursor-pos | -- col
  padi> pad> over - utf8count drop ;

:tuInputfoco
  | ...
  fx fy get-cursor-pos fx + fy .at .savec
  | ...
```

### 2. **Frame Stack Overflow**

**Problem:** No bounds checking on frame stack
```r3forth
#flstack * 64 | 8 levels
```

**Impact:** Stack overflow corrupts memory

**Fix:** Add bounds checking:
```r3forth
::flxpush
  flstack> flstack 64 + >=? ( 
    "Frame stack overflow!" print exit 
  )
  fh fw fy fx flstack> w!+ w!+ w!+ w!+ 'flstack> ! ;
```

### 3. **Tree Level Overflow**

**Problem:** Tree level limited to 5 bits (0-31)
```r3forth
$1f and  | Only 5 bits for level
```

**Impact:** Deep trees (>31 levels) won't work

**Recommendation:** Document limitation or use 2-byte format

---

## Design Improvements

### 1. **Widget Return Values Inconsistency**

**Problem:** Some widgets return state, others don't

```r3forth
tuBtn | Returns nothing
tuList | Returns nothing
tuiw | Returns state
```

**Recommendation:** Standardize return values or document clearly

### 2. **Focus Management**

**Current:** Focus changes with Tab/Shift+Tab in each widget

**Improvement:** Add global focus traversal
```r3forth
#focus-list * 64  | List of focusable widgets
#focus-count 0

::tuRegisterFocus | id --
  focus-list focus-count + !
  1 'focus-count +! ;

::tuFocusNext
  | Cycle to next focusable widget
  ;
```

### 3. **Color Theme Support**

**Current:** Each widget uses default colors

**Improvement:** Add theme system
```r3forth
#theme-normal $07
#theme-hover $17
#theme-active $70
#theme-focused $0F

::tuSetTheme | normal hover active focused --
  'theme-focused !
  'theme-active !
  'theme-hover !
  'theme-normal ! ;
```

### 4. **Widget Size Hints**

**Problem:** No way to query minimum widget size

**Addition:**
```r3forth
::tuBtnSize | "text" -- w h
  utf8count 2 + 1 ;

::tuListSize | 'var "list" -- w h
  | Calculate from content
  ;
```

---

## Missing Features

### 1. **Keyboard Shortcuts**

**Need:** Global hotkey system
```r3forth
#hotkeys * 256  | 'callback key

::tuHotkey | 'callback key --
  | Register hotkey
  ;
```

### 2. **Modal Dialogs**

**Need:** Easy message boxes
```r3forth
::tuMsgBox | "title" "message" --
  | Show centered message box
  | Wait for OK button
  ;

::tuConfirm | "title" "question" -- 1/0
  | Show Yes/No dialog
  | Return user choice
  ;
```

### 3. **Scroll Bars**

**Current:** Only list widget has visual scroll indicator

**Need:** Generic scroll bar widget
```r3forth
::tuScrollBar | 'var total visible --
  | Draw scroll bar
  | Handle mouse drag
  ;
```

### 4. **Tooltips**

**Need:** Hover tooltips
```r3forth
::tuTooltip | "text" --
  | Show tooltip on hover
  | Auto-hide after timeout
  ;
```

### 5. **Multi-line Text Input**

**Current:** Only single-line input

**Need:** Text area widget
```r3forth
::tuTextArea | 'buffer maxlines --
  | Multi-line editing
  | Scrolling
  | Line wrapping
  ;
```

### 6. **Menu Bar**

**Need:** Top menu bar widget
```r3forth
::tuMenuBar | "items" --
  | "File|Edit|View|Help"
  | Dropdown submenus
  ;
```

### 7. **Tab Control**

**Need:** Tabbed panels
```r3forth
::tuTabs | 'active "tab1|tab2|tab3" --
  | Switch between panels
  | Visual tab selection
  ;
```

### 8. **Status Bar**

**Need:** Bottom status bar
```r3forth
::tuStatusBar | "left" "center" "right" --
  | Three-section status bar
  ;
```

---

## Performance Optimizations

### 1. **Dirty Rectangles**

**Current:** Full screen redraw

**Improvement:** Track dirty regions
```r3forth
#dirty-regions * 256  | x y w h list

::tuMarkDirty | x y w h --
  | Add to dirty list
  ;
```

### 2. **Double Buffering**

**Current:** Direct terminal output

**Improvement:** Build in memory, then flush
```r3forth
#screen-buffer * 8192

::tuFlush
  | Compare buffers
  | Only update changed cells
  ;
```

### 3. **Widget Caching**

**Current:** Recreate layout every frame

**Improvement:** Cache static widgets
```r3forth
::tuCache | 'widget --
  | Cache rendered widget
  | Invalidate on change
  ;
```

---

## Documentation Gaps

### 1. **Place Codes**

The `.wtitle` place parameter needs documentation:
```
$xy format where x,y ∈ [0-7]

x: 0=left, 1=left+1, 2=right-n, 3=right-n-1, 4=center, 5=right, 6=right-n-fw, 7=0
y: 0=top, 1=top+1, 2=bottom-1, 3=bottom-2, 4=middle, 5=bottom, 6=top-2, 7=0

Common:
$00 = top-left
$01 = top-center  
$05 = top-right
$44 = center
```

### 2. **Event Flow**

Document the event processing order:
1. Mouse events processed first
2. Keyboard events after mouse
3. Focus changes trigger redraws
4. Actions set `tuX?` flag
5. Frame rendered if any changes

### 3. **State Machine**

Document widget state transitions:
```
Normal(0) → Over(1) → In(2) → Active(3) ⇄ Active-Out(4)
                                    ↓
                               Out(5) | Click(6)
```

---

## API Improvements

### 1. **Consistent Naming**

**Current:** Mix of prefixes (tu, flx, .)

**Suggestion:** 
- `tu*` - User-facing widgets
- `flx*` - Frame layout
- `.*` - Drawing primitives
- `tui*` - System functions

### 2. **Error Handling**

**Current:** No error reporting

**Addition:**
```r3forth
#tui-error 0

::tuError? | -- 0/"error"
  tui-error ;

:tuSetError | "msg" --
  'tui-error ! tuR! ;
```

### 3. **Widget State Query**

**Addition:**
```r3forth
::tuGetSelection | 'var -- index
  @ ;

::tuSetSelection | index 'var --
  ! tuR! ;

::tuGetText | 'buffer -- "text"
  ;
```

---

## Testing Recommendations

### 1. **Unit Tests Needed**

- Frame stack operations
- UTF-8 string handling
- List scrolling edge cases
- Tree expand/collapse
- Input field editing

### 2. **Integration Tests**

- Focus traversal
- Modal dialogs
- Nested layouts
- Window switching

### 3. **Performance Tests**

- Large lists (1000+ items)
- Deep trees (20+ levels)
- Rapid redraws
- Memory leaks

---

## Migration Path

### Phase 1: Critical Fixes
1. UTF-8 cursor positioning
2. Frame stack bounds checking
3. Tree level documentation

### Phase 2: Complete Widgets
1. Implement checkbox
2. Implement radio buttons
3. Implement combo box
4. Implement slider
5. Implement progress bar

### Phase 3: Enhancements
1. Theme system
2. Keyboard shortcuts
3. Modal dialogs
4. Scroll bars

### Phase 4: Advanced Features
1. Multi-line text area
2. Menu bar
3. Tab control
4. Status bar

### Phase 5: Optimization
1. Dirty rectangles
2. Double buffering
3. Widget caching

---

## Conclusion

**Strengths:**
- ✅ Solid architecture
- ✅ Good event handling
- ✅ Flexible layout system
- ✅ Working core widgets

**Weaknesses:**
- ❌ Incomplete widgets (5 missing)
- ❌ UTF-8 issues in input
- ❌ No bounds checking
- ❌ Limited documentation

**Priority Actions:**
1. **High:** Fix UTF-8 input cursor
2. **High:** Add frame stack bounds check
3. **Medium:** Implement missing widgets
4. **Medium:** Add theme system
5. **Low:** Performance optimizations

**Overall Assessment:** The library is production-ready for basic UIs but needs completion and polish for advanced use cases. The architecture is sound and extensible.