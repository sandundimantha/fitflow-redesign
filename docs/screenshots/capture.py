import os
import time
from playwright.sync_api import sync_playwright

output_dir = r"D:\HCI LAB\docs\screenshots"
os.makedirs(output_dir, exist_ok=True)

chrome_path = r"C:\Users\NGC\AppData\Local\Google\Chrome\Application\chrome.exe"

with sync_playwright() as p:
    browser = p.chromium.launch(
        executable_path=chrome_path,
        headless=True
    )
    # Mobile viewport (iPhone 14 / Pixel 7 style: 430 x 932) for realistic app screenshots
    context = browser.new_context(
        viewport={"width": 430, "height": 932},
        device_scale_factor=2
    )
    page = context.new_page()
    page.goto("http://localhost:5000", wait_until="networkidle")
    time.sleep(5)

    # 1. Dashboard
    page.screenshot(path=os.path.join(output_dir, "01_dashboard.png"))
    print("Saved 01_dashboard.png")

    # Bottom nav has 5 items across width 430:
    # Item 0 (Dashboard): ~43 px
    # Item 1 (Workouts): ~129 px
    # Item 2 (AI Plan): ~215 px
    # Item 3 (Nutrition): ~301 px
    # Item 4 (Community): ~387 px
    # Height of bottom nav ~ 900 px
    y_nav = 900

    # 2. Workouts Tab
    page.mouse.click(129, y_nav)
    time.sleep(2)
    page.screenshot(path=os.path.join(output_dir, "02_workouts.png"))
    print("Saved 02_workouts.png")

    # 3. AI Plan Tab
    page.mouse.click(215, y_nav)
    time.sleep(2)
    # Click generate plan button in AI Plan screen
    page.mouse.click(215, 620)
    time.sleep(3)
    page.screenshot(path=os.path.join(output_dir, "03_ai_planner.png"))
    print("Saved 03_ai_planner.png")

    # 4. Nutrition Tab
    page.mouse.click(301, y_nav)
    time.sleep(2)
    page.screenshot(path=os.path.join(output_dir, "04_nutrition.png"))
    print("Saved 04_nutrition.png")

    # 5. Community Tab
    page.mouse.click(387, y_nav)
    time.sleep(2)
    page.screenshot(path=os.path.join(output_dir, "05_community.png"))
    print("Saved 05_community.png")

    # 6. Return to Dashboard and open Progress Chart
    page.mouse.click(43, y_nav)
    time.sleep(2)
    # Click 'Progress Chart' quick action card on dashboard (middle right, approx x=320, y=280)
    page.mouse.click(320, 280)
    time.sleep(2)
    page.screenshot(path=os.path.join(output_dir, "06_progress_charts.png"))
    print("Saved 06_progress_charts.png")

    browser.close()
    print("All screenshots captured successfully!")
