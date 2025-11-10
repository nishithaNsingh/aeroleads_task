# 🕸️ LinkedIn Profile Scraper (AeroLeads Assignment – Task 1)

## 🚀 Features

* ✅ **Automated Login** using a LinkedIn test account
* ✅ **Smart scraping** with Selenium and Chrome WebDriver
* ✅ **Anti-detection techniques** (disabled automation flags)
* ✅ **Profile scrolling** to load dynamic content
* ✅ **Exports clean CSV** with URL, Name, Headline, and Location
* ✅ **Handles captcha manually** if prompted

## 🧠 Approach

LinkedIn actively blocks automated scrapers, so I focused on a **manual + automated hybrid**:

1. **Login Handling:**
   Used a test LinkedIn account. If CAPTCHA appears, the script pauses for manual solving.

2. **Avoiding Detection:**

   * Disabled Chrome’s `enable-automation` flag
   * Avoided headless mode
   * Added scrolling to mimic human-like behavior

3. **Scraping Logic:**

   * Visited each profile URL
   * Extracted name (`<h1>` tag), headline (class `text-body-medium`), and location (class `text-body-small`)
   * Stored results in a CSV

---

## 📂 Output Example

**linkedin_profiles.csv**

| URL                                                                | Name     | Headline                 | Location          |
| ------------------------------------------------------------------ | -------- | ------------------------ | ----------------- |
| [https://linkedin.com/in/example](https://linkedin.com/in/example) | John Doe | Software Engineer at XYZ | San Francisco, CA |

---

## 🧰 Technologies Used

* **Python 3**
* **Selenium WebDriver**
* **ChromeDriverManager**
* **CSV (built-in module)**

---

## ⚙️ How to Run

### 1️⃣ Install dependencies

```bash
pip install selenium webdriver-manager
```

### 2️⃣ Update credentials

Open the script and replace:

```python
USERNAME = "email@gmail.com"
PASSWORD = "********"
```

with your **test LinkedIn account** credentials.

### 3️⃣ Run the script

```bash
python linkedin_scraper.py
```

### 4️⃣ Output

After completion, a file named **linkedin_profiles.csv** will be created in your project folder.

---

## 🔒 Important Notes
* 🚫 LinkedIn prohibits automated scraping under its [Terms of Service](https://www.linkedin.com/legal/user-agreement).


---

## 🧩 Challenges Faced

* Handling **CAPTCHAs and login blocks** from LinkedIn
* **Dynamic selectors** — LinkedIn changes its DOM structure often
* Preventing **detection of automation tools** by Chrome
* Balancing **realistic wait times** to avoid temporary bans

---

## 📊 Example Profiles Used

The script scrapes about **20–22 AeroLeads employee profiles** (public URLs) to demonstrate functionality.

---

