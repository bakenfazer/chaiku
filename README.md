# chaiku

This is a sample web application showcasing a multi-tier architecture using **Node.js**, **Python (Flask)**, **PostgreSQL**, and **nginx**.

The app is available in two variants:
- **Legacy version** with traditional upstream container images.
- **Chainguard version** using minimal, secure-by-default, zero to near-zero CVE container images.

---

## Getting Started

### Prerequisites
- [Docker](https://www.docker.com/)
- [grype](https://github.com/anchore/grype) (for scanning container images)
- Clone this directory and `cd` into it from your terminal: 
```bash
git clone https://github.com/bakenfazer/chaiku && cd chaiku
```

---

## 1. Build and Run the Legacy Version


```bash
docker compose up -d --build
```

### Verify It’s Running

- Open [http://localhost:80](http://localhost:80) in your browser to view the website. You should see the following:

![alt text](img/website.png "website")

- Check that the backend API works by running:

```bash
curl http://localhost:5000
```

You should see the following response: `Hooray! The API works.`

### Scan Legacy Images for CVEs

```bash
./scanners/grype-scan.sh
```

This will save your results to `./scanners/scan-results/grype-legacy-images.csv`.

---

## 2. Tear Down the Legacy Stack

To clean everything, including volumes:

```bash
docker compose down -v
```

---

## 3. Build and Run the Chainguard Version

```bash
docker compose -f docker-compose-chainguard.yaml up -d --build
```

### Verify It’s Running

- Open [http://localhost:80](http://localhost:80)

- Check the API:

```bash
curl http://localhost:5000/
```

### Scan Chainguard Images for CVEs

```bash
./scanners/grype-scan.sh
```

This will save your results to `./scanners/scan-results/grype-chainguard-images.csv`.

---

## 4. Tear Down the Chainguard Stack

To clean everything, including volumes:

```bash
docker compose down -v
```

---
## Compare Results

After scanning both versions, open the CSV files to review the outputs to compare:

- Total CVEs
- Severity levels (Critical, High, etc.)
- Image size and dependency differences

This highlights the value of using Chainguard's minimal, secure-by-default images like those from Chainguard.

## Extra Credit

Compare image sizes, SBOMs, and provenance
