# XRechnung KoSIT Validator Docker

Docker container for validating XRechnung (XML) and ZUGFeRD (PDF) invoices using the official [KoSIT Validator](https://github.com/itplr-kosit/validator) with built-in HTTP daemon mode.

## Features

- ✅ **Official KoSIT Validator** - Uses the official validator from the German Coordination Office for IT Standards (KoSIT)
- ✅ **EN16931 Compliant** - Full validation against European e-invoicing standard
- ✅ **XRechnung & ZUGFeRD** - Supports both CII and UBL formats
- ✅ **HTTP Daemon Mode** - Built-in HTTP server for easy integration
- ✅ **Docker Ready** - Simple deployment with Docker or Docker Compose
- ✅ **Health Checks** - Built-in health check endpoint
- ✅ **Lightweight** - Based on Eclipse Temurin JRE 17

## Quick Start

### Using Docker

```bash
# Build the image
docker build -t xrechnung-validator .

# Run the container
docker run -d \
  --name validator \
  -p 8080:8080 \
  xrechnung-validator
```

### Using Docker Compose

```bash
# Start the service
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop the service
docker-compose down
```

## API Usage

### Health Check

```bash
curl http://localhost:8080/server/health
```

**Response:**
```xml
<health>
  <status>UP</status>
</health>
```

### Validate Invoice

```bash
curl -X POST \
  -H "Content-Type: application/xml" \
  --data-binary @invoice.xml \
  http://localhost:8080/
```

**Response:**
- `200 OK` - Invoice is valid (acceptable)
- `406 Not Acceptable` - Invoice has validation errors
- `422 Unprocessable Entity` - Processing error

The response body contains a detailed XML report with all validation errors and warnings.

### Example Response (Error)

```xml
<report xmlns="http://www.xoev.de/de/validator/varl/1" ...>
  <assessment>
    <report:accept>false</report:accept>
  </assessment>
  <validationResults>
    <error>
      <rep:message>Business rule BR-DE-1 violated: ...</rep:message>
      <rep:location>/Invoice[1]/cbc:InvoiceNumber[1]</rep:location>
    </error>
  </validationResults>
</report>
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JAVA_OPTS` | `-Xmx512m -Xms256m` | Java memory settings |

### Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `VALIDATOR_VERSION` | `1.5.2` | KoSIT Validator version |
| `CONFIG_VERSION` | `2025-07-10` | XRechnung configuration release date |

### Custom Validator Version

```bash
docker build \
  --build-arg VALIDATOR_VERSION=1.5.2 \
  --build-arg CONFIG_VERSION=2025-07-10 \
  -t xrechnung-validator .
```

## Integration Examples

### cURL

```bash
# Validate XRechnung XML
curl -X POST \
  -H "Content-Type: application/xml" \
  --data-binary @xrechnung.xml \
  http://localhost:8080/

# Validate with verbose output
curl -X POST \
  -H "Content-Type: application/xml" \
  --data-binary @xrechnung.xml \
  -v \
  http://localhost:8080/
```

### Ruby / Rails

```ruby
require 'net/http'
require 'nokogiri'

class XrechnungValidator
  def self.validate(xml_content)
    uri = URI('http://localhost:8080/')
    response = Net::HTTP.post(uri, xml_content, 'Content-Type' => 'application/xml')

    case response.code.to_i
    when 200
      { valid: true, report: parse_report(response.body) }
    when 406
      { valid: false, report: parse_report(response.body) }
    else
      { valid: false, error: "Validation failed with status #{response.code}" }
    end
  end

  def self.parse_report(xml_body)
    doc = Nokogiri::XML(xml_body)
    doc.remove_namespaces!

    {
      acceptable: doc.at_xpath('//accept')&.text == 'true',
      errors: doc.xpath('//error/message').map(&:text),
      warnings: doc.xpath('//warning/message').map(&:text)
    }
  end
end
```

### Python

```python
import requests

def validate_xrechnung(xml_file_path):
    with open(xml_file_path, 'rb') as f:
        response = requests.post(
            'http://localhost:8080/',
            data=f,
            headers={'Content-Type': 'application/xml'}
        )

    return {
        'valid': response.status_code == 200,
        'status_code': response.status_code,
        'report': response.text
    }

# Usage
result = validate_xrechnung('invoice.xml')
print(f"Valid: {result['valid']}")
```

### JavaScript / Node.js

```javascript
const fs = require('fs');
const axios = require('axios');

async function validateXRechnung(xmlFilePath) {
  const xmlContent = fs.readFileSync(xmlFilePath, 'utf8');

  try {
    const response = await axios.post('http://localhost:8080/', xmlContent, {
      headers: { 'Content-Type': 'application/xml' },
      validateStatus: () => true // Accept all status codes
    });

    return {
      valid: response.status === 200,
      statusCode: response.status,
      report: response.data
    };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

// Usage
validateXRechnung('invoice.xml').then(result => {
  console.log('Valid:', result.valid);
});
```

## Supported Formats

### XRechnung (XML)
- **CII** (Cross Industry Invoice) - UN/CEFACT format
- **UBL** (Universal Business Language) - OASIS format

### ZUGFeRD (PDF)
For ZUGFeRD PDF validation, you need to extract the embedded XML first:
- Extract XML from PDF using tools like `pdftotext` or PDF libraries
- Send the extracted XML to the validator

## Validation Rules

The validator checks invoices against:
- **EN16931** - European e-invoicing standard
- **XRechnung** - German e-invoicing standard (based on EN16931)
- **Business Rules** - Additional validation rules (BR-DE-* for Germany)
- **Technical Rules** - XML schema validation

## Production Deployment

### Docker Swarm

```bash
docker service create \
  --name xrechnung-validator \
  --publish 8080:8080 \
  --replicas 3 \
  xrechnung-validator
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: xrechnung-validator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: xrechnung-validator
  template:
    metadata:
      labels:
        app: xrechnung-validator
    spec:
      containers:
      - name: validator
        image: xrechnung-validator:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /server/health
            port: 8080
          initialDelaySeconds: 40
          periodSeconds: 30
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: xrechnung-validator
spec:
  selector:
    app: xrechnung-validator
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs validator

# Check if port is already in use
lsof -i :8080
```

### Validation takes too long
- Increase memory allocation via `JAVA_OPTS`
- Check invoice file size (large files take longer)
- Ensure sufficient CPU resources

### Out of memory errors
```bash
# Increase Java heap size
docker run -d \
  -e JAVA_OPTS="-Xmx1g -Xms512m" \
  -p 8080:8080 \
  xrechnung-validator
```

## Development

### Build from source
```bash
git clone https://github.com/yourusername/xrechnung-kosit-validator.git
cd xrechnung-kosit-validator
docker build -t xrechnung-validator .
```

### Run tests
```bash
# Test health endpoint
curl http://localhost:8080/server/health

# Test with example invoice
curl -X POST \
  --data-binary @examples/valid-invoice.xml \
  http://localhost:8080/
```

## References

- [KoSIT Validator](https://github.com/itplr-kosit/validator) - Official validator repository
- [XRechnung Standard](https://www.xrechnung.de/) - German e-invoicing standard
- [EN16931](https://ec.europa.eu/cefdigital/wiki/display/CEFDIGITAL/EN16931) - European e-invoicing standard
- [KoSIT Daemon Documentation](https://github.com/itplr-kosit/validator/blob/master/docs/daemon.md) - HTTP daemon mode docs

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

- **KoSIT Validator** - Developed by the German Coordination Office for IT Standards
- **XRechnung Configuration** - Maintained by the XRechnung community

## Support

For issues related to:
- **This Docker container**: Open an issue in this repository
- **KoSIT Validator**: Check the [official repository](https://github.com/itplr-kosit/validator/issues)
- **XRechnung Standard**: Visit [xrechnung.de](https://www.xrechnung.de/)
