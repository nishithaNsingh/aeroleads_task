from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
import csv

# My LinkedIn test account credentials
USERNAME = "nishithasingh666@gmail.com"  
PASSWORD = "Nishitha666@"         

def setup_browser():
    """Setting up Chrome - tried headless first but LinkedIn detected it"""
    options = webdriver.ChromeOptions()
    
    # These help avoid detection - found from stackoverflow
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    
    # Tried headless but LinkedIn blocks it, so keeping browser visible
    # options.add_argument('--headless')
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), 
                              options=options)
    return driver

def login_to_linkedin(driver):
    """Login function - this took some trial and error"""
    print("Trying to login...")
    driver.get('https://www.linkedin.com/login')
    time.sleep(2)
    
    # Find username field and enter email
    username_input = driver.find_element(By.ID, 'username')
    username_input.send_keys(USERNAME)
    
    # Find password field
    password_input = driver.find_element(By.ID, 'password')
    password_input.send_keys(PASSWORD)
    
    # Click login
    login_btn = driver.find_element(By.CSS_SELECTOR, 'button[type="submit"]')
    login_btn.click()
    
    time.sleep(5)  # Wait for login - sometimes captcha appears here
    
    # Check if we're logged in
    if 'feed' in driver.current_url:
        print("Login successful!")
        return True
    else:
        print("Might need to handle captcha manually...")
        input("Press Enter after solving captcha...")
        return True

def scrape_profile(driver, profile_url):
    """
    Scrape one profile - LinkedIn's HTML keeps changing so this might break
    Focusing on basic info that's usually visible
    """
    print(f"Scraping {profile_url}")
    driver.get(profile_url)
    time.sleep(3)  # Let page load
    
    # Scroll down a bit to load more content
    driver.execute_script("window.scrollTo(0, 500)")
    time.sleep(2)
    
    profile_info = {}
    profile_info['url'] = profile_url
    
    # Try to get name - it's usually in an h1 tag
    try:
        name = driver.find_element(By.TAG_NAME, 'h1').text
        profile_info['name'] = name
    except:
        profile_info['name'] = 'Not found'
    
    # Get headline/title - this selector works sometimes
    try:
        headline = driver.find_element(By.CLASS_NAME, 'text-body-medium').text
        profile_info['headline'] = headline
    except:
        profile_info['headline'] = 'Not found'
    
    # Location - tried multiple ways, this seems to work
    try:
        location_elements = driver.find_elements(By.CLASS_NAME, 'text-body-small')
        if location_elements:
            profile_info['location'] = location_elements[0].text
        else:
            profile_info['location'] = 'Not found'
    except:
        profile_info['location'] = 'Not found'
    
    print(f"Got data for: {profile_info.get('name', 'Unknown')}")
    return profile_info

def main():
    # List of profiles to scrape - employees of aeroleads
    profiles = [
        'https://www.linkedin.com/in/nidhi-agarwal-aeroleads/',
        'http://linkedin.com/in/monalisha-rout/',
        'https://www.linkedin.com/in/abhay-motwani-583200194/',
        'https://www.linkedin.com/in/vinodh-kumar-n-592a79152/',
        'https://www.linkedin.com/in/anjan-nayak-51b426175/',
        'https://www.linkedin.com/in/prakhar-k-789122284/',
        'https://www.linkedin.com/in/maithili-6bb4052b2/',
        'https://www.linkedin.com/in/sushmitha-r-0519552b9/',
        'https://www.linkedin.com/in/palak-wariya-939179257/',
        'https://www.linkedin.com/in/jennifer-s-992742280/',
        'https://www.linkedin.com/in/brahmajee-s-304930237/',
        'https://www.linkedin.com/in/gaurav-kumar-02bb561aa/',
        'https://www.linkedin.com/in/aashirya-bhat/',
        'https://www.linkedin.com/in/deepak-lakonde/',
        'https://www.linkedin.com/in/siddharthchauhanaeroleads/',
        'https://www.linkedin.com/in/penkey-bhavya-sri-127239241/',
        'https://www.linkedin.com/in/jeevanlodha/',
        'https://www.linkedin.com/in/chandrika-reddy-81a176124/',
        'https://www.linkedin.com/in/manoharmaniklal/',
        'https://www.linkedin.com/in/arpita-gaur-770896137/',
        'https://www.linkedin.com/in/sagar-s-268339340/',
        'https://www.linkedin.com/in/jasim-uddin-b94535201/'
        

    ]
    
    print("Starting scraper...")
    driver = setup_browser()
    
    try:
        # Login first
        if not login_to_linkedin(driver):
            print("Login failed, stopping...")
            return
        
        # Store all scraped data
        all_data = []
        
        # Loop through each profile
        for i, profile_url in enumerate(profiles):
            print(f"\nProfile {i+1}/{len(profiles)}")
            
            try:
                data = scrape_profile(driver, profile_url)
                all_data.append(data)
            except Exception as e:
                print(f"Error with {profile_url}: {e}")
                # Still save what we can
                all_data.append({
                    'url': profile_url,
                    'name': 'Error',
                    'headline': str(e),
                    'location': 'Error'
                })
            
            # Wait a bit between profiles to not get blocked
            time.sleep(4)
        
        # Save to CSV
        print("\nSaving to CSV...")
        with open('linkedin_profiles.csv', 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=['url', 'name', 'headline', 'location'])
            writer.writeheader()
            writer.writerows(all_data)
        
        print(f"Done! Scraped {len(all_data)} profiles")
        print("Saved to linkedin_profiles.csv")
        
    except Exception as e:
        print(f"Something went wrong: {e}")
    finally:
        driver.quit()

if __name__ == '__main__':
    main()