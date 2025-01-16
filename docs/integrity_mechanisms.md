# Data Validation Guidelines

## Client
- **Email**: Must be properly structured and valid.
- **Birth Date**: Must indicate an individual aged 18 or older.
- **Address**: Must be valid and provided.
- **NIF (Tax Identification Number)**: Must be provided and correctly formatted.
- **Gender**: Must be either "female" or "male."
- **Nationality**: Must be provided.

## Contract
- **Commitment Period**: Must be expressed in years.
- **Start Date**: Must precede the cancellation date and be earlier than the current date.
- **Cancellation Date**: Must be earlier than the current date.
- **Validity Status**: Must align with the cancellation status table.
- **Duration**: Must be a positive value.
- **Valid Field**: Must have a value of either 1 or 0.
- **Start Date**: Must be earlier than the current date.

## Cancellation
- **Cancellation Date**: Must occur after the contract’s start date and be earlier than the current date.
- **Penalty Amount**: Cannot be negative.

## Phone Number
- **Balance**: Cannot be negative.
- **Monthly Minimum Expenses (min_spent)**: Must reset at the end of each month.
- **Monthly SMS Expenses (sms_spent)**: Must reset at the end of each month.

## Call
- **Type**: Must align with the system’s predefined call types.

## SMS
- **Send Date**: Must precede the delivery date and be earlier than the current date.
- **Delivery Date**: Must be earlier than the current date.

## Other Calls
- **Start Date**: Must precede the end date and be earlier than the current date.
- **End Date**: Must be earlier than the current date.

## Voice Call
- **Start Date**: Must precede the end date and be earlier than the current date.
- **End Date**: Must be earlier than the current date.

## Events
- **Start Date**: Must precede the end date and be earlier than the current date.
- **End Date**: Must be earlier than the current date.
- **Status**: Must align with the event categories.

## Group
- **Start Date**: Must precede the end date and be earlier than the current date.
- **End Date**: Must be earlier than the current date.
- **Number of Members (n_members)**: Must be positive.
- **Status**: Must be either 1 or 0.

## Campaign
- **Start Date**: Must precede the end date and be earlier than the current date.
- **End Date**: Must be earlier than the current date.
- **Voice and SMS Discounts (voice_discounts, sms_discounts)**: Cannot exceed 100 (percentage).
- **Maximum Number of Friends (n_max_friends)**: Must be positive.

## Billing Period
- **Start Date**: Must precede the end date and be earlier than the current date.
- **End Date**: Must be earlier than the current date.
- **Date Range**: Must fall within the specified billing period.
- **Value**: Cannot be negative.

## Packages
- **Type**: Must align with the system’s predefined call types.
- **Package Price**: Cannot be negative.
- **Package Quantity**: Cannot be negative.
- **Unit Value**: Cannot be negative.
- **Package Period**: Must be expressed in years.
- **Release Date**: Cannot be later than the current date.

## Tariff
- **Type**: Must align with the system’s predefined call types.
- **Network**: Must align with the system’s supported networks.
- **Unit Type**: Must be consistent with the call type.
- **Unit Value**: Cannot be negative.
- **Release Date**: Cannot be later than the current date.

## Simple Postpaid Plan
- **Release Date**: Cannot be later than the current date.
- **Service Value**: Must be positive.

## Prepaid Plan
- **Days, Minutes, and SMS**: Cannot have negative values.

## Postpaid Plan with Plafond
- **Minutes and SMS**: Cannot have negative values.

## Recharge
- **Value**: Must be positive.
- **Recharge Date**: Cannot be later than the current date.
