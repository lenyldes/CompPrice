## ADDED Requirements

### Requirement: Add product to comparison list

The system SHALL allow the user to add a product to the comparison list by entering a price (in rubles) and a quantity, then activating the "Add" action.

The system SHALL accept decimal numbers using either `.` or `,` as the decimal separator and SHALL parse `,` as equivalent to `.` before computation.

The system SHALL reject input that does not parse to a finite number, that has a price less than 0, or that has a quantity less than or equal to 0. While input is invalid, the system SHALL NOT add a product to the list.

#### Scenario: Add a valid product

- **WHEN** the user enters a price of `90` and a quantity of `0.9` and activates "Add"
- **THEN** the system appends a new product to the list with price `90`, quantity `0.9`, and an auto-generated name
- **AND** the system clears the input fields ready for the next entry

#### Scenario: Add a product with comma decimal separator

- **WHEN** the user enters a price of `149,90` and a quantity of `1,5` and activates "Add"
- **THEN** the system parses the values as `149.90` and `1.5` and appends the product to the list

#### Scenario: Reject zero quantity

- **WHEN** the user enters a price of `100` and a quantity of `0`
- **THEN** the system does not add a product to the list and the "Add" action is unavailable or surfaces an inline error

#### Scenario: Reject non-numeric input

- **WHEN** the user enters a price of `abc` or a quantity of `--`
- **THEN** the system does not add a product and the "Add" action is unavailable or surfaces an inline error

### Requirement: Auto-generate stable product names

The system SHALL auto-name each added product as `Product N`, where `N` is a monotonically increasing counter that starts at 1 and never reuses a value, even after deletions.

#### Scenario: Sequential naming

- **WHEN** the user adds three products in succession
- **THEN** the system names them `Product 1`, `Product 2`, and `Product 3` in insertion order

#### Scenario: Deleted names are not reused

- **WHEN** the user has added `Product 1`, `Product 2`, and `Product 3`, deletes `Product 2`, and then adds another product
- **THEN** the new product is named `Product 4` and no entry is renamed

### Requirement: Display unit price for each product

The system SHALL compute the unit price of each product as `price / quantity` and SHALL display it rounded to two decimal places.

The system SHALL preserve the unrounded `double` value internally for comparison purposes.

#### Scenario: Display rounded unit price

- **WHEN** the list contains a product with price `149.90` and quantity `1.5`
- **THEN** the row for that product displays a unit price of `99.93`

#### Scenario: Internal precision preserved for comparison

- **WHEN** two products would round to the same displayed unit price but differ in their underlying `double` values
- **THEN** the system uses the underlying values (not the displayed strings) when determining which product has the lowest unit price

### Requirement: List products in insertion order

The system SHALL display products in the order they were added, with the most recently added product at the bottom of the list. The system SHALL NOT reorder the list based on price or any other attribute.

#### Scenario: Insertion order preserved

- **WHEN** the user adds products A, B, then C
- **THEN** the list displays them top-to-bottom as A, B, C regardless of their unit prices

### Requirement: Highlight the lowest unit price

The system SHALL visually highlight the product or products with the lowest unit price in the list, independent of list position.

If multiple products share the lowest unit price (compared as `double`s), the system SHALL highlight all of them.

If the list is empty, the system SHALL highlight nothing.

#### Scenario: Single cheapest product

- **WHEN** the list contains products with unit prices `100.00`, `99.93`, and `120.00`
- **THEN** only the row with unit price `99.93` is visually highlighted

#### Scenario: Tie at the minimum

- **WHEN** the list contains two products that both compute to a unit price of `50.0` and one product at `60.0`
- **THEN** both `50.0` rows are highlighted and the `60.0` row is not

#### Scenario: Empty list

- **WHEN** the list is empty
- **THEN** no row is highlighted (because there are no rows to highlight)

#### Scenario: Highlight updates after add

- **WHEN** a new product is added whose unit price is lower than every existing product's unit price
- **THEN** the new product becomes the highlighted row and any previously highlighted row is no longer highlighted

#### Scenario: Highlight updates after delete

- **WHEN** the currently highlighted product is deleted
- **THEN** the system recomputes and highlights the row(s) with the now-lowest unit price among the remaining products

### Requirement: Delete a product from the list

The system SHALL provide a per-row delete control (e.g., a trash icon) that removes that product from the list when activated.

The system SHALL NOT require a confirmation step before deletion.

The system SHALL recompute the lowest-unit-price highlight after a deletion.

#### Scenario: Delete a row

- **WHEN** the user activates the delete control on a product's row
- **THEN** that product is removed from the list immediately and remaining products keep their names and positions
