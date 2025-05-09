class Account::AddressesController < ApplicationController
  before_action :authenticate_user!

  def index
    @addresses = current_user.addresses.order(created_at: :desc)
  end

  def show
    @address = current_user.addresses.find(params[:id])
  end


  def new
    @address = current_user.addresses.new
  end

  def create
    @address = current_user.addresses.new(address_params)
    if @address.save
      redirect_to account_addresses_path, notice: 'Dirección agregada con éxito.'
    else
      render :new
    end
  end

  def edit
    @address = current_user.addresses.find(params[:id])
  end

  def update
    @address = current_user.addresses.find(params[:id])
    if @address.update(address_params)
      redirect_to account_addresses_path, notice: 'Dirección actualizada con éxito.'
    else
      render :edit
    end
  end

  def destroy
    @address = current_user.addresses.find(params[:id])
    @address.destroy

    respond_to do |format|
      format.html { redirect_to account_addresses_path, notice: 'Dirección eliminada con éxito.' }
      format.turbo_stream
    end
  end

  private

  def address_params
    params.require(:address).permit(
      :street_name,
      :street_number,
      :floor,
      :apartment,
      :locality,
      :city,
      :province_code,
      :postal_code,
      :indications
    )
  end

end
