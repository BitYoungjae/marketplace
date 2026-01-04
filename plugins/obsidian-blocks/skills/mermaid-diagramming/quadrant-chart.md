# Quadrant Chart Reference

Complete guide for Mermaid quadrant charts in Obsidian.

---

## Basic Syntax

A quadrant chart plots data points on a two-dimensional grid divided into four quadrants. Each point represents a data item with x and y coordinates.

### Simple Example

```mermaid
quadrantChart
    x-axis Low --> High
    y-axis Low --> High
    Slow & Cheap: [0.2, 0.3]
    Fast & Expensive: [0.8, 0.7]
    Slow & Expensive: [0.2, 0.8]
    Fast & Cheap: [0.8, 0.3]
```

### Basic Syntax Components

| Component | Syntax | Example |
|-----------|--------|---------|
| Chart type | `quadrantChart` | Start of diagram |
| X-axis | `x-axis Label --> Label` | `x-axis Low --> High` |
| Y-axis | `y-axis Label --> Label` | `y-axis Poor --> Good` |
| Point | `Name: [x, y]` | `Point A: [0.5, 0.7]` |
| Coordinates | `[x, y]` | Range 0.0 to 1.0 |

---

## Axis Configuration

### Basic Axis Labels

```mermaid
quadrantChart
    x-axis Cost --> Benefit
    y-axis Effort --> Impact
    Low Cost: [0.3, 0.2]
    High Impact: [0.8, 0.9]
```

### Custom Axis Text

```mermaid
quadrantChart
    x-axis Low Complexity --> High Complexity
    y-axis Low Risk --> High Risk
    Simple & Safe: [0.2, 0.2]
    Complex & Risky: [0.9, 0.9]
```

---

## Quadrant Structure

The chart is automatically divided into four quadrants:

| Quadrant | Position | Coordinates |
|----------|----------|-------------|
| Quadrant 1 | Top-Right | x > 0.5, y > 0.5 |
| Quadrant 2 | Top-Left | x < 0.5, y > 0.5 |
| Quadrant 3 | Bottom-Left | x < 0.5, y < 0.5 |
| Quadrant 4 | Bottom-Right | x > 0.5, y < 0.5 |

### Understanding Quadrants

```mermaid
quadrantChart
    x-axis Low --> High
    y-axis Low --> High
    Q2 Low-High: [0.3, 0.8]
    Q1 High-High: [0.7, 0.8]
    Q3 Low-Low: [0.3, 0.2]
    Q4 High-Low: [0.7, 0.2]
```

---

## Practical Examples

### Example 1: Feature Prioritization Matrix

```mermaid
quadrantChart
    title Feature Prioritization
    x-axis Effort --> Value
    y-axis Complexity --> Impact
    Dark Mode: [0.4, 0.7]
    Search: [0.6, 0.8]
    Export PDF: [0.7, 0.6]
    Fix UI Bug: [0.2, 0.3]
    API Redesign: [0.9, 0.9]
    Performance: [0.8, 0.7]
```

### Example 2: Risk Assessment Matrix

```mermaid
quadrantChart
    title Risk Assessment
    x-axis Probability --> Probability
    y-axis Impact --> Impact
    Mild Bug: [0.3, 0.2]
    Server Outage: [0.4, 0.95]
    Data Loss: [0.2, 0.99]
    Minor Typo: [0.8, 0.1]
    Security Breach: [0.3, 0.99]
```

### Example 3: Investment Portfolio

```mermaid
quadrantChart
    title Investment Strategy
    x-axis Conservative --> Aggressive
    y-axis Low Return --> High Return
    Bonds: [0.2, 0.3]
    Savings: [0.1, 0.2]
    Growth Stocks: [0.8, 0.85]
    Tech Startups: [0.9, 0.95]
    Index Funds: [0.5, 0.6]
    Real Estate: [0.6, 0.65]
```

### Example 4: Time vs Quality Matrix

