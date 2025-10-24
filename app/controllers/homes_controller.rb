class HomesController < ApplicationController
    def accueil
        @prime_inscription = Parametre.find_by(cle: 'prime_inscription')&.valeur.to_i || 0

        @frais_souscription = Parametre.find_by(cle: 'frais_souscription')&.valeur.to_i || 0
    end
end