require "application_system_test_case"

class RetraitsTest < ApplicationSystemTestCase
  setup do
    @retrait = retraits(:one)
  end

  test "visiting the index" do
    visit retraits_url
    assert_selector "h1", text: "Retraits"
  end

  test "should create retrait" do
    visit retraits_url
    click_on "New retrait"

    fill_in "Methode", with: @retrait.methode
    fill_in "Montant", with: @retrait.montant
    fill_in "Nom percepteur", with: @retrait.nom_percepteur
    fill_in "Numero percepteur", with: @retrait.numero_percepteur
    fill_in "Numero retrait", with: @retrait.numero_retrait
    fill_in "Statut", with: @retrait.statut
    fill_in "User", with: @retrait.user_id
    click_on "Create Retrait"

    assert_text "Retrait was successfully created"
    click_on "Back"
  end

  test "should update Retrait" do
    visit retrait_url(@retrait)
    click_on "Edit this retrait", match: :first

    fill_in "Methode", with: @retrait.methode
    fill_in "Montant", with: @retrait.montant
    fill_in "Nom percepteur", with: @retrait.nom_percepteur
    fill_in "Numero percepteur", with: @retrait.numero_percepteur
    fill_in "Numero retrait", with: @retrait.numero_retrait
    fill_in "Statut", with: @retrait.statut
    fill_in "User", with: @retrait.user_id
    click_on "Update Retrait"

    assert_text "Retrait was successfully updated"
    click_on "Back"
  end

  test "should destroy Retrait" do
    visit retrait_url(@retrait)
    click_on "Destroy this retrait", match: :first

    assert_text "Retrait was successfully destroyed"
  end
end
