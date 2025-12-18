class HomesController < ApplicationController
    def accueil
       prime = Parametre.find_by(cle: 'prime_parrainage')&.valeur.to_i
    end
end