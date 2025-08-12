require "test_helper"

class RetraitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retrait = retraits(:one)
  end

  test "should get index" do
    get retraits_url
    assert_response :success
  end

  test "should get new" do
    get new_retrait_url
    assert_response :success
  end

  test "should create retrait" do
    assert_difference("Retrait.count") do
      post retraits_url, params: { retrait: { methode: @retrait.methode, montant: @retrait.montant, nom_percepteur: @retrait.nom_percepteur, numero_percepteur: @retrait.numero_percepteur, numero_retrait: @retrait.numero_retrait, statut: @retrait.statut, user_id: @retrait.user_id } }
    end

    assert_redirected_to retrait_url(Retrait.last)
  end

  test "should show retrait" do
    get retrait_url(@retrait)
    assert_response :success
  end

  test "should get edit" do
    get edit_retrait_url(@retrait)
    assert_response :success
  end

  test "should update retrait" do
    patch retrait_url(@retrait), params: { retrait: { methode: @retrait.methode, montant: @retrait.montant, nom_percepteur: @retrait.nom_percepteur, numero_percepteur: @retrait.numero_percepteur, numero_retrait: @retrait.numero_retrait, statut: @retrait.statut, user_id: @retrait.user_id } }
    assert_redirected_to retrait_url(@retrait)
  end

  test "should destroy retrait" do
    assert_difference("Retrait.count", -1) do
      delete retrait_url(@retrait)
    end

    assert_redirected_to retraits_url
  end
end
