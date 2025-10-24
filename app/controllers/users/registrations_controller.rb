# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :balance_admin
    
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    Rails.logger.info "params[:ref] = #{params[:ref]}"
    session[:referral_code] = params[:ref] if params[:ref].present?
    super
  end

  # POST /resource
  def create
  super do |user|
    if session[:referral_code].present?
      Rails.logger.info "Referral code present: #{session[:referral_code]}"
      parrain_initial = User.find_by(referral_code: session[:referral_code])

      if parrain_initial
        Rails.logger.info "Parrain trouvé : #{parrain_initial.id}"

        # On cherche le premier parrain dispo dans son arbre
        parrain_dispo = parrain_initial.premier_parrain_disponible(3)

        if parrain_dispo
          user.parrain = parrain_dispo
          Rails.logger.info "Parrain final attribué : #{parrain_dispo.id}"
        else
          Rails.logger.warn "Aucun parrain disponible trouvé."
        end

        user.save(validate: false)
      else
        Rails.logger.warn "Aucun parrain trouvé pour le code : #{session[:referral_code]}"
      end
    end
  end
end





  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end


  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

   # Redirection après inscription
  def after_sign_up_path_for(resource)
    # Exemple : rediriger vers une page de bienvenue
    if resource.subscriptions.present?
      dashboard_index_path
    else
      souscriptions_path
    end
  end

  # Redirection après modification du compte
  # def after_update_path_for(resource)
  #   # Exemple : rediriger vers le profil
  #   profile_path
  # end
  # protected


    protected
      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:nom, :prenom])
        devise_parameter_sanitizer.permit(:account_update, keys: [:nom, :prenom])
      end

      def update_resource(resource, params)
          if params[:password].present? || params[:password_confirmation].present?
          # L'utilisateur veut changer le mot de passe, on exige l'ancien mot de passe
          resource.update_with_password(params)
        else
          # Pas de changement de mot de passe, on ne demande pas l'ancien mot de passe
          filtered_params = params.except(:current_password)
          resource.update_without_password(filtered_params)
        end
      end

      # Optionnel, pour rediriger après update réussie
      def after_update_path_for(resource)
        user_profile_path # ou une autre page
      end

    private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :nom, :prenom, :role, :parrain_id)
      end

      def account_update_params
        params.require(:user).permit(:nom, :prenom, :email, :telephone, :password, :password_confirmation, :current_password)
      end

  # def account_update_params
  #   params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :nom, :prenom, :role)
  # end
  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
