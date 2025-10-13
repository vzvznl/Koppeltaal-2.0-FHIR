
#### Channel Type

The channel type is fixed to `rest-hook` - this is the only type available in Koppeltaal for sending notifications.

#### Error Handling

The `error` element contains the last error message if the subscription fails, providing debugging information for subscription issues.

#### Important Considerations

##### Preventing Loops

**Warning**: It is the responsibility of the developer to prevent endless loops caused by sending a subscription notification to the original resource owner. Developers must implement appropriate logic to avoid circular subscription chains.

#### Implementation Notes

- Only REST hook channels are supported in the Koppeltaal environment
- Payload elements are not used in this profile
- Proper error handling and loop prevention are critical for stable operation
