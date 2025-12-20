class HomesController < ApplicationController
    def accueil
        @products = Product.all
        @prime = Parametre.find_by(cle: 'prime_parrainage')&.valeur.to_f || 0
    end
end