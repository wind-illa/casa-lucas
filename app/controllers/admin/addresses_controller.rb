class Admin::AddressesController < ApplicationController
  before_action :set_user
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy]

  def new
    @address = @user.addresses.new
  end

  def create
    @address = @user.addresses.new(address_params)
    if @address.save
      redirect_to [:admin, @user], notice: 'Dirección agregada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to [:admin, @user], notice: 'Dirección actualizada.'

    else
      render :edit
    end
  end

  def destroy
    @address = @user.addresses.find(params[:id])
    @address.destroy
    redirect_to admin_user_path(@user), notice: 'Dirección eliminada exitosamente.'
  end


  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_address
    @address = @user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:street_name, :street_number, :postal_code, :city, :locality, :floor, :apartment, :indications)
  end
end
