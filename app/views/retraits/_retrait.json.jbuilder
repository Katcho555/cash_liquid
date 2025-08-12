json.extract! retrait, :id, :user_id, :methode, :numero_retrait, :nom_percepteur, :montant, :statut, :created_at, :updated_at
json.url retrait_url(retrait, format: :json)
