from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
import random

url = random.choice([
    'https://www.google.com',
    'https://www.amazon.com.br/',
    'https://www.mercadolivre.com.br/',
    'https://shopee.com.br/',
    'https://shopee.com.br/',
    'https://github.com/DeepNotesApp/DeepNotes'
])


# Configurar as capabilities para o Chrome
options = ChromeOptions()
options.browser_version = "latest"
options.set_capability("browserName", "chrome")
options.set_capability(
    "selenoid:options", {
        "enableVNC": True,
    }
)

# Conectar ao Selenoid
driver = webdriver.Remote(
    command_executor="http://localhost:4444/wd/hub",
    options=options 
)

# Executar um teste simples
try:
    driver.get(url)
    print(driver.title)
    driver.maximize_window()
    import time
    time.sleep(40)
finally:
    driver.quit()
