# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Custom JS
pin "main", to: "main.js", preload: true
pin "marquee-main", to: "marquee-main.js", preload: true
pin "custom-gsap", to: "custom-gsap.js", preload: true
