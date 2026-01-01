# Example Files

This directory contains example XRechnung invoices for testing the validator.

## Files

### valid-xrechnung-cii.xml
A valid XRechnung 3.0 invoice in CII (Cross Industry Invoice) format.
- **Format**: UN/CEFACT Cross Industry Invoice
- **Standard**: XRechnung 3.0 (EN16931 compliant)
- **Expected Result**: ✅ Valid (HTTP 200)

## Testing

### Validate using cURL

```bash
# Test valid invoice
curl -X POST \
  --data-binary @examples/valid-xrechnung-cii.xml \
  http://localhost:8080/
```

### Expected Response

For valid invoices (HTTP 200):
```xml
<report xmlns="http://www.xoev.de/de/validator/varl/1">
  <assessment>
    <report:accept>true</report:accept>
  </assessment>
</report>
```

## Creating Your Own Test Files

You can create your own test files based on:
- [XRechnung Examples](https://github.com/itplr-kosit/xrechnung-testsuite)
- [EN16931 Specification](https://ec.europa.eu/cefdigital/wiki/display/CEFDIGITAL/EN16931)

## Common Issues

- **Missing mandatory fields**: Ensure all required EN16931 fields are present
- **Invalid VAT number format**: Use correct format (e.g., DE123456789)
- **Wrong date format**: Use format 102 (YYYYMMDD) for dates
- **Invalid currency code**: Use ISO 4217 codes (e.g., EUR, USD)
