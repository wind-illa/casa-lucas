# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/controllers/shared", under: "controllers/shared"
pin_all_from "app/javascript/controllers/admin", under: "controllers/admin"
pin_all_from "app/javascript/controllers/store", under: "controllers/store"
pin_all_from "app/javascript/controllers/business", under: "controllers/business"
pin_all_from "app/javascript/controllers/pos", under: "controllers/pos"
pin_all_from "app/javascript/controllers/logistics", under: "controllers/logistics"
