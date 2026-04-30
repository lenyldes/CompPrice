## MODIFIED Requirements

### Requirement: Highlight the lowest unit price

The system SHALL visually highlight the product or products with the lowest unit price in the list, independent of list position.

The highlight SHALL be rendered solely as a light green row background — affirmative in tone — with no leading icon, badge, asterisk, or other textual marker preceding the row content. Foreground text SHALL remain readable against the highlighted background in both light and dark themes.

If multiple products share the lowest unit price (compared as `double`s), the system SHALL highlight all of them.

If the list is empty, the system SHALL highlight nothing.

#### Scenario: Single cheapest product

- **WHEN** the list contains products with unit prices `100.00`, `99.93`, and `120.00`
- **THEN** only the row with unit price `99.93` is visually highlighted with a light green background and no leading icon

#### Scenario: Tie at the minimum

- **WHEN** the list contains two products that both compute to a unit price of `50.0` and one product at `60.0`
- **THEN** both `50.0` rows are highlighted with a light green background and the `60.0` row is not

#### Scenario: Empty list

- **WHEN** the list is empty
- **THEN** no row is highlighted (because there are no rows to highlight)

#### Scenario: Highlight updates after add

- **WHEN** a new product is added whose unit price is lower than every existing product's unit price
- **THEN** the new product becomes the highlighted row and any previously highlighted row is no longer highlighted

#### Scenario: Highlight updates after delete

- **WHEN** the currently highlighted product is deleted
- **THEN** the system recomputes and highlights the row(s) with the now-lowest unit price among the remaining products

#### Scenario: No leading marker on highlighted row

- **WHEN** any row in the list is the lowest-unit-price row
- **THEN** that row displays no leading star, asterisk, or other "best" marker — its highlighted state is conveyed by background color alone
