# 📞 Autodialer + 📝 AI Blog Generator 
## — Task 2 & Task 3



---

## 🚀 Overview

This Ruby on Rails application contains **two major features**:

### 1. Autodialer (Twilio-based)

Automatically calls 100+ phone numbers, logs statuses, and supports AI prompts like:

> “make a call to 9876543210”

###  2. AI Blog Generator

Generates 10 full programming articles using **DeepSeek API** + AI prompt interface.

This project was the **most challenging** part of the assignment because of:

✅ Rails version conflicts
✅ Twilio trial limitations
✅ Webhook callback issues on localhost
✅ Database model migrations
✅ Integrating two complex systems in one app

I learned A LOT while building it.

---

# FEATURES

## 📞 1. Autodialer (Task 2)

### ✅ **Hybrid Calling System**

Because **Twilio trial accounts can only call verified numbers**, I implemented:

### **✅ Real Calling (for verified number only)**

If the number matches `TWILIO_VERIFIED_NUMBER`, the app places a REAL Twilio call.

### **✅ Simulated Calling (for all other numbers)**

I built a simulation engine that generates:

* completed
* no-answer
* failed
* in-progress
* random realistic call durations

This allows the dashboard to look realistic **without spending money**.

---

### ✅ **Autodialer Dashboard**

Shows:

* total calls
* completed
* failed
* in-progress
* answered
* time (India Timezone)
* call logs with icons
* Twilio webhook support (in production)

---

### ✅ **Bulk Upload / Pasted Numbers**

Features include:

* Upload a text file with numbers
* Paste 100 numbers at once
* AI prompt:

  > “call 18001234567”

---

### ✅ **AI Command Prompt**

Natural language interface to trigger actions:

✅ “make a call to 919019058876”
✅ “call 100 numbers”
✅ “start calling list again”

---

### ✅ **Webhook Setup**

Twilio sends status updates to:

```
/twilio/status
```

On localhost webhook doesn’t fire because:

✅ Twilio cannot reach 127.0.0.1
✅ In production (Render) it works correctly

---

# 📝 2. Blog Generator (Task 3)

### ✅ **DeepSeek API Integration**

Generates full 800–1000 word articles with:

* headings
* subheadings
* code examples
* best practices
* conclusion

### ✅ **Two Modes**

#### 1️⃣ **AI Prompt**

Type:

> generate article about docker basics

And the app generates the article + image.

#### 2️⃣ **Batch Title Mode**

Paste up to 10 titles, one per line.

---

### ✅ **Auto Images**

Each article features a dynamic banner fetched from Pollinations.ai:

```
https://image.pollinations.ai/prompt/{title}
```

---

### ✅ **Blog Page**

Shows:

* Article card
* Auto image
* Reading time
* Slug-based URL
* View full article page

---

# 💻 Tech Stack

### **Backend**

* Ruby on Rails
* SQLite (simple + perfect for assignment)
* Twilio API
* DeepSeek API

### **Frontend**

* ERB templates
* Bootstrap for clean UI

### **Dev Tools**

* VS Code
* GitHub
* Localhost for development

---

# ⚙️ Setup Instructions

### 1️⃣ Install dependencies

```bash
bundle install
```

### 2️⃣ Set environment variables

Create `.env`:

```
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=
TWILIO_VERIFIED_NUMBER=
DEEPSEEK_API_KEY=
```

### 3️⃣ Start server

```bash
rails server
```

### 4️⃣ Visit app

```
http://localhost:3000/calls
http://localhost:3000/articles
```

---

# 🏆 Challenges I Solved

### ✅ **Rails version mismatch**

Latest Rails (7.1.x) had bugs with ActiveRecord inspectors →
I downgraded to a stable setup and fixed dependency conflicts.

### ✅ **Twilio webhook not updating**

Learned why:

> Twilio cannot reach localhost — needs public hosting.
> I used simulated calling + built-in real calling logic.

### ✅ **DeepSeek returning Markdown**

I wrote a formatter that cleans markdown → displays as readable HTML.

### ✅ **Bulk calling logic**

Handled:

* rate limits
* delays
* logging
* queueing
* hybrid calling

### ✅ **Slug system for blog URLs**

Articles open using `slug` instead of ID.

---