```mermaid
quadrantChart
    title Project Delivery Quadrant
    x-axis Quick --> Time-Consuming
    y-axis Low Quality --> High Quality
    MVP Release: [0.3, 0.4]
    Full Feature: [0.8, 0.9]
    Quick Patch: [0.1, 0.2]
    Refactored Code: [0.7, 0.95]
    Spike Research: [0.4, 0.5]
```

---

## Point Naming Conventions

### Short Names

Simple, concise labels for clarity:

```mermaid
quadrantChart
    x-axis Low --> High
    y-axis Low --> High
    A: [0.2, 0.3]
    B: [0.5, 0.5]
    C: [0.8, 0.8]
```

### Descriptive Names

Full descriptions for context:

```mermaid
quadrantChart
    x-axis Time Required --> Time Required
    y-axis Business Value --> Business Value
    "User Authentication": [0.4, 0.9]
    "Dark Mode Toggle": [0.2, 0.5]
    "Database Optimization": [0.7, 0.8]
    "Fix Typo": [0.1, 0.1]
```

### Names with Special Characters

Use quotes for names with spaces or special characters:

```mermaid
quadrantChart
    x-axis Cost --> Cost
    y-axis Benefit --> Benefit
    "High ROI": [0.8, 0.9]
    "Low Cost/High Benefit": [0.3, 0.8]
    "No Impact": [0.5, 0.2]
```

---

## Advanced Features

### Title and Labels

```mermaid
quadrantChart
    title Eisenhower Matrix
    x-axis Urgent --> Not Urgent
    y-axis Important --> Not Important
    Crisis: [0.1, 0.9]
    Planning: [0.7, 0.8]
    Distractions: [0.1, 0.2]
    Timewasters: [0.8, 0.1]
```

### Multiple Points in Same Quadrant

```mermaid
quadrantChart
    x-axis Complexity --> Complexity
    y-axis Value --> Value
    Feature A: [0.6, 0.7]
    Feature B: [0.65, 0.75]
    Feature C: [0.7, 0.72]
    Quick Win: [0.3, 0.8]
    Tech Debt: [0.8, 0.2]
```

### Dense Data Visualization

```mermaid
quadrantChart
    title Technology Stack Evaluation
    x-axis Learning Curve --> Learning Curve
    y-axis Performance --> Performance
    Python: [0.3, 0.7]
    Rust: [0.8, 0.95]
    JavaScript: [0.2, 0.6]
    Go: [0.5, 0.9]
    Java: [0.6, 0.85]
    Ruby: [0.25, 0.65]
```

---

## Obsidian Notes

**Theme Compatibility**: Quadrant colors adapt to Obsidian theme. Use custom styling in Obsidian CSS if consistent colors are needed across themes.

**Performance**: Large datasets (50+ points) render smoothly, but very dense clustering may reduce readability.

**Export**: PDF export renders quadrant charts as images. For external sharing, capture as PNG/SVG.

**Coordinate Range**: Coordinates must be between 0.0 and 1.0. Values outside this range may not display.

**Axis Labels**: Keep axis labels concise (2-3 words) for clarity.

**Code Block Format**:
````
```mermaid
quadrantChart
    x-axis Low --> High
    y-axis Low --> High
    Point: [0.5, 0.5]
```
````

---

## Quick Reference Table

| Concept | Syntax | Example |
|---------|--------|---------|
| Chart type | `quadrantChart` | Start diagram |
| Title | `title text` | `title My Chart` |
| X-axis | `x-axis left --> right` | `x-axis Low --> High` |
| Y-axis | `y-axis bottom --> top` | `y-axis Poor --> Good` |
| Data point | `Name: [x, y]` | `Point A: [0.5, 0.7]` |
| X coordinate | Number 0.0-1.0 | `[0.5, y]` |
| Y coordinate | Number 0.0-1.0 | `[x, 0.5]` |
| Spacing | Empty lines allowed | Between sections |
| Comments | `%%` | `%% note` |
